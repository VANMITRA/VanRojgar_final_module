import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/livelihood/providers/detail_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood/idea/:code`: Idea detail screen.
class LivelihoodIdeaPage extends ConsumerWidget {
  final String code;

  const LivelihoodIdeaPage({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = communityTokens(context);
    final s = communityScale(context);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);
    final lang = language.name;

    final asyncIdea = ref.watch(ideaDetailProvider(code));

    return CommunityPage(
      title: strings.lhTitle,
      body: asyncIdea.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('lh_idea_error'),
            icon: Icons.cloud_off_outlined,
            body: strings.lhReportLoadError,
            actions: [
              CommunityPrimaryButton(
                key: const Key('lh_idea_retry'),
                label: strings.lhRetry,
                onPressed: () => ref.invalidate(ideaDetailProvider(code)),
              ),
            ],
          ),
        ),
        data: (d) {
          final card = d.card;
          final String name = d.name(lang);
          final String reason = strings.raw.reason(card.reason);

          return CommunityScroll(
            scrollKey: const Key('lh_idea_scroll'),
            children: [
              // Header Card
              CommunityCard(
                key: const Key('lh_idea_header'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.0 * s,
                        fontWeight: FontWeight.w800,
                        color: tokens.heading,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 10.0 * s),
                    Wrap(
                      spacing: 8.0 * s,
                      runSpacing: 8.0 * s,
                      children: [
                        WildlifeRiskBadge(risk: card.wildlifeRisk, strings: strings),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0 * s, vertical: 3.0 * s),
                          decoration: BoxDecoration(
                            color: tokens.chipBg,
                            borderRadius: BorderRadius.circular(8.0 * s),
                          ),
                          child: Text(
                            strings.lhIdeasDraftBadge,
                            style: TextStyle(fontSize: 11.5 * s, fontWeight: FontWeight.w700, color: tokens.chipText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.0 * s),

              // Why this idea
              if (reason.isNotEmpty) ...[
                CommunityCard(
                  key: const Key('lh_idea_reason'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.raw.t('idea.why'),
                        style: TextStyle(fontSize: 15.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                      ),
                      SizedBox(height: 6.0 * s),
                      Text(
                        reason,
                        style: TextStyle(fontSize: 14.0 * s, color: tokens.bodyText, height: 1.35),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.0 * s),
              ],

              // Forest rights reminder
              GramSabhaNoticeCard(strings: strings),
              SizedBox(height: 14.0 * s),

              // Related schemes
              if (d.schemes.isNotEmpty) ...[
                Text(
                  strings.lhHubSchemes,
                  style: TextStyle(fontSize: 16.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
                ),
                SizedBox(height: 8.0 * s),
                for (final sch in d.schemes) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0 * s),
                    child: SchemeCardWidget(scheme: sch, strings: strings),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
