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

          // Horizontal Folder Tabs Strip (height 86 s)
          SizedBox(
            height: 86.0 * s,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: tabs.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.0 * s),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = index == activeIndex;
                final tabWidth = 116.0 * s;
                final topRadius = Radius.circular(16.0 * s);

                final stripBg = isSelected ? tokens.primaryGreen : tokens.chipBg;
                final stripFg = isSelected ? tokens.onPrimaryGreen : tokens.chipText;
                final bodyBg = isSelected ? tokens.card : tokens.chipBg;
                final labelFg = isSelected ? tokens.heading : tokens.chipText;

                return Transform.translate(
                  offset: Offset(0.0, isSelected ? 1.5 : 0.0),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: isSelected ? 0.0 : 4.0 * s,
                      bottom: isSelected ? 0.0 : 4.0 * s,
                    ),
                    child: CustomPaint(
                      foregroundPainter: _FolderTabBorderPainter(
                        isSelected: isSelected,
                        hasLeftEar: isSelected && index > 0,
                        hasRightEar: isSelected,
                        fillColor: bodyBg,
                        borderColor: tokens.borders,
                        topRadius: 16.0 * s,
                        earRadius: 10.0 * s,
                      ),
                      child: Material(
                        key: Key('top_deal_tab_$index'),
                        color: bodyBg,
                        borderRadius: BorderRadius.only(
                          topLeft: topRadius,
                          topRight: topRadius,
                          bottomLeft: isSelected ? Radius.zero : Radius.circular(10.0 * s),
                          bottomRight: isSelected ? Radius.zero : Radius.circular(10.0 * s),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                          child: SizedBox(
                            width: tabWidth,
                            child: Column(
                              children: [
                                // Top label strip (height 22 s)
                                Container(
                                  key: Key('top_deal_tab_strip_$index'),
                                  height: 22.0 * s,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 4.0 * s),
                                  color: stripBg,
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isSelected
                                          ? strings.startingAtTag(formatRupees(tab.startingPrice))
                                          : strings.upToOffTag(tab.maxDiscount),
                                      key: Key('top_deal_tab_tag_$index'),
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 11.0 * s,
                                        fontWeight: FontWeight.w700,
                                        color: stripFg,
                                      ),
                                    ),
                                  ),
                                ),
                                // Tab body
                                Expanded(
                                  child: Container(
                                    key: Key('top_deal_tab_body_$index'),
                                    color: bodyBg,
                                    padding: EdgeInsets.symmetric(horizontal: 6.0 * s),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34.0 * s,
                                          height: 34.0 * s,
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
                                            key: Key('top_deal_tab_label_$index'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5 * s,
                                              fontWeight: FontWeight.w700,
                                              color: labelFg,
                                              height: 1.12,
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
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Container below strip holding horizontal card row + See all products pill
          Container(
            key: const Key('top_deals_panel'),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(activeIndex == 0 ? 0.0 : 16.0 * s),
                topRight: Radius.circular(16.0 * s),
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

class _FolderTabBorderPainter extends CustomPainter {
  final bool isSelected;
  final bool hasLeftEar;
  final bool hasRightEar;
  final Color fillColor;
  final Color borderColor;
  final double topRadius;
  final double earRadius;

  const _FolderTabBorderPainter({
    required this.isSelected,
    required this.hasLeftEar,
    required this.hasRightEar,
    required this.fillColor,
    required this.borderColor,
    required this.topRadius,
    required this.earRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (!isSelected) {
      final rrect = RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.circular(topRadius),
        topRight: Radius.circular(topRadius),
        bottomLeft: Radius.circular(earRadius),
        bottomRight: Radius.circular(earRadius),
      );
      canvas.drawRRect(rrect, strokePaint);
      return;
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final r = topRadius;
    final er = earRadius;

    // Outward concave fillets ("folder tab ears") at bottom corners
    if (hasLeftEar) {
      final leftEarPath = Path()
        ..moveTo(-er, h)
        ..quadraticBezierTo(0.0, h, 0.0, h - er)
        ..lineTo(0.0, h)
        ..close();
      canvas.drawPath(leftEarPath, fillPaint);
    }

    if (hasRightEar) {
      final rightEarPath = Path()
        ..moveTo(w, h - er)
        ..quadraticBezierTo(w, h, w + er, h)
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(rightEarPath, fillPaint);
    }

    // Open-bottom folder tab outline that smoothly joins the panel border below
    final borderPath = Path();
    if (hasLeftEar) {
      borderPath.moveTo(-er, h - 1.5);
      borderPath.quadraticBezierTo(0.5, h - 1.5, 0.5, h - er);
    } else {
      borderPath.moveTo(0.5, h);
    }
    borderPath.lineTo(0.5, r);
    borderPath.quadraticBezierTo(0.5, 0.5, r, 0.5);
    borderPath.lineTo(w - r, 0.5);
    borderPath.quadraticBezierTo(w - 0.5, 0.5, w - 0.5, r);
    if (hasRightEar) {
      borderPath.lineTo(w - 0.5, h - er);
      borderPath.quadraticBezierTo(w - 0.5, h - 1.5, w + er, h - 1.5);
    } else {
      borderPath.lineTo(w - 0.5, h);
    }
    canvas.drawPath(borderPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _FolderTabBorderPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.hasLeftEar != hasLeftEar ||
        oldDelegate.hasRightEar != hasRightEar ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.topRadius != topRadius ||
        oldDelegate.earRadius != earRadius;
  }
}
