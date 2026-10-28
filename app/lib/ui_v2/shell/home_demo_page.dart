import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/app_shell_top_area.dart';
import '../widgets/category_tab_row.dart';
import '../widgets/sample_product_card.dart';

/// The Home Demo Screen for VanRozgar Phase 1.
///
/// Combines the top branding, village picker, search bar, category tabs,
/// and a responsive grid of 6 sample CFR products with dynamic background tinting.
class HomeDemoPage extends ConsumerStatefulWidget {
  const HomeDemoPage({super.key});

  @override
  ConsumerState<HomeDemoPage> createState() => _HomeDemoPageState();
}

class _HomeDemoPageState extends ConsumerState<HomeDemoPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final selectedCategorySlug = ref.watch(selectedCategorySlugProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    return AppBackground(
      categorySlug: selectedCategorySlug,
      headerHeight: 220.0,
      useSafeArea: false,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Branding, Village Picker, and Search Field
            SliverToBoxAdapter(
              child: AppShellTopArea(
                language: language,
                searchController: _searchController,
                onSearchChanged: (query) {
                  ref.read(catalogSearchQueryProvider.notifier).state = query;
                },
                onVillagePickerTap: () {
                  // In Phase 1, village picker is an accessible demonstration control
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.guestModeNotice),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: VanRozgarTokens.space12),
            ),

            // 2. Horizontal Category Tabs Row
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (categories) => CategoryTabRow(
                  categories: categories,
                  selectedSlug: selectedCategorySlug,
                  language: language,
                  onSelectCategory: (slug) {
                    ref.read(selectedCategorySlugProvider.notifier).state = slug;
                  },
                ),
                loading: () => const SizedBox(height: 48.0),
                error: (_, __) => const SizedBox(height: 48.0),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: VanRozgarTokens.space12),
            ),

            // 3. Section Header: Title & Sample Badge
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VanRozgarTokens.space16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.browseSubtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: tokens.heading,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      strings.sampleBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: VanRozgarTokens.space8),
            ),

            // 4. Responsive Product Grid (Two columns on phone widths, expanding on wider windows)
            productsAsync.when(
              skipLoadingOnReload: true,
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(VanRozgarTokens.space24),
                        child: Text(
                          strings.emptyProducts,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: tokens.mutedText,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VanRozgarTokens.space16,
                    vertical: VanRozgarTokens.space8,
                  ),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final int crossAxisCount;
                      final double childAspectRatio;

                      if (width >= 900) {
                        crossAxisCount = 4;
                        childAspectRatio = 0.72;
                      } else if (width >= 600) {
                        crossAxisCount = 3;
                        childAspectRatio = 0.70;
                      } else {
                        // Standard mobile width (360px - 430px)
                        crossAxisCount = 2;
                        childAspectRatio = 0.67;
                      }

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: VanRozgarTokens.space12,
                          mainAxisSpacing: VanRozgarTokens.space12,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return SampleProductCard(
                              product: product,
                              language: language,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.localizedTitle(language)} — ${strings.sampleBadge}'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                          childCount: products.length,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: tokens.primaryGreen),
                      const SizedBox(height: VanRozgarTokens.space12),
                      Text(
                        strings.loading,
                        style: theme.textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                      ),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 36.0, color: tokens.orange),
                      const SizedBox(height: VanRozgarTokens.space8),
                      Text(
                        strings.errorLoading,
                        style: theme.textTheme.bodyMedium?.copyWith(color: tokens.bodyText),
                      ),
                      const SizedBox(height: VanRozgarTokens.space12),
                      OutlinedButton(
                        onPressed: () => ref.refresh(productsProvider),
                        child: Text(strings.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom breathing space for smooth scroll above navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: VanRozgarTokens.space24),
            ),
          ],
        ),
      ),
    );
  }
}
