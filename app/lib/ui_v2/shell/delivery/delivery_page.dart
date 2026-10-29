import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../models/catalog_models.dart';
import '../../models/community_models.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/delivery/delivery_job_card.dart';

/// `/delivery`: what a visitor sees depends on who they are (guest, not a CFR holder, CFR holder who has
/// not applied, applied with a status, or an approved partner with the jobs hub).
class DeliveryPage extends ConsumerStatefulWidget {
  const DeliveryPage({super.key});

  @override
  ConsumerState<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends ConsumerState<DeliveryPage> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(ref.watch(uiV2LanguageProvider));
    final user = ref.watch(authUserProvider);

    final Widget body;
    if (user == null) {
      body = CommunityCentered(child: CommunityGuestCard(icon: Icons.two_wheeler, body: strings.dlGuestBody));
    } else if (!isCfrHolderRole(user.role)) {
      body = CommunityCentered(
        child: KeyedSubtree(
          key: const Key('delivery_not_cfr'),
          child: CommunityMessageCard(
            icon: Icons.two_wheeler,
            title: strings.dlNotCfrTitle,
            body: strings.dlNotCfrBody,
          ),
        ),
      );
    } else {
      body = _buildPartnerBody(strings);
    }

    return CommunityPage(title: strings.dlTitle, body: body);
  }

  Widget _buildPartnerBody(AppStrings strings) {
    final profile = ref.watch(deliveryProfileProvider);
    return profile.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => CommunityCentered(
        child: CommunityMessageCard(
          icon: Icons.cloud_off_outlined,
          body: strings.dlLoadError,
          actions: [
            KeyedSubtree(
              key: const Key('delivery_retry'),
              child: CommunityPrimaryButton(
                label: strings.dlRetry,
                onPressed: () => ref.invalidate(deliveryProfileProvider),
              ),
            ),
          ],
        ),
      ),
      data: (p) {
        if (p == null) return _buildIntro(strings);
        if (p.isApproved) return _buildHub(strings, p);
        return _buildStatus(strings, p);
      },
    );
  }

  Widget _buildIntro(AppStrings strings) {
    return CommunityCentered(
      child: KeyedSubtree(
        key: const Key('delivery_intro'),
        child: CommunityMessageCard(
          icon: Icons.two_wheeler,
          title: strings.dlIntroTitle,
          body: strings.dlIntroBody,
          actions: [
            KeyedSubtree(
              key: const Key('delivery_apply_button'),
              child: CommunityPrimaryButton(
                label: strings.dlApplyButton,
                onPressed: () => context.push('/delivery/apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(AppStrings strings, DeliveryPartnerProfile p) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final String title;
    final String body;
    final IconData icon;
    switch (p.approvalStatus) {
      case 'rejected':
        title = strings.dlRejectedTitle;
        body = strings.dlRejectedBody;
        icon = Icons.highlight_off_rounded;
      case 'paused':
        title = strings.dlPausedTitle;
        body = strings.dlPausedBody;
        icon = Icons.pause_circle_outline_rounded;
      default:
        title = strings.dlPendingTitle;
        body = strings.dlPendingBody;
        icon = Icons.hourglass_top_rounded;
    }
    final note = p.reviewNote?.trim();
    return CommunityCentered(
      child: KeyedSubtree(
        key: Key('delivery_status_${p.approvalStatus}'),
        child: CommunityMessageCard(
          icon: icon,
          title: title,
          body: body,
          actions: [
            if (note != null && note.isNotEmpty)
              Container(
                key: const Key('delivery_review_note'),
                padding: EdgeInsets.all(12.0 * s),
                decoration: BoxDecoration(
                  color: tokens.chipBg,
                  borderRadius: BorderRadius.circular(12.0 * s),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dlReviewNote,
                      style: TextStyle(fontSize: 12.0 * s, fontWeight: FontWeight.w700, color: tokens.chipText),
                    ),
                    SizedBox(height: 2.0 * s),
                    Text(note, style: TextStyle(fontSize: 14.0 * s, color: tokens.chipText, height: 1.35)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHub(AppStrings strings, DeliveryPartnerProfile p) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final jobsAsync = _segment == 0 ? ref.watch(deliveryOpenJobsProvider) : ref.watch(deliveryMyJobsProvider);

    Future<void> setAvailable(bool value) async {
      try {
        await ref.read(deliveryRepositoryProvider).setAvailable(value);
        invalidateDeliveryData(ref);
      } catch (_) {
        if (mounted) showCommunityNotice(context, strings.dlActionError);
      }
    }

    final Widget jobs = jobsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => CommunityMessageCard(
        icon: Icons.cloud_off_outlined,
        body: strings.dlLoadError,
        actions: [
          KeyedSubtree(
            key: const Key('delivery_jobs_retry'),
            child: CommunityPrimaryButton(
              label: strings.dlRetry,
              onPressed: () {
                ref.invalidate(deliveryOpenJobsProvider);
                ref.invalidate(deliveryMyJobsProvider);
              },
            ),
          ),
        ],
      ),
      data: (list) {
        if (list.isEmpty) {
          return KeyedSubtree(
            key: const Key('delivery_jobs_empty'),
            child: CommunityMessageCard(
              icon: Icons.inventory_2_outlined,
              body: _segment == 0 ? strings.dlNoOpenJobs : strings.dlNoMyJobs,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < list.length; i++) ...[
              if (i > 0) SizedBox(height: 12.0 * s),
              DeliveryJobCard(job: list[i], showStatus: _segment == 1),
            ],
          ],
        );
      },
    );

    return CommunityScroll(
      scrollKey: const Key('delivery_hub_scroll'),
      children: [
        CommunityCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.dlAvailableLabel,
                      style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                    ),
                  ),
                  Semantics(
                    label: strings.dlAvailableLabel,
                    toggled: p.available,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
                      child: Switch(
                        key: const Key('delivery_available_switch'),
                        value: p.available,
                        onChanged: setAvailable,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 20.0 * s, color: tokens.borders),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Stat(
                      label: strings.dlEarnings,
                      value: formatRupees(p.earningsPaise),
                      color: tokens.orange,
                      valueKey: const Key('delivery_earnings'),
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      label: strings.dlJobsDone,
                      value: '${p.jobsCompleted}',
                      color: tokens.heading,
                      valueKey: const Key('delivery_jobs_done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 14.0 * s),
        CommunitySegments(
          labels: [strings.dlSegOpen, strings.dlSegMine],
          keys: const [Key('delivery_seg_open'), Key('delivery_seg_mine')],
          selected: _segment,
          onSelect: (i) => setState(() => _segment = i),
        ),
        SizedBox(height: 12.0 * s),
        jobs,
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Key valueKey;

  const _Stat({required this.label, required this.value, required this.color, required this.valueKey});

  @override
  Widget build(BuildContext context) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText)),
        SizedBox(height: 2.0 * s),
        Text(
          value,
          key: valueKey,
          style: TextStyle(fontSize: 20.0 * s, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}

