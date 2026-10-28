import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import 'product_card.dart';

class _DealTabInfo {
  final String key;
  final String label;
  final String imageAsset;
  final int startingPrice;
  final int maxDiscount;
  final List<ShopProduct> products;

  const _DealTabInfo({
    required this.key,
    required this.label,
    required this.imageAsset,
    required this.startingPrice,
    required this.maxDiscount,
    required this.products,
  });
}

/// Top Deals section with custom folder-style category tab strip and horizontal product card row.
class HomeTopDealsSection extends ConsumerStatefulWidget {
  final List<ShopProduct> topDeals;
  final bool showTabs;
  final VoidCallback onSeeAllProducts;

  const HomeTopDealsSection({
    super.key,
    required this.topDeals,
    this.showTabs = true,
    required this.onSeeAllProducts,
  });

  @override
  ConsumerState<HomeTopDealsSection> createState() => _HomeTopDealsSectionState();
}

class _HomeTopDealsSectionState extends ConsumerState<HomeTopDealsSection> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.topDeals.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final s = (screenWidth / 360.0).clamp(0.85, 1.25);
    final cardWidth = (0.40 * screenWidth).clamp(140.0, 190.0);

    // If showTabs is false (category page view), just show title and horizontal list
    if (!widget.showTabs) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
            child: Text(
              strings.sectionTopDeals,
              style: TextStyle(
                fontSize: 20.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
              ),
            ),
          ),
          SizedBox(height: 12.0 * s),
          // Height follows the tallest card; the cards in the row are equally tall.
          RepaintBoundary(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < widget.topDeals.length; i++) ...[
                      if (i > 0) SizedBox(width: 12.0 * s),
                      SizedBox(
                        width: cardWidth,
                        child: ProductCard(
                          product: widget.topDeals[i],
                          cardType: ProductCardType.topDeal,
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

    // Build tabs:
    // Tab 0 is all top deals
    final tabs = <_DealTabInfo>[];

    final int allMinPrice = widget.topDeals
        .map((p) => p.startingAtPaise)
        .reduce((a, b) => a < b ? a : b);
    final int allMaxDiscount = widget.topDeals
        .map((p) => p.bestDiscountPercent)
        .reduce((a, b) => a > b ? a : b);

    tabs.add(
      _DealTabInfo(
        key: 'all',
        label: strings.sectionTopDeals,
        imageAsset: widget.topDeals.first.imageAsset,
        startingPrice: allMinPrice,
        maxDiscount: allMaxDiscount,
        products: widget.topDeals,
      ),
    );

    // Group remaining deals by category, up to 3 categories sorted by best discount
    final Map<String, List<ShopProduct>> catMap = {};
    for (final p in widget.topDeals) {
      catMap.putIfAbsent(p.categorySlug, () => []).add(p);
    }

    final sortedCatEntries = catMap.entries.toList()
      ..sort((a, b) {
        final maxA = a.value.map((p) => p.bestDiscountPercent).reduce((x, y) => x > y ? x : y);
        final maxB = b.value.map((p) => p.bestDiscountPercent).reduce((x, y) => x > y ? x : y);
        return maxB.compareTo(maxA);
      });

    for (final entry in sortedCatEntries.take(3)) {
      final list = entry.value;
      final minP = list.map((p) => p.startingAtPaise).reduce((x, y) => x < y ? x : y);
      final maxD = list.map((p) => p.bestDiscountPercent).reduce((x, y) => x > y ? x : y);
      tabs.add(
        _DealTabInfo(
          key: entry.key,
          label: strings.categoryLabel(entry.key),
          imageAsset: list.first.imageAsset,
          startingPrice: minP,
          maxDiscount: maxD,
          products: list,
        ),
      );
    }

    final activeIndex = _selectedTabIndex < tabs.length ? _selectedTabIndex : 0;
    final activeTab = tabs[activeIndex];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Title
          Text(
            strings.sectionTopDeals,
            style: TextStyle(
              fontSize: 20.0 * s,
              fontWeight: FontWeight.w800,
              color: tokens.heading,
            ),
          ),
          SizedBox(height: 12.0 * s),

          // Horizontal Folder Tabs Strip (height 84 s)
          SizedBox(
            height: 84.0 * s,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.0 * s),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = index == activeIndex;
                final tabWidth = 112.0 * s;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0 * s),
                    topRight: Radius.circular(16.0 * s),
                  ),
                  child: Container(
                    width: tabWidth,
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.card : tokens.chipBg.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0 * s),
                        topRight: Radius.circular(16.0 * s),
                      ),
                      border: Border.all(color: tokens.borders, width: 1.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Top label strip (height 20 s)
                        Container(
                          height: 20.0 * s,
                          width: double.infinity,
                          color: isSelected ? tokens.heading : Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            isSelected
                                ? strings.startingAtTag(formatRupees(tab.startingPrice))
                                : strings.upToOffTag(tab.maxDiscount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.0 * s,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : tokens.primaryGreen,
                            ),
                          ),
                        ),
                        // Tab body (height 64 s)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0 * s),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.0 * s,
                                  height: 36.0 * s,
                                  decoration: BoxDecoration(
                                    color: VanRozgarTokens.picturePanel,
                                    borderRadius: BorderRadius.circular(8.0 * s),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    tab.imageAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.eco_outlined,
                                          size: 18.0 * s,
                                          color: tokens.primaryGreen.withValues(alpha: 0.6),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 6.0 * s),
                                Expanded(
                                  child: Text(
                                    tab.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.0 * s,
                                      fontWeight: FontWeight.w600,
                                      color: tokens.heading,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Container below strip holding horizontal card row + See all products pill
          Container(
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0 * s),
                bottomRight: Radius.circular(16.0 * s),
              ),
              border: Border.all(color: tokens.borders, width: 1.0),
            ),
            padding: EdgeInsets.all(12.0 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < activeTab.products.length; i++) ...[
                            if (i > 0) SizedBox(width: 12.0 * s),
                            SizedBox(
                              width: cardWidth,
                              child: ProductCard(
                                product: activeTab.products[i],
                                cardType: ProductCardType.topDeal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.0 * s),

                // 3.6 "See all products >" Pill
                InkWell(
                  onTap: widget.onSeeAllProducts,
                  borderRadius: BorderRadius.circular(12.0 * s),
                  child: Container(
                    height: 44.0 * s,
                    decoration: BoxDecoration(
                      color: tokens.card,
                      borderRadius: BorderRadius.circular(12.0 * s),
                      border: Border.all(color: tokens.borders, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Up to 3 overlapping round thumbnails
                        SizedBox(
                          width: 48.0 * s,
                          height: 24.0 * s,
                          child: Stack(
                            children: [
                              for (int i = 0; i < math.min(3, widget.topDeals.length); i++)
                                Positioned(
                                  left: i * 12.0 * s,
                                  child: Container(
                                    width: 24.0 * s,
                                    height: 24.0 * s,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      color: VanRozgarTokens.picturePanel,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      widget.topDeals[i].imageAsset,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.eco_outlined, size: 12.0);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0 * s),
                        Flexible(
                          child: Text(
                            strings.seeAllProducts,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0 * s,
                              fontWeight: FontWeight.w700,
                              color: tokens.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.0 * s),
                        Icon(
                          Icons.chevron_right,
                          size: 18.0 * s,
                          color: tokens.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
