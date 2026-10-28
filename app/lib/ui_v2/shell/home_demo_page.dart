import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/app_shell_top_area.dart';
import '../widgets/category_tab_row.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_top_deals_section.dart';
import '../widgets/product_card.dart';

/// Phase 3 Home Page of the VanMitra Shop on realistic sample data.
class HomeDemoPage extends ConsumerStatefulWidget {
  const HomeDemoPage({super.key});

  @override
  ConsumerState<HomeDemoPage> createState() => _HomeDemoPageState();
}

class _HomeDemoPageState extends ConsumerState<HomeDemoPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _topDealsKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTopDeals() {
    final ctx = _topDealsKey.currentContext;
    if (ctx != null) {
      if (MediaQuery.disableAnimationsOf(context)) {
        Scrollable.ensureVisible(ctx, duration: Duration.zero);
      } else {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(uiV2LanguageProvider);
    final selectedCategorySlug = ref.watch(selectedCategorySlugProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final homeAsync = ref.watch(shopHomeProvider);
    final productsAsync = ref.watch(shopProductsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final s = (screenWidth / 360.0).clamp(0.85, 1.25);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final cardWidth = (0.40 * screenWidth).clamp(140.0, 190.0);

    return AppBackground(
      categorySlug: selectedCategorySlug,
      useSafeArea: false,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
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
            SliverToBoxAdapter(
              child: SizedBox(height: 12.0 * s),
            ),

            // 2. Horizontal Category Tabs Row (9 fixed tabs)
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
                loading: () => SizedBox(height: 48.0 * s),
                error: (_, __) => SizedBox(height: 48.0 * s),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16.0 * s),
            ),

            // 3. Main Content
            if (searchQuery.trim().isNotEmpty) ...[
              // Search Results View
              _buildSectionTitleSliver(strings.searchResultsTitle, s, tokens),
              _buildProductGridSliver(productsAsync, s, tokens, strings, strings.nothingFound),
            ] else if (selectedCategorySlug != 'all') ...[
              // Category View (Single Category)
              homeAsync.when(
                data: (home) {
                  final catDeals = home.topDeals
                      .where((p) => p.categorySlug == selectedCategorySlug)
                      .toList();
                  if (catDeals.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.0 * s),
                      child: HomeTopDealsSection(
                        topDeals: catDeals,
                        showTabs: false,
                        onSeeAllProducts: () {
                          ref.read(selectedCategorySlugProvider.notifier).state = 'all';
                          _scrollToTop();
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              _buildSectionTitleSliver(strings.allProductsTitle, s, tokens),
              _buildProductGridSliver(productsAsync, s, tokens, strings, strings.noSellersYet),
            ] else ...[
              // "all" Tab: Home Feed (3.1 to 3.7)
              homeAsync.when(
                data: (home) {
                  final bool isAllEmpty = home.topDeals.isEmpty &&
                      home.bestSellers.isEmpty &&
                      home.categories.isEmpty &&
                      home.newArrivals.isEmpty;

                  if (isAllEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0 * s),
                        child: Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0 * s),
                              child: Text(
                                strings.emptyHome,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0 * s,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // 3.1 Hero Banner
                      HomeHeroBanner(
                        topDeals: home.topDeals,
                        language: language,
                        onCtaTap: _scrollToTopDeals,
                      ),
                      SizedBox(height: 24.0 * s),

                      // 3.2 Top Deals Section
                      if (home.topDeals.isNotEmpty) ...[
                        KeyedSubtree(
                          key: _topDealsKey,
                          child: HomeTopDealsSection(
                            topDeals: home.topDeals,
                            showTabs: true,
                            onSeeAllProducts: () {
                              ref.read(selectedCategorySlugProvider.notifier).state = 'all';
                              _scrollToTop();
                            },
                          ),
                        ),
                        SizedBox(height: 24.0 * s),
                      ],

                      // 3.4 Best Sellers Section
                      if (home.bestSellers.isNotEmpty) ...[
                        _buildHorizontalListingSection(
                          title: strings.sectionBestSellers,
                          items: home.bestSellers,
                          cardType: ProductCardType.bestSeller,
                          s: s,
                          tokens: tokens,
                          cardWidth: cardWidth,
                          trailingAction: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => context.go('/categories'),
                                child: Row(
                                  children: [
                                    Text(
                                      strings.viewAll,
                                      style: TextStyle(
                                        fontSize: 13.0 * s,
                                        fontWeight: FontWeight.w600,
                                        color: tokens.primaryGreen,
                                      ),
                                    ),
                                    SizedBox(width: 2.0 * s),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 16.0 * s,
                                      color: tokens.primaryGreen,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.0 * s),
                      ],

                      // 3.5 Shop By Category Section
                      if (home.categories.isNotEmpty) ...[
                        _buildShopByCategorySection(
                          categories: home.categories,
                          allDeals: home.topDeals,
                          s: s,
                          tokens: tokens,
                          strings: strings,
                          onSelectCategory: (slug) {
                            ref.read(selectedCategorySlugProvider.notifier).state = slug;
                            _scrollToTop();
                          },
                        ),
                        SizedBox(height: 24.0 * s),
                      ],

                      // 3.7 New Arrivals Section
                      if (home.newArrivals.isNotEmpty) ...[
                        _buildHorizontalListingSection(
                          title: strings.sectionNewArrivals,
                          items: home.newArrivals,
                          cardType: ProductCardType.newArrival,
                          s: s,
                          tokens: tokens,
                          cardWidth: cardWidth,
                        ),
                        SizedBox(height: 24.0 * s),
                      ],
                    ]),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],

            // Bottom breathing space for smooth scroll above navigation bar
            SliverToBoxAdapter(
              // Extra room while the floating "View cart" pill is showing, so it never covers the last row
              child: SizedBox(
                height: bottomInset + 24.0 * s + (ref.watch(cartItemCountProvider) > 0 ? 76.0 * s : 0.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitleSliver(String title, double s, VanRozgarColorTokens tokens) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0 * s, vertical: 8.0 * s),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.0 * s,
            fontWeight: FontWeight.w800,
            color: tokens.heading,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridSliver(
    AsyncValue<List<ShopProduct>> productsAsync,
    double s,
    VanRozgarColorTokens tokens,
    AppStrings strings,
    String emptyMessage,
  ) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0 * s),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0 * s),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 36.0 * s,
                          color: tokens.primaryGreen.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: 12.0 * s),
                        Text(
                          emptyMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0 * s,
                            color: tokens.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.0 * s, vertical: 8.0 * s),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final crossAxisCount = width >= 960 ? 4 : (width >= 600 ? 3 : 2);
              final double spacing = 12.0 * s;
              final int rowCount = (products.length / crossAxisCount).ceil();

              // Rows of equally tall cards whose height comes from their content
              // (a fixed aspect ratio overflowed with bigger fonts and Hindi / Marathi).
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, rowIndex) {
                    final start = rowIndex * crossAxisCount;
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int c = 0; c < crossAxisCount; c++) ...[
                              if (c > 0) SizedBox(width: spacing),
                              Expanded(
                                child: start + c < products.length
                                    ? ProductCard(
                                        product: products[start + c],
                                        cardType: ProductCardType.grid,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: rowCount,
                ),
              );
            },
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildHorizontalListingSection({
    required String title,
    required List<ShopListingCard> items,
    required ProductCardType cardType,
    required double s,
    required VanRozgarColorTokens tokens,
    required double cardWidth,
    Widget? trailingAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
          child: Row(
            children: [
              // The title takes the free width and wraps / shortens, so a long title or a big
              // font never pushes "View all" out of the row.
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0 * s,
                    fontWeight: FontWeight.w800,
                    color: tokens.heading,
                  ),
                ),
              ),
              if (trailingAction != null) ...[
                SizedBox(width: 8.0 * s),
                trailingAction,
              ],
            ],
          ),
        ),
        SizedBox(height: 12.0 * s),
        // The row height follows the tallest card (no fixed height), and the cards in the row
        // are equally tall, so bigger fonts and longer Hindi / Marathi text never overflow.
        RepaintBoundary(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(width: 12.0 * s),
                    SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: items[i].product,
                        listing: items[i].listing,
                        cardType: cardType,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopByCategorySection({
    required List<ShopCategoryCount> categories,
    required List<ShopProduct> allDeals,
    required double s,
    required VanRozgarColorTokens tokens,
    required AppStrings strings,
    required ValueChanged<String> onSelectCategory,
  }) {
    // Helper to find image for category
    String getCatImage(String slug) {
      for (final p in allDeals) {
        if (p.categorySlug == slug) return p.imageAsset;
      }
      return 'assets/catalog/fruit_mango.jpg';
    }

    // 4-column layout
    final List<List<ShopCategoryCount>> rows = [];
    for (int i = 0; i < categories.length; i += 4) {
      rows.add(categories.sublist(i, math.min(i + 4, categories.length)));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.sectionShopByCategory,
            style: TextStyle(
              fontSize: 20.0 * s,
              fontWeight: FontWeight.w800,
              color: tokens.heading,
            ),
          ),
          SizedBox(height: 12.0 * s),
          for (final row in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < 4; i++) ...[
                  if (i > 0) SizedBox(width: 12.0 * s),
                  if (i < row.length)
                    Expanded(
                      child: InkWell(
                        onTap: () => onSelectCategory(row[i].slug),
                        borderRadius: BorderRadius.circular(16.0 * s),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tokens.chipBg,
                                  borderRadius: BorderRadius.circular(16.0 * s),
                                ),
                                padding: EdgeInsets.all(8.0 * s),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0 * s),
                                  child: Image.asset(
                                    getCatImage(row[i].slug),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.eco_outlined,
                                          size: 24.0 * s,
                                          color: tokens.primaryGreen.withValues(alpha: 0.6),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 6.0 * s),
                            Text(
                              strings.categoryLabel(row[i].slug),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5 * s,
                                fontWeight: FontWeight.w600,
                                color: tokens.heading,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
            SizedBox(height: 12.0 * s),
          ],
        ],
      ),
    );
  }
}
