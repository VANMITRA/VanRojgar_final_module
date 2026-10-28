import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/van_rozgar_tokens.dart';

/// Top branding, village picker, and search bar component for the VanRozgar shell.
class AppShellTopArea extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onVillagePickerTap;
  final TextEditingController? searchController;

  const AppShellTopArea({
    super.key,
    required this.language,
    this.onSearchChanged,
    this.onVillagePickerTap,
    this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(language);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VanRozgarTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: VanRozgarTokens.space8),

          // 1. Top Branding: VanRozgar & Tagline
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.appNameNative,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: tokens.heading,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      strings.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Small Sample Tag in top corner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: VanRozgarTokens.space8,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: tokens.chipBg,
                  borderRadius: VanRozgarTokens.borderPill,
                ),
                child: Text(
                  strings.sampleBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.chipText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: VanRozgarTokens.space12),

          // 2. Village Picker (compact, accessible, outlined button style)
          Semantics(
            button: true,
            label: '${strings.villagePickerLabel}: ${strings.sampleVillageValue}',
            child: InkWell(
              onTap: onVillagePickerTap ?? () {},
              borderRadius: VanRozgarTokens.borderPill,
              child: Container(
                constraints: const BoxConstraints(minHeight: VanRozgarTokens.minTouchTarget),
                padding: const EdgeInsets.symmetric(
                  horizontal: VanRozgarTokens.space12,
                  vertical: VanRozgarTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? tokens.card.withValues(alpha: 0.9) : VanRozgarTokens.white.withValues(alpha: 0.9),
                  borderRadius: VanRozgarTokens.borderPill,
                  border: Border.all(
                    color: tokens.borders,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20.0,
                      color: tokens.primaryGreen,
                    ),
                    const SizedBox(width: VanRozgarTokens.space8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.villagePickerLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10.0,
                              color: tokens.mutedText,
                            ),
                          ),
                          Text(
                            strings.sampleVillageValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.0,
                      color: tokens.outlinedControl,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: VanRozgarTokens.space12),

          // 3. Search Bar
          Semantics(
            textField: true,
            label: strings.searchSemanticLabel,
            child: SizedBox(
              height: VanRozgarTokens.minTouchTarget,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.bodyText,
                ),
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.mutedText,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: tokens.mutedText,
                    size: 22.0,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? tokens.card.withValues(alpha: 0.92)
                      : VanRozgarTokens.white.withValues(alpha: 0.95),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: VanRozgarTokens.space16,
                    vertical: 0.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: VanRozgarTokens.borderPill,
                    borderSide: BorderSide(color: tokens.borders, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: VanRozgarTokens.borderPill,
                    borderSide: BorderSide(color: tokens.borders, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: VanRozgarTokens.borderPill,
                    borderSide: BorderSide(color: tokens.primaryGreen, width: 1.5),
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
