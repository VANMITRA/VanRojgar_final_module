import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/community_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/community_providers.dart';
import '../../widgets/barter/barter_card.dart';
import '../../widgets/community/community_widgets.dart';

/// Segment selector: 0 for "Offers to me" (incoming), 1 for "My offers" (outgoing).
final barterSegmentProvider = StateProvider.autoDispose<int>((ref) => 0);

/// `/barter`: Incoming and outgoing barter offers.
class BarterPage extends ConsumerWidget {
  const BarterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final user = ref.watch(authUserProvider);

    if (user == null) {
      return CommunityPage(
        title: strings.btTitle,
        body: CommunityCentered(
          child: CommunityGuestCard(
            icon: Icons.swap_horiz,
            body: strings.btGuestBody,
          ),
        ),
      );
    }

    final selectedSegment = ref.watch(barterSegmentProvider);
    final isIncoming = selectedSegment == 0;
    final asyncOffers = ref.watch(isIncoming ? incomingBarterProvider : outgoingBarterProvider);

    final Widget content = asyncOffers.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => CommunityCentered(
        child: CommunityMessageCard(
          icon: Icons.cloud_off_outlined,
          body: strings.msLoadError,
          actions: [
            CommunityPrimaryButton(
              label: strings.dlRetry,
              onPressed: () => ref.invalidate(isIncoming ? incomingBarterProvider : outgoingBarterProvider),
            ),
          ],
        ),
      ),
      data: (offers) {
        if (offers.isEmpty) {
          return CommunityCentered(
            child: KeyedSubtree(
              key: Key(isIncoming ? 'barter_empty_incoming' : 'barter_empty_outgoing'),
              child: CommunityMessageCard(
                icon: Icons.swap_horiz,
                body: isIncoming ? strings.btEmptyIncoming : strings.btEmptyOutgoing,
              ),
            ),
          );
        }
        final sorted = [...offers]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return CommunityScroll(
          scrollKey: Key(isIncoming ? 'barter_scroll_incoming' : 'barter_scroll_outgoing'),
          children: [
            for (int i = 0; i < sorted.length; i++) ...[
              if (i > 0) SizedBox(height: 10.0 * s),
              BarterCard(
                offer: sorted[i],
                strings: strings,
                onTap: () => context.push('/barter/${sorted[i].id}'),
              ),
            ],
          ],
        );
      },
    );

    return CommunityPage(
      title: strings.btTitle,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 8.0 * s),
            child: CommunitySegments(
              labels: [strings.btSegIncoming, strings.btSegOutgoing],
              keys: const [Key('barter_seg_incoming'), Key('barter_seg_outgoing')],
              selected: selectedSegment,
              onSelect: (idx) => ref.read(barterSegmentProvider.notifier).state = idx,
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

