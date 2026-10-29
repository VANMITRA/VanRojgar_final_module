import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/livelihood/providers/livelihood_providers.dart';
import '../../l10n/livelihood_ui_strings.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/community/community_widgets.dart';
import '../../widgets/livelihood/livelihood_widgets.dart';

/// `/livelihood/resources`: Nearby mapped resources.
class LivelihoodResourcesPage extends ConsumerWidget {
  const LivelihoodResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = LivelihoodUiStrings.of(context, language);
    final s = communityScale(context);

    final reportAsync = ref.watch(reportProvider);
    final filter = ref.watch(resourceFilterProvider);

    return CommunityPage(
      title: strings.lhHubResources,
      body: reportAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => CommunityCentered(
          child: CommunityMessageCard(
            key: const Key('lh_resources_error'),
            icon: Icons.cloud_off_outlined,
            body: strings.lhReportLoadError,
            actions: [
              CommunityPrimaryButton(
                key: const Key('lh_resources_retry'),
                label: strings.lhRetry,
                onPressed: () => ref.invalidate(reportProvider),
              ),
            ],
          ),
        ),
        data: (result) {
          final allResources = result.report.resources;
          final resources = filter == null
              ? allResources
              : allResources.where((x) => x.label == filter).toList();

          if (resources.isEmpty) {
            return CommunityCentered(
              child: CommunityMessageCard(
                key: const Key('lh_resources_empty'),
                icon: Icons.place_outlined,
                body: strings.lhMissingNotAvailable,
              ),
            );
          }

          return CommunityScroll(
            scrollKey: const Key('lh_resources_scroll'),
            children: [
              for (int i = 0; i < resources.length; i++) ...[
                if (i > 0) SizedBox(height: 8.0 * s),
                ResourceCardWidget(item: resources[i], strings: strings),
              ],
            ],
          );
        },
      ),
    );
  }
}

