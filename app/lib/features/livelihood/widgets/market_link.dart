import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../livelihood_routes.dart';
import '../livelihood_strings.dart';
import '../product_links.dart';
import '../providers/detail_providers.dart';
import '../providers/launch_provider.dart';

/// How the feature leaves for another part of the app (the add-listing screen). Tests replace it.
final marketNavigatorProvider = Provider<void Function(BuildContext context, String route)>(
  (ref) => (context, route) => GoRouter.of(context).push(route),
);

/// Shown at the top of the Livelihood home when the person arrived from a marketplace listing: what the listing was,
/// and the ideas in HIS report that can lead to that product. An idea his report does not hold is not shown.
class MarketLaunchBanner extends ConsumerWidget {
  const MarketLaunchBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launch = ref.watch(livelihoodLaunchProvider);
    final product = launch?.product == null ? null : marketProducts[launch!.product];
    if (launch == null || launch.isEmpty || (product == null && (launch.village ?? '').isEmpty)) {
      return const SizedBox.shrink();
    }
    final s = LivelihoodStrings.of(context);
    final c = context.colors;
    final village = launch.village ?? '';
    final text = product == null
        ? s.t('mk_from_listing_no_village', {'product': ''})
        : village.isEmpty
            ? s.t('mk_from_listing_no_village', {'product': product.title(s.lang)})
            : s.t('mk_from_listing', {'product': product.title(s.lang), 'village': village});
    final ideaCodes = product == null ? const <String>[] : ideasForProduct(product.code);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        key: const ValueKey('market_launch_banner'),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.saffron.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.saffron.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.saffron),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text, style: AppTypography.body.copyWith(color: c.textPrimary))),
                IconButton(
                  tooltip: s.t('mk_dismiss'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => ref.read(livelihoodLaunchProvider.notifier).state = null,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            if (product != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                ideaCodes.isEmpty ? s.t('mk_no_ideas') : s.t('mk_ideas_for'),
                style: AppTypography.subtitle.copyWith(color: c.textSecondary),
              ),
              if (ideaCodes.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [for (final code in ideaCodes) _IdeaChip(code)],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdeaChip extends ConsumerWidget {
  const _IdeaChip(this.code);

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = LivelihoodStrings.of(context);
    // Only an idea that is in his own report opens (the server answers 404 otherwise); the rest are not shown.
    return ref.watch(ideaDetailProvider(code)).maybeWhen(
          data: (d) => ActionChip(
            avatar: const Icon(Icons.lightbulb_outline_rounded, size: 18),
            label: Text(d.name(s.lang)),
            onPressed: () => Navigator.of(context).pushNamed(LivelihoodRoutes.idea, arguments: code),
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// On an idea that makes sellable produce: opens the add-listing screen already filled for the chosen product.
class MarketListButton extends ConsumerWidget {
  const MarketListButton({super.key, required this.ideaCode});

  final String ideaCode;

  Future<void> _go(BuildContext context, WidgetRef ref, List<MarketProduct> products) async {
    var chosen = products.first;
    if (products.length > 1) {
      final picked = await showModalBottomSheet<MarketProduct>(
        context: context,
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  LivelihoodStrings.of(ctx).t('mk_list_pick'),
                  style: AppTypography.subtitle,
                ),
              ),
              for (final p in products)
                ListTile(
                  key: ValueKey('pick_${p.code}'),
                  title: Text(p.title(LivelihoodStrings.of(ctx).lang)),
                  onTap: () => Navigator.of(ctx).pop(p),
                ),
            ],
          ),
        ),
      );
      if (picked == null) return;
      chosen = picked;
    }
    if (!context.mounted) return;
    ref.read(marketNavigatorProvider)(context, addListingRouteFor(chosen.code));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = productsForIdea(ideaCode);
    if (products.isEmpty) return const SizedBox.shrink();
    final s = LivelihoodStrings.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.t('mk_list_note'), style: AppTypography.body.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          key: const ValueKey('market_list_button'),
          icon: const Icon(Icons.storefront_outlined),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: () => _go(context, ref, products),
          label: Text(s.t('mk_list_button')),
        ),
      ],
    );
  }
}
