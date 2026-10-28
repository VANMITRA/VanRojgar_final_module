import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';

/// The floating "View cart" pill that hovers above the bottom navigation while the cart is not empty.
///
/// It first appears as a CIRCLE (the picture of the last added product), then grows into a rounded
/// pill with the text "View cart / N items" and a chevron. When the cart becomes empty it shrinks
/// back to the circle and disappears. With "reduce motion" on it just appears and disappears.
class FloatingCartPill extends ConsumerStatefulWidget {
  const FloatingCartPill({super.key});

  @override
  ConsumerState<FloatingCartPill> createState() => _FloatingCartPillState();
}

class _FloatingCartPillState extends ConsumerState<FloatingCartPill>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  // Kept while the pill shrinks away, so its text does not jump to "0 items"
  int _lastCount = 0;
  String? _lastImage;

  @override
  void initState() {
    super.initState();
    // The keyboard opening is not visible through the MediaQuery of the Scaffold body, so listen to the metrics
    WidgetsBinding.instance.addObserver(this);
    _lastCount = ref.read(cartItemCountProvider);
    _lastImage = ref.read(lastAddedImageProvider);
    if (_lastCount > 0) _grow.value = 1.0;
    // When the shrink animation ends, rebuild once so the pill is removed from the tree
    _grow.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) setState(() {});
    });
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _grow.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Brings the grow animation in line with the cart count. Called after every build, so it also
  /// works when the count changed while another page (for example the Cart page) covered the shell.
  void _sync(int count, bool reduceMotion) {
    if (!mounted) return;
    if (count > 0) {
      if (_grow.status != AnimationStatus.forward && _grow.value < 1.0) {
        reduceMotion ? _grow.value = 1.0 : _grow.forward();
      }
    } else {
      if (_grow.status != AnimationStatus.reverse && _grow.value > 0.0) {
        reduceMotion ? _grow.value = 0.0 : _grow.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // A short pulse when another product is added or the count changes while the pill is showing
    ref.listen<int>(cartItemCountProvider, (previous, next) {
      if (next > 0 && (previous ?? 0) > 0 && !MediaQuery.disableAnimationsOf(context)) {
        _pulse.forward(from: 0.0);
      }
    });
    ref.listen<String?>(lastAddedImageProvider, (previous, next) {
      if (next != null && next != previous && _grow.value > 0 && !MediaQuery.disableAnimationsOf(context)) {
        _pulse.forward(from: 0.0);
      }
    });

    final count = ref.watch(cartItemCountProvider);
    final image = ref.watch(lastAddedImageProvider);
    if (count > 0) {
      _lastCount = count;
      _lastImage = image ?? _lastImage;
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync(count, reduceMotion));

    // The Scaffold removes the keyboard from the MediaQuery its body sees, so read the real value
    // from the view. Reading the MediaQuery inset too makes this widget rebuild when it changes.
    MediaQuery.viewInsetsOf(context);
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;

    // Nothing in the cart and fully shrunk: draw nothing. Also hidden while the keyboard is open.
    if ((count == 0 && _grow.isDismissed) || keyboardOpen) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final s = (screenWidth / 360.0).clamp(0.85, 1.25);
    final double circle = 52.0 * s;
    final double pillWidth = (0.52 * screenWidth).clamp(176.0, 240.0);
    final double thumb = 36.0 * s;
    final double chip = 36.0 * s;

    return AnimatedBuilder(
      animation: Listenable.merge([_grow, _pulse]),
      builder: (context, _) {
        final t = _grow.value;
        final scaleT = const Interval(0.0, 0.35, curve: Curves.easeOutBack).transform(t);
        final widthT = const Interval(0.30, 1.0, curve: Curves.easeOutCubic).transform(t);
        final contentT = const Interval(0.65, 1.0).transform(t);
        final pulseScale = 1.0 + 0.06 * math.sin(math.pi * _pulse.value);
        final double width = lerpDouble(circle, pillWidth, widthT)!;
        final double thumbLeft = lerpDouble((width - thumb) / 2.0, 8.0 * s, widthT)!;

        return Transform.scale(
          scale: scaleT * pulseScale,
          child: Semantics(
            button: true,
            label: strings.cartSemantic(_lastCount),
            child: Material(
              color: tokens.primaryGreen,
              elevation: 6.0,
              shadowColor: Colors.black.withValues(alpha: 0.5),
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => GoRouter.maybeOf(context)?.push('/cart'),
                child: SizedBox(
                  key: const Key('floating_cart_pill'),
                  width: width,
                  height: circle,
                  child: Stack(
                    children: [
                      // The round product picture (centred in the circle, then moves to the left end)
                      Positioned(
                        left: thumbLeft,
                        top: (circle - thumb) / 2.0,
                        child: Container(
                          width: thumb,
                          height: thumb,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: VanRozgarTokens.picturePanel,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _lastImage == null
                              ? Icon(Icons.eco_outlined, size: thumb * 0.5, color: tokens.primaryGreen)
                              : Image.asset(
                                  _lastImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.eco_outlined,
                                    size: thumb * 0.5,
                                    color: tokens.primaryGreen,
                                  ),
                                ),
                        ),
                      ),
                      // "View cart" and "N items"
                      Positioned(
                        left: 8.0 * s + thumb + 10.0 * s,
                        right: 8.0 * s + chip + 6.0 * s,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: contentT,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.viewCart,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 16.0 * s,
                                    fontWeight: FontWeight.w800,
                                    color: tokens.onPrimaryGreen,
                                    height: 1.1,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 150),
                                  child: Text(
                                    strings.cartItems(_lastCount),
                                    key: ValueKey<int>(_lastCount),
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 12.0 * s,
                                      fontWeight: FontWeight.w600,
                                      color: tokens.onPrimaryGreen.withValues(alpha: 0.85),
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Round chevron chip
                      Positioned(
                        right: 8.0 * s,
                        top: (circle - chip) / 2.0,
                        child: Opacity(
                          opacity: contentT,
                          child: Container(
                            width: chip,
                            height: chip,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.18),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              size: 22.0 * s,
                              color: tokens.onPrimaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
