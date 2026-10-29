import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/livelihood/models/scheme.dart';
import '../../../../features/livelihood/providers/detail_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood/schemes`: 10 official government schemes with links.
class LivelihoodSchemesPage extends ConsumerWidget {
  const LivelihoodSchemesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);
    final s = communityScale(context);

    final asyncSchemes = ref.watch(schemesProvider(const SchemeFilter()));

    return CommunityPage(
      title: strings.lhHubSchemes,
      body: asyncSchemes.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('lh_schemes_error'),
            icon: Icons.cloud_off_outlined,
            body: strings.lhReportLoadError,
            actions: [
              CommunityPrimaryButton(
                key: const Key('lh_schemes_retry'),
                label: strings.lhRetry,
                onPressed: () => ref.invalidate(schemesProvider(const SchemeFilter())),
              ),
            ],
          ),
        ),
        data: (result) {
          final list = result.schemes;
          if (list.isEmpty) {
            return CommunityCentered(
              child: CommunityMessageCard(
                key: const Key('lh_schemes_empty'),
                icon: Icons.account_balance_outlined,
                body: strings.lhMissingNotAvailable,
              ),
            );
          }

          return CommunityScroll(
            scrollKey: const Key('lh_schemes_scroll'),
            children: [
              for (int i = 0; i < list.length; i++) ...[
                if (i > 0) SizedBox(height: 10.0 * s),
                SchemeCardWidget(scheme: list[i], strings: strings),
              ],
            ],
          );
        },
      ),
    );
  }
}

