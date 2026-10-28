import 'package:flutter/material.dart';
import '../theme/van_rozgar_tokens.dart';

/// Reusable full-screen visual background widget for VanRozgar Phase 1.
///
/// Features:
/// - Flat page colour layer (light #F7F2E8, dark #1C2619).
/// - Header artwork aligned at the top (assets/backgrounds/header_{light,dark}.png).
/// - Graceful errorBuilder fallback to flat page colour if image is missing.
/// - Smooth 300ms implicit cross-fade category tint gradient over header only.
/// - RepaintBoundary for optimal rendering performance on low-end devices.
class AppBackground extends StatelessWidget {
  final Widget child;
  final String? categorySlug;
  final double headerHeight;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.categorySlug = 'all',
    this.headerHeight = 220.0,
    this.useSafeArea = false,
  });

  /// Precaches both header artwork assets to prevent flash during theme switching.
  static Future<void> precacheArtwork(BuildContext context) async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(VanRozgarTokens.headerLightAsset), context),
        precacheImage(const AssetImage(VanRozgarTokens.headerDarkAsset), context),
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
    final headerAsset = isDark ? VanRozgarTokens.headerDarkAsset : VanRozgarTokens.headerLightAsset;

    Widget content = child;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1 & 2: Static background layers wrapped in RepaintBoundary
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Flat page colour base
              Container(color: tokens.page),

              // Layer 2: Header artwork aligned at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: Image.asset(
                  headerAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: headerHeight,
                  alignment: Alignment.topCenter,
                  // If asset is missing, show plain page-colour layer: no crash, no broken-image icon
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Layer 3: Category tint with 300ms implicit cross-fade
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tween: ColorTween(begin: targetTintColor, end: targetTintColor),
                  builder: (context, animatedColor, _) {
                    final color = animatedColor ?? targetTintColor;
                    return Container(
                      height: headerHeight,
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
