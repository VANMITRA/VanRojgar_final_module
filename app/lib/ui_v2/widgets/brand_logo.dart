import 'package:flutter/material.dart';
import '../theme/van_rozgar_tokens.dart';

/// The round VanMitra logo (assets/brand/vanmitra_logo.png). If the file is missing it falls back to a
/// leaf icon, so nothing crashes.
class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Semantics(
      image: true,
      label: 'VanMitra',
      child: ExcludeSemantics(
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              'assets/brand/vanmitra_logo.png',
              fit: BoxFit.cover,
              cacheWidth: px,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.eco, size: size * 0.8, color: tokens.heading),
            ),
          ),
        ),
      ),
    );
  }
}
