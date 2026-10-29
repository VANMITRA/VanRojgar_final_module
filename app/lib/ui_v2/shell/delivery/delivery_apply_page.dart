import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/villages.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/delivery/delivery_job_card.dart';

/// `/delivery/apply`: one scrolling form with a sticky submit button.
class DeliveryApplyPage extends ConsumerStatefulWidget {
  const DeliveryApplyPage({super.key});

  @override
  ConsumerState<DeliveryApplyPage> createState() => _DeliveryApplyPageState();
}

class _DeliveryApplyPageState extends ConsumerState<DeliveryApplyPage> {
  static const _vehicles = <(String, IconData)>[
    ('bike', Icons.two_wheeler),
    ('tempo', Icons.local_shipping_outlined),
    ('pickup', Icons.airport_shuttle_outlined),
    ('tractor', Icons.agriculture_outlined),
  ];

  final _vehicleNumber = TextEditingController();
  final _capacity = TextEditingController();
  final _licence = TextEditingController();
  String _vehicleType = 'bike';
  final Set<String> _talukas = {};
  bool _submitting = false;
  String? _vehicleNumberError;
  String? _capacityError;
  String? _licenceError;
  String? _talukaError;

  @override
  void dispose() {
    _vehicleNumber.dispose();
    _capacity.dispose();
    _licence.dispose();
    super.dispose();
  }

  List<String> get _allTalukas {
    final seen = <String>[];
    for (final v in pilotVillages) {
      if (!seen.contains(v.taluka)) seen.add(v.taluka);
    }
    return seen;
  }

  Future<void> _submit(AppStrings strings) async {
    final number = _vehicleNumber.text.trim();
    final capacity = int.tryParse(_capacity.text.trim());
    final licence = _licence.text.trim();
    setState(() {
      _vehicleNumberError = number.isEmpty ? strings.dlErrVehicleNumber : null;
      _capacityError = (capacity == null || capacity <= 0) ? strings.dlErrCapacity : null;
      _licenceError = licence.length >= 4 ? null : strings.dlErrLicence;
      _talukaError = _talukas.isEmpty ? strings.dlErrTaluka : null;
    });
    if (_vehicleNumberError != null || _capacityError != null || _licenceError != null || _talukaError != null) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(deliveryRepositoryProvider).apply(
            DeliveryApplication(
              vehicleType: _vehicleType,
              vehicleNumber: number,
              capacityKg: capacity!,
              licenceNumber: licence,
              serviceTalukas: _allTalukas.where(_talukas.contains).toList(),
            ),
          );
      invalidateDeliveryData(ref);
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/delivery');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        showCommunityNotice(context, strings.dlActionError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    final user = ref.watch(authUserProvider);

    if (user == null) {
      return CommunityPage(
        title: strings.dlApplyTitle,
        body: CommunityCentered(child: CommunityGuestCard(icon: Icons.two_wheeler, body: strings.dlGuestBody)),
      );
    }
    if (!isCfrHolderRole(user.role)) {
      return CommunityPage(
        title: strings.dlApplyTitle,
        body: CommunityCentered(
          child: CommunityMessageCard(
            icon: Icons.two_wheeler,
            title: strings.dlNotCfrTitle,
            body: strings.dlNotCfrBody,
          ),
        ),
      );
    }

    Widget vehicleCard((String, IconData) v) {
      final selected = _vehicleType == v.$1;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: strings.dlVehicleName(v.$1),
          child: Material(
            color: selected ? tokens.chipBg : tokens.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0 * s),
              side: BorderSide(color: selected ? tokens.primaryGreen : tokens.borders, width: selected ? 2.0 : 1.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('delivery_vehicle_${v.$1}'),
              onTap: () => setState(() => _vehicleType = v.$1),
              child: Container(
                constraints: BoxConstraints(minHeight: 88.0 * s),
                padding: EdgeInsets.all(10.0 * s),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.$2, size: 30.0 * s, color: selected ? tokens.primaryGreen : tokens.chipText),
                    SizedBox(height: 6.0 * s),
                    Text(
                      strings.dlVehicleName(v.$1),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CommunityPage(
      title: strings.dlApplyTitle,
      bottomBar: KeyedSubtree(
        key: const Key('delivery_apply_submit'),
        child: CommunityPrimaryButton(
          label: strings.dlSubmitApplication,
          onPressed: _submitting ? null : () => _submit(strings),
        ),
      ),
      body: CommunityScroll(
        scrollKey: const Key('delivery_apply_scroll'),
        children: [
          Text(
            strings.dlVehicleType,
            style: TextStyle(fontSize: 14.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
          ),
          SizedBox(height: 8.0 * s),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                vehicleCard(_vehicles[0]),
                SizedBox(width: 10.0 * s),
                vehicleCard(_vehicles[1]),
              ],
            ),
          ),
          SizedBox(height: 10.0 * s),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                vehicleCard(_vehicles[2]),
                SizedBox(width: 10.0 * s),
                vehicleCard(_vehicles[3]),
              ],
            ),
          ),
          SizedBox(height: 16.0 * s),
          TextField(
            key: const Key('delivery_vehicle_number'),
            controller: _vehicleNumber,
            textCapitalization: TextCapitalization.characters,
            decoration: communityField(tokens, strings.dlVehicleNumber, error: _vehicleNumberError, icon: Icons.pin_outlined),
          ),
          SizedBox(height: 14.0 * s),
          TextField(
            key: const Key('delivery_capacity'),
            controller: _capacity,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: communityField(tokens, strings.dlCapacityKg, error: _capacityError, icon: Icons.scale_outlined),
          ),
          SizedBox(height: 14.0 * s),
          TextField(
            key: const Key('delivery_licence'),
            controller: _licence,
            textCapitalization: TextCapitalization.characters,
            decoration: communityField(tokens, strings.dlLicenceNumber, error: _licenceError, icon: Icons.badge_outlined),
          ),
          SizedBox(height: 16.0 * s),
          Text(
            strings.dlServiceTalukas,
            style: TextStyle(fontSize: 14.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
          ),
          SizedBox(height: 8.0 * s),
          Wrap(
            spacing: 8.0 * s,
            runSpacing: 4.0 * s,
            children: [
              for (final t in _allTalukas)
                FilterChip(
                  key: Key('delivery_taluka_$t'),
                  label: Text(t),
                  selected: _talukas.contains(t),
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  selectedColor: tokens.primaryGreen,
                  backgroundColor: tokens.chipBg,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _talukas.contains(t) ? tokens.onPrimaryGreen : tokens.chipText,
                  ),
                  shape: const StadiumBorder(),
                  onSelected: (on) => setState(() {
                    if (on) {
                      _talukas.add(t);
                    } else {
                      _talukas.remove(t);
                    }
                    _talukaError = null;
                  }),
                ),
            ],
          ),
          if (_talukaError != null)
            Padding(
              padding: EdgeInsets.only(top: 6.0 * s, left: 4.0 * s),
              child: Text(
                _talukaError!,
                key: const Key('delivery_taluka_error'),
                style: TextStyle(fontSize: 12.5 * s, color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

