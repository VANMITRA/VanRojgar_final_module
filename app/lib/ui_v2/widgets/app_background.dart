import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/van_rozgar_tokens.dart';

/// Readability veil alpha opacity in light mode. Tune here.
const double backgroundVeilAlphaLight = 0.45;

/// Readability veil alpha opacity in dark mode. Tune here.
const double backgroundVeilAlphaDark = 0.35;

/// Reusable full-screen visual background widget for VanRozgar.
///
/// Features:
/// - Flat page colour base layer (light #F7F2E8, dark #1C2619).
/// - Full-screen background artwork aligned at bottomCenter (assets/backgrounds/bg_full_{light,dark}.jpg).
/// - Graceful errorBuilder fallback to flat page colour if image asset is missing (no crash or broken icon).
/// - Central readability veil gradient with configurable alpha opacity.
/// - Smooth 300ms implicit cross-fade category tint gradient from top of screen.
/// - RepaintBoundary wrapping for optimal rendering performance across devices.
class AppBackground extends StatelessWidget {
  final Widget child;
  final String? categorySlug;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.categorySlug = 'all',
    this.useSafeArea = false,
  });

  /// Precaches the full-screen background artwork assets to prevent flash during theme switching.
  static Future<void> precacheArtwork(BuildContext context) async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(VanRozgarTokens.backgroundFullLightAsset), context),
        precacheImage(const AssetImage(VanRozgarTokens.backgroundFullDarkAsset), context),
      ]);
    } catch (_) {
      // Missing assets fall back safely to flat colour layer without crashing
    }
  }

  /// Determines tint color based on category slug and theme brightness.
  static Color _getTintColor(String? slug, VanRozgarColorTokens tokens, bool isDark) {
    switch (slug) {
      case 'fruit':
      case 'flowers':
        // Orange glow only
        return tokens.orange;
      case 'nuts-and-seeds':
      case 'timber-trees':
        // Brown in light, tan in dark
        return tokens.outlinedControl;
      case 'medicinal-plants':
      case 'shade-trees':
        // Heading green
        return isDark ? tokens.primaryGreen : tokens.heading;
      case 'handicrafts-bamboo':
      case 'forest-produce':
      case 'all':
      default:
        // Primary green
        return tokens.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    final targetTintColor = _getTintColor(categorySlug, tokens, isDark);
    final topPadding = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final tintHeight = math.max(150.0 + topPadding, 0.24 * screenHeight);
    final veilAlpha = isDark ? backgroundVeilAlphaDark : backgroundVeilAlphaLight;

    Widget content = child;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Static background layers wrapped in RepaintBoundary
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer (a): Flat page colour base
              Container(color: tokens.page),

              // Layer (b): Full-screen background artwork aligned at bottomCenter
              Positioned.fill(
                child: Image.asset(
                  isDark
                      ? VanRozgarTokens.backgroundFullDarkAsset
                      : VanRozgarTokens.backgroundFullLightAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  height: double.infinity,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Layer (c): Readability veil
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.22, 0.30, 0.62, 0.85, 1.0],
                        colors: [
                          tokens.page.withValues(alpha: 0.0),
                          tokens.page.withValues(alpha: 0.0),
                          tokens.page.withValues(alpha: veilAlpha),
                          tokens.page.withValues(alpha: veilAlpha),
                          tokens.page.withValues(alpha: 0.0),
                          tokens.page.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Layer (d): Category tint gradient with 300ms implicit cross-fade
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: tintHeight,
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: ColorTween(begin: targetTintColor, end: targetTintColor),
                  builder: (context, animatedColor, _) {
                    final color = animatedColor ?? targetTintColor;
                    return Container(
                      height: tintHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.7, 1.0],
                          colors: [
                            color.withValues(alpha: 0.25),
                            color.withValues(alpha: 0.08),
                            color.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Foreground content
        content,
      ],
    );
  }
}
