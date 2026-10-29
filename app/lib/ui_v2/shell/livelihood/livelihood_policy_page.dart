import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood/policy`: Forest and wildlife protection policy.
class LivelihoodPolicyPage extends ConsumerWidget {
  const LivelihoodPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);

    return CommunityPage(
      title: strings.lhHubPolicy,
      body: CommunityScroll(
        scrollKey: const Key('lh_policy_scroll'),
        children: [
          CommunityCard(
            key: const Key('lh_policy_card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.0 * s,
                      height: 44.0 * s,
                      decoration: BoxDecoration(
                        color: tokens.primaryGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.pets_outlined, size: 24.0 * s, color: tokens.primaryGreen),
                    ),
                    SizedBox(width: 12.0 * s),
                    Expanded(
                      child: Text(
                        strings.lhHubPolicy,
                        style: TextStyle(
                          fontSize: 17.0 * s,
                          fontWeight: FontWeight.w800,
                          color: tokens.heading,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.0 * s),
                Text(
                  strings.raw.t('lv_policy_body'),
                  style: TextStyle(fontSize: 14.0 * s, color: tokens.bodyText, height: 1.4),
                ),
                SizedBox(height: 14.0 * s),
                Text(
                  strings.raw.t('lv_policy_check'),
                  style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText, height: 1.35),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.0 * s),
          GramSabhaNoticeCard(strings: strings),
        ],
      ),
    );
  }
}

