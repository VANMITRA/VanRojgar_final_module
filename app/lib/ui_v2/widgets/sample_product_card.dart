import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';
import '../theme/van_rozgar_tokens.dart';

/// Reusable sample product card component for the VanRozgar catalog grid.
class SampleProductCard extends StatelessWidget {
  final ProductItem product;
  final AppLanguage language;
  final VoidCallback? onTap;

  const SampleProductCard({
    super.key,
    required this.product,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);

    final title = product.localizedTitle(language);
    final village = product.localizedVillage(language);
    final unit = product.localizedUnit(language);
    final priceStr = product.formattedRupees;

    return Semantics(
      button: true,
      label: '$title, $priceStr ${strings.perUnitPrefix} $unit, $village, ${strings.sampleBadge}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(VanRozgarTokens.space8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Picture Panel: Flat #E4EDCB in BOTH light & dark modes
                AspectRatio(
                  aspectRatio: 1.25,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: VanRozgarTokens.picturePanel,
                      borderRadius: VanRozgarTokens.borderImage,
                    ),
                    child: Stack(
                      children: [
                        // Centred plain label "Sample" (no photo loaded)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                size: 28.0,
                                color: VanRozgarTokens.lightHeadingGreen.withValues(alpha: 0.55),
                              ),
                              const SizedBox(height: VanRozgarTokens.space4),
                              Text(
                                strings.sampleBadge,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: VanRozgarTokens.lightHeadingGreen.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Visible Localised Sample Badge Pill in Top Left
                        Positioned(
                          top: VanRozgarTokens.space8,
                          left: VanRozgarTokens.space8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: VanRozgarTokens.space8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: VanRozgarTokens.white.withValues(alpha: 0.92),
                              borderRadius: VanRozgarTokens.borderPill,
                              border: Border.all(
                                color: VanRozgarTokens.lightBorders,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              strings.sampleBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: VanRozgarTokens.lightHeadingGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: VanRozgarTokens.space8),

                // 2. Village of origin
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 13.0,
                      color: tokens.mutedText,
                    ),
                    const SizedBox(width: 2.0),
                    Expanded(
                      child: Text(
                        village,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tokens.mutedText,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3.0),

                // 3. Localised mock product title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: tokens.heading,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: VanRozgarTokens.space4),

                // 4. Price in Orange in Rupees (calculated from paise integers)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      priceStr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.orange,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    Expanded(
                      child: Text(
                        '/ $unit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
