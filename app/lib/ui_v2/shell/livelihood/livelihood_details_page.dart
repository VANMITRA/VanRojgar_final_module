import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/livelihood/models/profile.dart';
import '../../../../features/livelihood/providers/intake_provider.dart';
import '../../../../features/livelihood/providers/livelihood_providers.dart';
import '../../../../features/livelihood/providers/profile_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';

/// `/livelihood/details`: Multi-step intake form for personal details.
class LivelihoodDetailsPage extends ConsumerWidget {
  const LivelihoodDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);

    final state = ref.watch(intakeProvider);
    final notifier = ref.read(intakeProvider.notifier);

    final stepTitles = [
      strings.lhStepLand,
      strings.lhStepAnimals,
      strings.lhStepAssets,
      strings.lhStepWork,
      strings.lhStepLocation,
    ];

    return PopScope(
      canPop: state.step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.back();
      },
      child: CommunityPage(
        title: strings.lhUpdateDetails,
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 8.0 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stepTitles[state.step],
                          key: const Key('lh_step_title'),
                          style: TextStyle(
                            fontSize: 15.5 * s,
                            fontWeight: FontWeight.w800,
                            color: tokens.heading,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0 * s),
                      Text(
                        '${state.step + 1} / $kIntakeSteps',
                        key: const Key('lh_step_progress_text'),
                        style: TextStyle(
                          fontSize: 13.0 * s,
                          fontWeight: FontWeight.w700,
                          color: tokens.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.0 * s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0 * s),
                    child: LinearProgressIndicator(
                      key: const Key('lh_step_progress_bar'),
                      value: (state.step + 1) / kIntakeSteps,
                      backgroundColor: tokens.chipBg,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.primaryGreen),
                      minHeight: 6.0 * s,
                    ),
                  ),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: CommunityScroll(
                scrollKey: Key('lh_details_step_${state.step}'),
                children: [
                  if (state.step == 0) _LandStepView(state: state, notifier: notifier, strings: strings),
                  if (state.step == 1) _AnimalsStepView(state: state, notifier: notifier, strings: strings),
                  if (state.step == 2) _AssetsStepView(state: state, notifier: notifier, strings: strings),
                  if (state.step == 3) _WorkStepView(state: state, notifier: notifier, strings: strings),
                  if (state.step == 4) _LocationStepView(state: state, notifier: notifier, strings: strings),
                  if (state.errorKey != null) ...[
                    SizedBox(height: 8.0 * s),
                    Text(
                      strings.raw.t(state.errorKey!),
                      key: const Key('lh_details_error'),
                      style: TextStyle(fontSize: 13.0 * s, color: tokens.orange, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom action bar
            Container(
              padding: EdgeInsets.fromLTRB(16.0 * s, 10.0 * s, 16.0 * s, MediaQuery.paddingOf(context).bottom + 10.0 * s),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border(top: BorderSide(color: tokens.borders)),
              ),
              child: Row(
                children: [
                  if (state.step > 0) ...[
                    Expanded(
                      child: CommunitySecondaryButton(
                        key: const Key('lh_step_prev_btn'),
                        label: strings.lhPrevStep,
                        onPressed: notifier.back,
                      ),
                    ),
                    SizedBox(width: 12.0 * s),
                  ],
                  Expanded(
                    flex: 2,
                    child: CommunityPrimaryButton(
                      key: Key(state.isLast ? 'lh_step_create_btn' : 'lh_step_next_btn'),
                      label: state.isLast ? strings.lhCreateReportBtn : strings.lhNextStep,
                      onPressed: () async {
                        if (state.isLast) {
                          if (notifier.validateForSave()) {
                            await ref.read(profileProvider.notifier).save(state.toProfile());
                            ref.invalidate(reportProvider);
                            if (context.mounted) {
                              context.pushReplacement('/livelihood/report');
                            }
                          }
                        } else {
                          notifier.next();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandStepView extends StatelessWidget {
  final IntakeState state;
  final IntakeNotifier notifier;
  final LivelihoodUiStrings strings;

  const _LandStepView({required this.state, required this.notifier, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.lhAreaLabel,
                style: TextStyle(fontSize: 14.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 6.0 * s),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('lh_input_area'),
                      initialValue: state.areaText,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 2.5',
                        filled: true,
                        fillColor: tokens.chipBg,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 12.0 * s),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                      ),
                      onChanged: notifier.setArea,
                    ),
                  ),
                  SizedBox(width: 8.0 * s),
                  Expanded(
                    child: DropdownButtonFormField<AreaUnit>(
                      key: const Key('lh_dropdown_unit'),
                      isExpanded: true,
                      initialValue: state.unit,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: tokens.chipBg,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0 * s, vertical: 12.0 * s),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0 * s), borderSide: BorderSide.none),
                      ),
                      items: [
                        DropdownMenuItem(value: AreaUnit.acre, child: Text(strings.lhAcre, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: AreaUnit.guntha, child: Text(strings.lhGuntha, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: AreaUnit.hectare, child: Text(strings.lhHectare, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (u) {
                        if (u != null) notifier.setUnit(u);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimalsStepView extends StatelessWidget {
  final IntakeState state;
  final IntakeNotifier notifier;
  final LivelihoodUiStrings strings;

  const _AnimalsStepView({required this.state, required this.notifier, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final code in kAnimalCodes) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0 * s),
            child: CommunityCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.raw.animal(code),
                      style: TextStyle(fontSize: 14.5 * s, fontWeight: FontWeight.w700, color: tokens.heading),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('lh_animal_minus_$code'),
                        icon: const Icon(Icons.remove_circle_outline),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 36 * s, minHeight: 36 * s),
                        onPressed: () {
                          final cur = state.animals[code] ?? 0;
                          if (cur > 0) notifier.setAnimal(code, cur - 1);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0 * s),
                        child: Text(
                          '${state.animals[code] ?? 0}',
                          key: Key('lh_animal_count_$code'),
                          style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                        ),
                      ),
                      IconButton(
                        key: Key('lh_animal_plus_$code'),
                        icon: const Icon(Icons.add_circle_outline),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 36 * s, minHeight: 36 * s),
                        onPressed: () {
                          final cur = state.animals[code] ?? 0;
                          notifier.setAnimal(code, cur + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AssetsStepView extends StatelessWidget {
  final IntakeState state;
  final IntakeNotifier notifier;
  final LivelihoodUiStrings strings;

  const _AssetsStepView({required this.state, required this.notifier, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.lhStepAssets,
                style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 10.0 * s),
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 8.0 * s,
                children: [
                  for (final code in kAssetCodes)
                    FilterChip(
                      key: Key('lh_asset_$code'),
                      selected: state.assets.contains(code),
                      label: Text(strings.raw.asset(code)),
                      onSelected: (_) => notifier.toggleAsset(code),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkStepView extends StatelessWidget {
  final IntakeState state;
  final IntakeNotifier notifier;
  final LivelihoodUiStrings strings;

  const _WorkStepView({required this.state, required this.notifier, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.lhStepWork,
                style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 10.0 * s),
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 8.0 * s,
                children: [
                  for (final w in kPastWorkCodes)
                    FilterChip(
                      key: Key('lh_work_$w'),
                      selected: state.pastWork.contains(w),
                      label: Text(strings.raw.t('w_$w')),
                      onSelected: (_) => notifier.togglePastWork(w),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationStepView extends StatelessWidget {
  final IntakeState state;
  final IntakeNotifier notifier;
  final LivelihoodUiStrings strings;

  const _LocationStepView({required this.state, required this.notifier, required this.strings});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.lhStepLocation,
                style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 8.0 * s),
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 8.0 * s,
                children: [
                  ChoiceChip(
                    key: const Key('lh_loc_village'),
                    selected: state.source == LocationSource.villageCentre,
                    label: Text(strings.lhVillageCentre),
                    onSelected: (_) => notifier.setSource(LocationSource.villageCentre),
                  ),
                  ChoiceChip(
                    key: const Key('lh_loc_plot'),
                    selected: state.source == LocationSource.gps,
                    label: Text(strings.lhPlotCentre),
                    onSelected: (_) => notifier.setSource(LocationSource.gps),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
