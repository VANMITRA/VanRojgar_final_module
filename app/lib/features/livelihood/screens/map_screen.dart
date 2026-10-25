import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/error_mapping.dart';
import '../data/livelihood_repository.dart';
import '../livelihood_strings.dart';
import '../models/profile.dart';
import '../models/report.dart';
import '../providers/livelihood_providers.dart';
import '../providers/market_points.dart';
import '../providers/profile_providers.dart';
import '../widgets/lv_colors.dart';
import '../widgets/lv_scaffold.dart';

/// Where the land is, the search circle around it, and what is mapped inside it. The person can move the plot by
/// tapping the map, and change how far to look (2 to 10 km, the server's limit).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

// Nashik city: only used to open the map somewhere sensible when no plot is saved yet.
const _fallbackCentre = LatLng(19.9975, 73.7898);
const minRadiusKm = 2;
const maxRadiusKm = 10;

class _MapScreenState extends ConsumerState<MapScreen> {
  final _controller = MapController();
  int _km = 5;
  LatLng? _pin;
  bool _showListings = false;
  bool _saving = false;
  ReportResult? _report;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(profileProvider.notifier).load();
      await _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ref.read(livelihoodRepositoryProvider).report(radiusM: _km * 1000);
      if (mounted) setState(() => _report = r);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  LatLng? _plot(LivelihoodProfile? p) => p?.lat == null || p?.lng == null ? null : LatLng(p!.lat!, p.lng!);

  Future<void> _usePin() async {
    final pin = _pin;
    if (pin == null) return;
    final s = LivelihoodStrings.of(context);
    final profile = ref.read(profileProvider);
    final next = (profile ?? const LivelihoodProfile())
        .withLocation(lat: pin.latitude, lng: pin.longitude, source: LocationSource.manual);
    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).save(next);
      if (!mounted) return;
      setState(() => _pin = null);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('map_pin_saved'))));
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t(errorMessageKey(e)))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color _color(UsefulLabel label) => switch (label) {
        UsefulLabel.useful => AppColors.successGreen,
        UsefulLabel.partlyUseful => AppColors.saffron,
        UsefulLabel.notUseful => Colors.blueGrey,
      };

  IconData _icon(String kind) => switch (kind) {
        'well' => Icons.water_drop_outlined,
        'water_body' || 'water_structure' => Icons.waves_rounded,
        'river' || 'drainage_line' => Icons.stream_rounded,
        'wildlife_compartment' || 'conservation_reserve' => Icons.forest_rounded,
        'forest_compartment' => Icons.park_outlined,
        'grazing_land' => Icons.grass_rounded,
        _ => Icons.place_outlined,
      };

  void _showResource(ResourceItem r) {
    final s = LivelihoodStrings.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.name(s.lang), style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text('${s.kind(r.kind)} • ${LivelihoodStrings.distance(r.distanceM)}', style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.sm),
              Text(s.reason(r.reason), style: AppTypography.body),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LivelihoodStrings.of(context);
    final c = context.colors;
    final profile = ref.watch(profileProvider);
    final plot = _plot(profile);
    final centre = plot ?? _fallbackCentre;
    final report = _report?.report;
    final tiles = ref.watch(mapTilesEnabledProvider);
    final listings = _showListings ? ref.watch(marketPointsProvider).asData?.value ?? const [] : const <MarketPoint>[];
    final resources = [for (final r in report?.resources ?? const <ResourceItem>[]) if (r.lat != null && r.lng != null) r];

    return LvScaffold(
      title: s.t('map_title'),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: centre,
                    initialZoom: plot == null ? 9 : 12,
                    minZoom: 5,
                    maxZoom: 18,
                    onTap: (_, point) => setState(() => _pin = point),
                  ),
                  children: [
                    if (tiles)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'in.vanrozgar.app',
                      ),
                    if (plot != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: plot,
                            radius: _km * 1000.0,
                            useRadiusInMeter: true,
                            color: AppColors.saffron.withValues(alpha: 0.12),
                            borderColor: AppColors.saffron,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        for (final r in resources)
                          Marker(
                            key: ValueKey('resource_${r.id}'),
                            point: LatLng(r.lat!, r.lng!),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _showResource(r),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _color(r.label), width: 2),
                                ),
                                child: Icon(_icon(r.kind), size: 22, color: _color(r.label)),
                              ),
                            ),
                          ),
                        for (final m in listings)
                          Marker(
                            key: ValueKey('listing_${m.id}'),
                            point: LatLng(m.lat, m.lng),
                            width: 36,
                            height: 36,
                            child: Tooltip(
                              message: m.title(s.lang),
                              child: const Icon(Icons.storefront_rounded, color: Colors.indigo, size: 30),
                            ),
                          ),
                        if (plot != null)
                          Marker(
                            key: const ValueKey('my_plot'),
                            point: plot,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.location_on_rounded, color: AppColors.saffron, size: 44),
                          ),
                        if (_pin != null)
                          Marker(
                            key: const ValueKey('new_pin'),
                            point: _pin!,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.add_location_alt_rounded, color: Colors.red, size: 44),
                          ),
                      ],
                    ),
                  ],
                ),
                // OpenStreetMap asks for a visible credit: plain text on the map, not a hidden icon
                Positioned(
                  left: 6,
                  bottom: 6,
                  right: 60,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.white70,
                      child: Text(s.t('map_credit'), style: const TextStyle(fontSize: 11, color: Colors.black87)),
                    ),
                  ),
                ),
                if (_loading) const Positioned(top: 8, left: 0, right: 0, child: LinearProgressIndicator()),
              ],
            ),
          ),
          Container(
            key: const ValueKey('map_controls'),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: c.cardBg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plot == null)
                  Text(s.t('map_nothing_to_show'), style: AppTypography.body.copyWith(color: c.textSecondary)),
                Text(s.t('map_radius', {'km': _km}), style: AppTypography.subtitle.copyWith(color: c.textPrimary)),
                Slider(
                  key: const ValueKey('radius_slider'),
                  value: _km.toDouble(),
                  min: minRadiusKm.toDouble(),
                  max: maxRadiusKm.toDouble(),
                  divisions: maxRadiusKm - minRadiusKm,
                  label: '$_km km',
                  onChanged: (v) => setState(() => _km = v.round()),
                  onChangeEnd: (_) => _load(),
                ),
                if (_error != null)
                  Text(s.t(errorMessageKey(_error!)), style: AppTypography.body.copyWith(color: c.textSecondary))
                else if (!_loading && report != null && resources.isEmpty)
                  Text(s.t('map_no_resources'), style: AppTypography.body.copyWith(color: c.textSecondary)),
                if (report?.isSampleData ?? false)
                  Text(s.t('map_sample_note'), style: AppTypography.body.copyWith(color: context.lvEmphasis)),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      key: const ValueKey('listings_toggle'),
                      avatar: const Icon(Icons.storefront_rounded, size: 18),
                      label: Text(s.t('map_listings')),
                      selected: _showListings,
                      onSelected: (v) => setState(() => _showListings = v),
                    ),
                    if (_pin != null)
                      FilledButton(
                        key: const ValueKey('use_pin'),
                        onPressed: _saving ? null : _usePin,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.saffron),
                        child: Text(s.t('map_use_pin')),
                      )
                    else
                      Text(s.t('map_pin_hint'), style: AppTypography.body.copyWith(color: c.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
