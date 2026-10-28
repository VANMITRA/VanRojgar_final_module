import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';
import '../theme/van_rozgar_tokens.dart';

/// Hero Banner PageView section with 2 rotating banners matching Phase 3 specs.
class HomeHeroBanner extends StatefulWidget {
  final List<ShopProduct> topDeals;
  final AppLanguage language;
  final VoidCallback onCtaTap;

  const HomeHeroBanner({
    super.key,
    required this.topDeals,
    required this.language,
    required this.onCtaTap,
  });

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildProductThumbnail(String assetPath, double size, double rotationDeg, VanRozgarColorTokens tokens) {
    return Transform.rotate(
      angle: rotationDeg * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: VanRozgarTokens.picturePanel,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.eco_outlined,
                size: size * 0.4,
                color: tokens.primaryGreen.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final s = (screenWidth / 360.0).clamp(0.85, 1.25);

    // Banner 1 pictures
    const banner1Pictures = [
      'assets/catalog/bamboo.jpg',
      'assets/catalog/fruit_mango.jpg',
      'assets/catalog/fruit_awla.jpg',
    ];

    // Banner 2 pictures: up to 3 best discount products
    final banner2Pictures = widget.topDeals.take(3).map((p) => p.imageAsset).toList();
    while (banner2Pictures.length < 3) {
      banner2Pictures.add('assets/catalog/fruit_mango.jpg');
    }

    final int bestDiscount = widget.topDeals.isNotEmpty
        ? widget.topDeals.first.bestDiscountPercent
        : 25;

    // The banner height follows the text (3-line headline, 2-line subtitle, button), so longer
    // Hindi / Marathi text or a bigger system font never overflows. 150 s is the minimum.
    final textScaler = MediaQuery.textScalerOf(context);
    final baseStyle = DefaultTextStyle.of(context).style;
    final textColumnWidth = math.max(40.0, (screenWidth - 32.0 * s) * 0.58 - 20.0 * s);
    double measure(String text, TextStyle style, int maxLines) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: baseStyle.merge(style)),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: maxLines,
      )..layout(maxWidth: textColumnWidth);
      return painter.height;
    }

    double neededHeight(String eyebrow, String title, String subtitle) {
      final chip = measure(
            eyebrow,
            TextStyle(fontSize: 10.5 * s, fontWeight: FontWeight.w700, letterSpacing: 0.8),
            1,
          ) +
          5.0 * s;
      final head = measure(
        title,
        TextStyle(fontSize: 18.0 * s, fontWeight: FontWeight.w800, height: 1.1),
        3,
      );
      final sub = measure(subtitle, TextStyle(fontSize: 12.0 * s), 2);
      return 24.0 * s + chip + head + sub + 36.0 * s + 3 * 6.0 * s;
    }

    final bannerHeight = math.max(
      150.0 * s,
      math.max(
        neededHeight(strings.heroEyebrow1, strings.heroTitle1, strings.heroSubtitle1),
        neededHeight(strings.heroEyebrow2, strings.heroTitle2(bestDiscount), strings.heroSubtitle2),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              // Banner 1
              _buildBannerCard(
                s: s,
                tokens: tokens,
                eyebrow: strings.heroEyebrow1,
                title: strings.heroTitle1,
                subtitle: strings.heroSubtitle1,
                ctaText: strings.heroCta1,
                pictureAssets: banner1Pictures,
              ),
              // Banner 2
              _buildBannerCard(
                s: s,
                tokens: tokens,
                eyebrow: strings.heroEyebrow2,
                title: strings.heroTitle2(bestDiscount),
                subtitle: strings.heroSubtitle2,
                ctaText: strings.heroCta2,
                pictureAssets: banner2Pictures,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0 * s),
        // Pager dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 2; i++) ...[
              if (i > 0) SizedBox(width: 4.0 * s),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentPage == i ? 14.0 * s : 6.0 * s,
                height: 6.0 * s,
                decoration: BoxDecoration(
                  color: _currentPage == i ? tokens.primaryGreen : tokens.borders,
                  borderRadius: BorderRadius.circular(3.0 * s),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCard({
    required double s,
    required VanRozgarColorTokens tokens,
    required String eyebrow,
    required String title,
    required String subtitle,
    required String ctaText,
    required List<String> pictureAssets,
  }) {
    final thumbSize = 76.0 * s;
    final overlap = 18.0 * s;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0 * s),
      decoration: BoxDecoration(
        color: tokens.chipBg,
        borderRadius: BorderRadius.circular(24.0 * s),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            children: [
              // Left 58%
              Expanded(
                flex: 58,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0 * s, 12.0 * s, 4.0 * s, 12.0 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Eyebrow chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0 * s,
                          vertical: 2.5 * s,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text(
                          eyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5 * s,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.mutedText,
                          ),
                        ),
                      ),
                      // Headline
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.0 * s,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: tokens.heading,
                        ),
                      ),
                      // Subtitle
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0 * s,
                          color: tokens.mutedText,
                        ),
                      ),
                      // CTA Button Pill
                      InkWell(
                        onTap: widget.onCtaTap,
                        borderRadius: BorderRadius.circular(100.0),
                        child: Container(
                          height: 36.0 * s,
                          padding: EdgeInsets.only(left: 14.0 * s, right: 6.0 * s),
                          decoration: BoxDecoration(
                            color: tokens.card,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                ctaText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.0 * s,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.primaryGreen,
                                ),
                                ),
                              ),
                              SizedBox(width: 8.0 * s),
                              Container(
                                width: 24.0 * s,
                                height: 24.0 * s,
                                decoration: BoxDecoration(
                                  color: tokens.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 14.0 * s,
                                  color: Colors.white,
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

              // Right 42%
              Expanded(
                flex: 42,
                child: SizedBox(
                  height: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Picture 1 (-6 deg)
                      Positioned(
                        top: 20.0 * s,
                        right: 12.0 * s + (2 * overlap),
                        child: _buildProductThumbnail(pictureAssets[0], thumbSize, -6.0, tokens),
                      ),
                      // Picture 2 (+4 deg)
                      Positioned(
                        top: 36.0 * s,
                        right: 12.0 * s + overlap,
                        child: _buildProductThumbnail(pictureAssets[1], thumbSize, 4.0, tokens),
                      ),
                      // Picture 3 (-3 deg)
                      Positioned(
                        top: 14.0 * s,
                        right: 12.0 * s,
                        child: _buildProductThumbnail(pictureAssets[2], thumbSize, -3.0, tokens),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
