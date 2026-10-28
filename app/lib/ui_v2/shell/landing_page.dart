import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import 'app_shell.dart';
import 'landing_geometry.dart';

/// The pixel-accurate VanRozgar Landing (onboarding) Page with custom rounded-quadrilateral
/// image cards, overlapping text, handwritten note accents, and fixed controls.
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishLanding() {
    uiV2LandingSeen.value = true;
    if (mounted) {
      context.go('/');
    }
  }

  void _handleNext() {
    if (_currentPage < 2) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _pageController.jumpToPage(_currentPage + 1);
      } else {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _finishLanding();
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _pageController.jumpToPage(_currentPage - 1);
      } else {
        _pageController.animateToPage(
          _currentPage - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    final mediaQuery = MediaQuery.of(context);
    final W = mediaQuery.size.width;
    final H = mediaQuery.size.height;
    final d = math.min(W, H / 2.2);
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;

    // Ink color: near-black #1A1D16 in light mode, cream (tokens.heading) in dark mode
    final inkColor = isDark ? tokens.heading : const Color(0xFF1A1D16);

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.page,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Swipeable Slide Content (PageView)
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Slide 1: Mirrored (Pictures LEFT, Text RIGHT)
                _LandingSlideView(
                  isMirrored: true,
                  eyebrow: strings.landingSlide1Eyebrow,
                  headlineLines: strings.landingSlide1HeadlineLines,
                  highlightIndex: strings.landingSlide1HighlightIndex,
                  subtitle: strings.landingSlide1Subtitle,
                  noteLines: strings.landingSlide1NoteLines,
                  pictureLabel: strings.landingSlide1PictureLabel,
                  topAsset: VanRozgarTokens.landingSlide1Top,
                  bottomAsset: VanRozgarTokens.landingSlide1Bottom,
                  W: W,
                  H: H,
                  d: d,
                  language: language,
                  tokens: tokens,
                  inkColor: inkColor,
                ),

                // Slide 2: Reference (Pictures RIGHT, Text LEFT)
                _LandingSlideView(
                  isMirrored: false,
                  eyebrow: strings.landingSlide2Eyebrow,
                  headlineLines: strings.landingSlide2HeadlineLines,
                  highlightIndex: strings.landingSlide2HighlightIndex,
                  subtitle: strings.landingSlide2Subtitle,
                  noteLines: strings.landingSlide2NoteLines,
                  pictureLabel: strings.landingSlide2PictureLabel,
                  topAsset: VanRozgarTokens.landingSlide2Top,
                  bottomAsset: VanRozgarTokens.landingSlide2Bottom,
                  W: W,
                  H: H,
                  d: d,
                  language: language,
                  tokens: tokens,
                  inkColor: inkColor,
                ),

                // Slide 3: Mirrored (Pictures LEFT, Text RIGHT)
                _LandingSlideView(
                  isMirrored: true,
                  eyebrow: strings.landingSlide3Eyebrow,
                  headlineLines: strings.landingSlide3HeadlineLines,
                  highlightIndex: strings.landingSlide3HighlightIndex,
                  subtitle: strings.landingSlide3Subtitle,
                  noteLines: strings.landingSlide3NoteLines,
                  pictureLabel: strings.landingSlide3PictureLabel,
                  topAsset: VanRozgarTokens.landingSlide3Top,
                  bottomAsset: VanRozgarTokens.landingSlide3Bottom,
                  W: W,
                  H: H,
                  d: d,
                  language: language,
                  tokens: tokens,
                  inkColor: inkColor,
                ),
              ],
            ),

            // 2. Fixed Top Bar (Logo left, Language Chips center, Skip right)
            _buildFixedTopBar(
              context: context,
              W: W,
              H: H,
              d: d,
              safeTop: safeTop,
              currentLanguage: language,
              strings: strings,
              tokens: tokens,
              inkColor: inkColor,
            ),

            // 3. Fixed Bottom Bar (Dots left, Action button right)
            _buildFixedBottomBar(
              context: context,
              W: W,
              H: H,
              d: d,
              safeBottom: safeBottom,
              strings: strings,
              tokens: tokens,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTopBar({
    required BuildContext context,
    required double W,
    required double H,
    required double d,
    required double safeTop,
    required AppLanguage currentLanguage,
    required AppStrings strings,
    required VanRozgarColorTokens tokens,
    required Color inkColor,
  }) {
    // Vertically centred at v = 0.098 * H, but never above safeTop + 28 dp
    final topBarCenterY = math.max(0.098 * H, safeTop + 28.0);
    const topBarHeight = VanRozgarTokens.minTouchTarget;
    final topBarTop = topBarCenterY - (topBarHeight / 2.0);

    return Positioned(
      top: topBarTop,
      left: 0.082 * W,
      right: (1.0 - 0.935) * W,
      height: topBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Leaf icon + App name
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    size: 0.07 * d,
                    color: tokens.heading,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    strings.appNameNative,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: VanRozgarTokens.fontFamily,
                      fontSize: 0.064 * d,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.02 * (0.064 * d),
                      color: inkColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8.0),

          // Middle: Three tiny language chips (EN, हिं, मरा)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguage.values.map((lang) {
              final isSelected = lang == currentLanguage;
              final label = AppStrings.shortLanguageLabel(lang);

              return Semantics(
                button: true,
                selected: isSelected,
                label: lang.nativeLabel,
                child: InkWell(
                  onTap: () {
                    ref.read(uiV2LanguageProvider.notifier).state = lang;
                  },
                  borderRadius: VanRozgarTokens.borderPill,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48.0,
                      minHeight: 48.0,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: VanRozgarTokens.fontFamily,
                            fontSize: 0.033 * d,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? tokens.primaryGreen : tokens.mutedText,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Container(
                          width: 14.0,
                          height: 2.0,
                          color: isSelected ? tokens.primaryGreen : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(width: 4.0),

          // Right: Skip button
          Semantics(
            button: true,
            label: strings.landingSkip,
            child: InkWell(
              onTap: _finishLanding,
              borderRadius: VanRozgarTokens.borderPill,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
                alignment: Alignment.centerRight,
                child: Text(
                  strings.landingSkip,
                  style: TextStyle(
                    fontFamily: VanRozgarTokens.fontFamily,
                    fontSize: 0.036 * d,
                    fontWeight: FontWeight.w600,
                    color: tokens.mutedText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedBottomBar({
    required BuildContext context,
    required double W,
    required double H,
    required double d,
    required double safeBottom,
    required AppStrings strings,
    required VanRozgarColorTokens tokens,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final buttonHeight = 0.15 * d;
    final maxBottomPos = H - safeBottom - 12.0 - buttonHeight;
    final preferredTop = 0.923 * H - (buttonHeight / 2.0);
    final buttonTop = math.min(preferredTop, maxBottomPos);

    final isLastSlide = _currentPage == 2;
    final buttonLabel = isLastSlide ? strings.landingGetStarted : strings.landingNext;

    final buttonFill = isDark ? tokens.primaryGreen : tokens.heading;
    final buttonTextColor = isDark ? tokens.onPrimaryGreen : Colors.white;

    return Positioned(
      top: buttonTop,
      left: 0.0,
      right: 0.0,
      height: buttonHeight,
      child: Stack(
        children: [
          // Dots on the left: left edge u = 0.065 * W
          Positioned(
            left: 0.065 * W,
            top: 0.0,
            bottom: 0.0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final isActive = index == _currentPage;
                  return Semantics(
                    label: strings.landingSlideDotLabel(index + 1, 3),
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 13.0 : 0.0),
                      width: isActive ? 18.0 : 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: isActive ? tokens.primaryGreen : tokens.borders,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Button on the right: left edge u = 0.42 * W, right edge u = 0.939 * W
          Positioned(
            left: 0.42 * W,
            right: (1.0 - 0.939) * W,
            top: 0.0,
            bottom: 0.0,
            child: Semantics(
              button: true,
              label: buttonLabel,
              child: InkWell(
                onTap: _handleNext,
                borderRadius: BorderRadius.circular(0.033 * W),
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: buttonFill,
                    borderRadius: BorderRadius.circular(0.033 * W),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        buttonLabel,
                        style: TextStyle(
                          fontFamily: VanRozgarTokens.fontFamily,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 24.0),
                      Icon(
                        Icons.east,
                        size: 22.0,
                        color: buttonTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-screen slide containing background blobs, rounded quadrilateral picture cards,
/// text block, and handwritten note.
class _LandingSlideView extends StatelessWidget {
  final bool isMirrored;
  final String eyebrow;
  final List<String> headlineLines;
  final int highlightIndex;
  final String subtitle;
  final List<String> noteLines;
  final String pictureLabel;
  final String topAsset;
  final String bottomAsset;
  final double W;
  final double H;
  final double d;
  final AppLanguage language;
  final VanRozgarColorTokens tokens;
  final Color inkColor;

  const _LandingSlideView({
    required this.isMirrored,
    required this.eyebrow,
    required this.headlineLines,
    required this.highlightIndex,
    required this.subtitle,
    required this.noteLines,
    required this.pictureLabel,
    required this.topAsset,
    required this.bottomAsset,
    required this.W,
    required this.H,
    required this.d,
    required this.language,
    required this.tokens,
    required this.inkColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Polygons
    final card1Poly = LandingGeometry.getCard1(mirrored: isMirrored);
    final card2Poly = LandingGeometry.getCard2(mirrored: isMirrored);
    final blobAPoly = LandingGeometry.getBlobA(mirrored: isMirrored);
    final blobBPoly = LandingGeometry.getBlobB(mirrored: isMirrored);

    final card1Rect = card1Poly.absoluteBounds(W, H);
    final card2Rect = card2Poly.absoluteBounds(W, H);
    final blobARect = blobAPoly.absoluteBounds(W, H);
    final blobBRect = blobBPoly.absoluteBounds(W, H);

    final cardRadius = 0.058 * d;
    final blobRadius = 0.09 * d;

    final blobColor = tokens.chipBg.withValues(alpha: isDark ? 0.50 : 0.75);

    // Headline auto-fit calculation:
    // If the widest line is wider than 0.50 * W, reduce font size until it fits (minimum 24 sp)
    double headlineFontSize = math.min(0.16 * W, 0.073 * H);
    final maxAllowedWidth = 0.50 * W;

    for (int step = 0; step < 50; step++) {
      double maxLineWidth = 0.0;
      for (final line in headlineLines) {
        final painter = TextPainter(
          text: TextSpan(
            text: line,
            style: TextStyle(
              fontFamily: VanRozgarTokens.fontFamily,
              fontSize: headlineFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.03 * headlineFontSize,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        if (painter.width > maxLineWidth) {
          maxLineWidth = painter.width;
        }
      }
      if (maxLineWidth <= maxAllowedWidth || headlineFontSize <= 24.0) {
        break;
      }
      headlineFontSize = math.max(24.0, headlineFontSize - 1.0);
    }

    final eyebrowFontSize = 0.034 * d;
    final isDevanagari = language == AppLanguage.hi || language == AppLanguage.mr;

    return Semantics(
      label: pictureLabel,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Blob A (behind Card 1)
          Positioned.fromRect(
            rect: blobARect,
            child: ClipPath(
              clipper: _PolygonClipper(
                points: blobAPoly.toAbsolute(W, H).map((p) => p - blobARect.topLeft).toList(),
                radius: blobRadius,
              ),
              child: Container(color: blobColor),
            ),
          ),

          // 2. Blob B (behind Card 2)
          Positioned.fromRect(
            rect: blobBRect,
            child: ClipPath(
              clipper: _PolygonClipper(
                points: blobBPoly.toAbsolute(W, H).map((p) => p - blobBRect.topLeft).toList(),
                radius: blobRadius,
              ),
              child: Container(color: blobColor),
            ),
          ),

          // 3. Picture Card 1 (Top)
          Positioned.fromRect(
            rect: card1Rect,
            child: KeyedSubtree(
              key: const Key('landing_card_top'),
              child: ClipPath(
                clipper: _PolygonClipper(
                  points: card1Poly.toAbsolute(W, H).map((p) => p - card1Rect.topLeft).toList(),
                  radius: cardRadius,
                ),
                child: ExcludeSemantics(
                  child: Image.asset(
                    topAsset,
                    width: card1Rect.width,
                    height: card1Rect.height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackPanel(),
                  ),
                ),
              ),
            ),
          ),

          // 4. Picture Card 2 (Bottom)
          Positioned.fromRect(
            rect: card2Rect,
            child: KeyedSubtree(
              key: const Key('landing_card_bottom'),
              child: ClipPath(
                clipper: _PolygonClipper(
                  points: card2Poly.toAbsolute(W, H).map((p) => p - card2Rect.topLeft).toList(),
                  radius: cardRadius,
                ),
                child: ExcludeSemantics(
                  child: Image.asset(
                    bottomAsset,
                    width: card2Rect.width,
                    height: card2Rect.height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackPanel(),
                  ),
                ),
              ),
            ),
          ),

          // 5. Text Block (Drawn over pictures where they overlap)
          Positioned(
            left: isMirrored ? null : (0.065 * W),
            right: isMirrored ? (0.065 * W) : null,
            top: 0.228 * H,
            child: Column(
              crossAxisAlignment: isMirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // a) Eyebrow
                Text(
                  eyebrow,
                  style: TextStyle(
                    fontFamily: VanRozgarTokens.fontFamily,
                    fontSize: eyebrowFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: isDevanagari ? 0.0 : 0.55 * eyebrowFontSize,
                    color: tokens.mutedText,
                  ),
                ),

                SizedBox(height: math.max(4.0, (0.266 - 0.228) * H - eyebrowFontSize)),

                // b) Headline with tight line height and auto-fitted font size
                KeyedSubtree(
                  key: const Key('landing_headline'),
                  child: Column(
                    crossAxisAlignment: isMirrored ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: headlineLines.asMap().entries.map((entry) {
                      final lineIndex = entry.key;
                      final lineText = entry.value;
                      final isHighlighted = lineIndex == highlightIndex;

                      return Text(
                        lineText,
                        softWrap: false,
                        textAlign: isMirrored ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          fontFamily: VanRozgarTokens.fontFamily,
                          fontSize: headlineFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -0.03 * headlineFontSize,
                          color: isHighlighted ? tokens.primaryGreen : inkColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 0.02 * H),

                // c) Subtitle (max width 0.405 * W so it never touches Card 2)
                KeyedSubtree(
                  key: const Key('landing_subtitle'),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 0.405 * W),
                    child: Text(
                      subtitle,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isMirrored ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                        fontFamily: VanRozgarTokens.fontFamily,
                        fontSize: 0.039 * d,
                        height: 1.38,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Handwritten Note with Underline Stroke
          Positioned(
            left: isMirrored ? null : (0.098 * W),
            right: isMirrored ? (0.098 * W) : null,
            top: 0.723 * H,
            width: 0.196 * W,
            child: KeyedSubtree(
              key: const Key('landing_note'),
              child: Transform.rotate(
                angle: (isMirrored ? 14.0 : -14.0) * math.pi / 180.0,
                child: Text(
                  noteLines.join('\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: isDevanagari ? VanRozgarTokens.fontFamily : 'cursive',
                    fontStyle: FontStyle.italic,
                    fontSize: 0.06 * d,
                    height: 1.15,
                    color: tokens.mutedText,
                  ),
                ),
              ),
            ),
          ),

          // Underline stroke decoration
          CustomPaint(
            painter: _UnderlinePainter(
              mirrored: isMirrored,
              W: W,
              H: H,
              color: tokens.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPanel() {
    return Container(
      color: VanRozgarTokens.picturePanel,
      alignment: Alignment.center,
      child: Icon(
        Icons.eco_outlined,
        size: 28.0,
        color: VanRozgarTokens.lightHeadingGreen.withValues(alpha: 0.6),
      ),
    );
  }
}

/// CustomClipper that clips child to a rounded polygon using LandingGeometry.
class _PolygonClipper extends CustomClipper<Path> {
  final List<Offset> points;
  final double radius;

  _PolygonClipper({required this.points, required this.radius});

  @override
  Path getClip(Size size) {
    return LandingGeometry.roundPolygon(points, radius);
  }

  @override
  bool shouldReclip(covariant _PolygonClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.points != points;
  }
}

/// CustomPainter for the single handwritten underline stroke.
class _UnderlinePainter extends CustomPainter {
  final bool mirrored;
  final double W;
  final double H;
  final Color color;

  _UnderlinePainter({
    required this.mirrored,
    required this.W,
    required this.H,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.008 * W
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Offset p1;
    final Offset p2;

    if (mirrored) {
      p1 = Offset((1.0 - 0.216) * W, 0.832 * H);
      p2 = Offset((1.0 - 0.290) * W, 0.814 * H);
    } else {
      p1 = Offset(0.216 * W, 0.832 * H);
      p2 = Offset(0.290 * W, 0.814 * H);
    }

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant _UnderlinePainter oldDelegate) {
    return oldDelegate.mirrored != mirrored ||
        oldDelegate.W != W ||
        oldDelegate.H != H ||
        oldDelegate.color != color;
  }
}
