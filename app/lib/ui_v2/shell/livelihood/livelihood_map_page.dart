import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../features/livelihood/models/profile.dart';
import '../../../../features/livelihood/models/report.dart';
import '../../../../features/livelihood/providers/livelihood_providers.dart';
import '../../../../features/livelihood/providers/market_points.dart';
import '../../../../features/livelihood/providers/profile_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';

const _defaultCentre = LatLng(19.9975, 73.7898);

/// `/livelihood/map`: Interactive map of land and surrounding resources.
class LivelihoodMapPage extends ConsumerStatefulWidget {
  const LivelihoodMapPage({super.key});

  @override
  ConsumerState<LivelihoodMapPage> createState() => _LivelihoodMapPageState();
}

class _LivelihoodMapPageState extends ConsumerState<LivelihoodMapPage> {
  final _mapController = MapController();

  LatLng? _plotCoord(LivelihoodProfile? profile) {
    if (profile == null) return null;
    final lat = profile.lat;
    final lng = profile.lng;
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);

    final profile = ref.watch(profileProvider);
    final plot = _plotCoord(profile);
    final centre = plot ?? _defaultCentre;

    final reportAsync = ref.watch(reportProvider);
    final tiles = ref.watch(mapTilesEnabledProvider);
    final resources = [
      for (final r in reportAsync.asData?.value.report.resources ?? const <ResourceItem>[])
        if (r.lat != null && r.lng != null) r,
    ];

    return CommunityPage(
      title: strings.lhHubMap,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centre,
              initialZoom: plot == null ? 9.0 : 12.0,
              minZoom: 5.0,
              maxZoom: 18.0,
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
                      radius: 5000.0,
                      useRadiusInMeter: true,
                      color: tokens.primaryGreen.withValues(alpha: 0.12),
                      borderColor: tokens.primaryGreen,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (plot != null)
                    Marker(
                      key: const Key('map_plot_marker'),
                      point: plot,
                      width: 40.0 * s,
                      height: 40.0 * s,
                      child: Icon(Icons.location_on, size: 36.0 * s, color: tokens.primaryGreen),
                    ),
                  for (final r in resources)
                    Marker(
                      key: Key('map_resource_${r.id}'),
                      point: LatLng(r.lat!, r.lng!),
                      width: 32.0 * s,
                      height: 32.0 * s,
                      child: Container(
                        decoration: BoxDecoration(
                          color: tokens.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.primaryGreen, width: 2.0),
                        ),
                        child: Icon(Icons.place, size: 18.0 * s, color: tokens.primaryGreen),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
