import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../community/community_widgets.dart';

/// Refreshes everything a job action can change.
void invalidateDeliveryData(WidgetRef ref) {
  ref.invalidate(deliveryProfileProvider);
  ref.invalidate(deliveryOpenJobsProvider);
  ref.invalidate(deliveryMyJobsProvider);
}

/// The one button a job can show: "Accept job" for an open job, otherwise the next valid step
/// ("Picked up", then "On the way", then "Delivered"). Each press asks first.
class DeliveryJobActionButton extends ConsumerWidget {
  final DeliveryJob job;

  const DeliveryJobActionButton({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    final isOpen = job.status == 'available';
    final nextLabel = strings.dlNextStepLabel(job.status);
    if (!isOpen && nextLabel == null) return const SizedBox.shrink();

    Future<void> run() async {
      final confirmed = await showCommunityConfirm(
        context,
        title: isOpen ? strings.dlAcceptAskTitle : strings.dlStepAskTitle,
        body: isOpen ? strings.dlAcceptAskBody : strings.dlStepAskBody(nextLabel!),
        confirmLabel: strings.dlConfirmYes,
        cancelLabel: strings.dlCancel,
      );
      if (!confirmed || !context.mounted) return;
      final repo = ref.read(deliveryRepositoryProvider);
      try {
        if (isOpen) {
          await repo.acceptJob(job.id);
        } else {
          await repo.updateJobStatus(job.id, _nextStatus(job.status)!);
        }
        invalidateDeliveryData(ref);
      } catch (_) {
        if (context.mounted) showCommunityNotice(context, strings.dlActionError);
      }
    }

    return KeyedSubtree(
      key: Key(isOpen ? 'delivery_accept_${job.id}' : 'delivery_step_${job.id}'),
      child: CommunityPrimaryButton(label: isOpen ? strings.dlAcceptJob : nextLabel!, onPressed: run),
    );
  }

  static String? _nextStatus(String status) {
    switch (status) {
      case 'accepted':
        return 'picked_up';
      case 'picked_up':
        return 'on_the_way';
      case 'on_the_way':
        return 'delivered';
      default:
        return null;
    }
  }
}

/// A delivery job in a list: places, goods, weight and distance, the fee, the cash to collect, and the action.
class DeliveryJobCard extends ConsumerWidget {
  final DeliveryJob job;
  final bool showStatus;

  const DeliveryJobCard({super.key, required this.job, required this.showStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    return KeyedSubtree(
      key: Key('delivery_job_${job.id}'),
      child: CommunityCard(
        onTap: () => context.push('/delivery/jobs/${job.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    strings.dlRoute(job.pickupVillage, job.dropVillage),
                    style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading, height: 1.25),
                  ),
                ),
                if (showStatus) ...[
                  SizedBox(width: 8.0 * s),
                  Flexible(child: CommunityChip(label: strings.dlStatusLabel(job.status), strong: job.status == 'delivered')),
                ],
              ],
            ),
            SizedBox(height: 6.0 * s),
            Text(
              job.goodsSummary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.0 * s, color: tokens.bodyText, height: 1.35),
            ),
            SizedBox(height: 4.0 * s),
            Text(
              strings.dlWeightDistance(_num(job.weightKg), _num(job.distanceKm)),
              style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
            ),
            SizedBox(height: 8.0 * s),
            Row(
              children: [
                Text(
                  '${strings.dlFee}: ',
                  style: TextStyle(fontSize: 13.5 * s, color: tokens.mutedText),
                ),
                Flexible(
                  child: Text(
                    formatRupees(job.feePaise),
                    style: TextStyle(fontSize: 17.0 * s, fontWeight: FontWeight.w800, color: tokens.orange),
                  ),
                ),
              ],
            ),
            if (job.collectCashPaise > 0) ...[
              SizedBox(height: 6.0 * s),
              Text(
                strings.dlCollectCash(formatRupees(job.collectCashPaise)),
                key: Key('delivery_cash_${job.id}'),
                style: TextStyle(fontSize: 14.0 * s, fontWeight: FontWeight.w800, color: tokens.orange),
              ),
            ],
            if (job.status == 'available' || strings.dlNextStepLabel(job.status) != null) ...[
              SizedBox(height: 12.0 * s),
              DeliveryJobActionButton(job: job),
            ],
          ],
        ),
      ),
    );
  }
}

/// `12.0` shows as "12", `12.5` as "12.5".
String _num(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

