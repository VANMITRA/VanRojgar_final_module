import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/delivery/delivery_job_card.dart';

/// `/delivery/jobs/:id`: one job in full: both places, goods, fee, the cash line, the timeline and the action.
class DeliveryJobPage extends ConsumerWidget {
  final String jobId;

  const DeliveryJobPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));

    final mine = ref.watch(deliveryMyJobsProvider);
    final open = ref.watch(deliveryOpenJobsProvider);
    DeliveryJob? job;
    for (final list in [mine.valueOrNull, open.valueOrNull]) {
      for (final j in list ?? const <DeliveryJob>[]) {
        if (j.id == jobId) job = j;
      }
    }
    if (job == null) {
      final stillLoading = mine.isLoading || open.isLoading;
      return CommunityPage(
        title: strings.dlJobTitle,
        body: stillLoading
            ? const SizedBox.shrink()
            : CommunityCentered(
                child: KeyedSubtree(
                  key: const Key('delivery_job_missing'),
                  child: CommunityMessageCard(icon: Icons.inventory_2_outlined, body: strings.dlJobNotFound),
                ),
              ),
      );
    }

    final j = job;
    Widget place(String label, String village, String taluka, IconData icon) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.0 * s,
              height: 36.0 * s,
              decoration: BoxDecoration(color: tokens.chipBg, shape: BoxShape.circle),
              child: Icon(icon, size: 19.0 * s, color: tokens.chipText),
            ),
            SizedBox(width: 12.0 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText)),
                  Text(
                    strings.dlPlace(village, taluka),
                    style: TextStyle(fontSize: 15.5 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                  ),
                ],
              ),
            ),
          ],
        );

    final steps = j.timeline;
    return CommunityPage(
      title: strings.dlJobTitle,
      body: CommunityScroll(
        scrollKey: const Key('delivery_job_scroll'),
        children: [
          CommunityCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CommunityChip(label: strings.dlStatusLabel(j.status), strong: j.status == 'delivered'),
                ),
                SizedBox(height: 12.0 * s),
                place(strings.dlPickup, j.pickupVillage, j.pickupTaluka, Icons.upload_outlined),
                SizedBox(height: 12.0 * s),
                place(strings.dlDrop, j.dropVillage, j.dropTaluka, Icons.download_outlined),
                Divider(height: 24.0 * s, color: tokens.borders),
                Text(strings.dlGoods, style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText)),
                Text(
                  j.goodsSummary,
                  style: TextStyle(fontSize: 14.5 * s, color: tokens.bodyText, height: 1.4),
                ),
                SizedBox(height: 6.0 * s),
                Text(
                  strings.dlWeightDistance(_num(j.weightKg), _num(j.distanceKm)),
                  style: TextStyle(fontSize: 13.5 * s, color: tokens.mutedText),
                ),
                SizedBox(height: 10.0 * s),
                Row(
                  children: [
                    Text('${strings.dlFee}: ', style: TextStyle(fontSize: 14.0 * s, color: tokens.mutedText)),
                    Flexible(
                      child: Text(
                        formatRupees(j.feePaise),
                        key: const Key('delivery_job_fee'),
                        style: TextStyle(fontSize: 20.0 * s, fontWeight: FontWeight.w800, color: tokens.orange),
                      ),
                    ),
                  ],
                ),
                if (j.collectCashPaise > 0) ...[
                  SizedBox(height: 8.0 * s),
                  Text(
                    j.cashCollected ? strings.dlCashCollected : strings.dlCollectCash(formatRupees(j.collectCashPaise)),
                    key: const Key('delivery_job_cash'),
                    style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.orange),
                  ),
                ],
              ],
            ),
          ),
          if (steps.isNotEmpty) ...[
            SizedBox(height: 16.0 * s),
            CommunityHeading(strings.dlTimeline),
            CommunityCard(
              child: Column(
                key: const Key('delivery_job_timeline'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < steps.length; i++)
                    _TimelineRow(
                      label: strings.dlStatusLabel(steps[i].status),
                      date: communityDate(steps[i].at),
                      note: steps[i].note,
                      isLast: i == steps.length - 1,
                    ),
                ],
              ),
            ),
          ],
          if (j.status == 'available' || strings.dlNextStepLabel(j.status) != null) ...[
            SizedBox(height: 16.0 * s),
            DeliveryJobActionButton(job: j),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String date;
  final String? note;
  final bool isLast;

  const _TimelineRow({required this.label, required this.date, this.note, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20.0 * s,
            child: Column(
              children: [
                Container(
                  width: 12.0 * s,
                  height: 12.0 * s,
                  margin: EdgeInsets.only(top: 4.0 * s),
                  decoration: BoxDecoration(color: tokens.primaryGreen, shape: BoxShape.circle),
                ),
                if (!isLast) Expanded(child: Container(width: 2.0, color: tokens.borders)),
              ],
            ),
          ),
          SizedBox(width: 8.0 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 14.0 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14.5 * s, fontWeight: FontWeight.w800, color: tokens.heading)),
                  Text(date, style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText)),
                  if (note != null && note!.trim().isNotEmpty)
                    Text(note!, style: TextStyle(fontSize: 13.0 * s, color: tokens.bodyText, height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _num(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

