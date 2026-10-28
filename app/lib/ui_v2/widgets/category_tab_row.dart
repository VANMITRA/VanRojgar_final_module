import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';
import '../theme/van_rozgar_tokens.dart';

/// Horizontally scrollable row of category tabs with accessible touch targets.
class CategoryTabRow extends StatelessWidget {
  final List<CatalogCategory> categories;
  final String selectedSlug;
  final ValueChanged<String> onSelectCategory;
  final AppLanguage language;

  const CategoryTabRow({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelectCategory,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    return SizedBox(
      height: 48.0, // Strict 48px touch target container
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VanRozgarTokens.space16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: VanRozgarTokens.space8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.slug == selectedSlug;
          final label = category.label(language);

          final Color bgColor;
          final Color textColor;
          final BorderSide borderSide;

          if (isSelected) {
            bgColor = tokens.primaryGreen;
            textColor = tokens.onPrimaryGreen;
            borderSide = BorderSide.none;
          } else {
            bgColor = isDark ? tokens.card : tokens.chipBg;
            textColor = isDark ? tokens.bodyText : tokens.heading;
            borderSide = BorderSide(
              color: isDark ? tokens.borders : tokens.borders.withValues(alpha: 0.5),
              width: 1.0,
            );
          }

          return Semantics(
            button: true,
            selected: isSelected,
            label: label,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectCategory(category.slug),
                borderRadius: VanRozgarTokens.borderPill,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: VanRozgarTokens.minTouchTarget,
                    minWidth: VanRozgarTokens.minTouchTarget,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: VanRozgarTokens.space16,
                    vertical: VanRozgarTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: VanRozgarTokens.borderPill,
                    border: Border.fromBorderSide(borderSide),
                    boxShadow: isSelected && !isDark
                        ? [
                            BoxShadow(
                              color: tokens.primaryGreen.withValues(alpha: 0.18),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
