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

          // 1. Top Branding: VanRozgar & Tagline + Compact Village Picker Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        strings.appNameNative,
                        maxLines: 1,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: tokens.heading,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      strings.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VanRozgarTokens.space8),

              // Right: Compact village picker pill (max width ~45% screen, min touch target 48, painted height 38)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.45,
                ),
                child: Semantics(
                  button: true,
                  label: '${strings.villagePickerLabel}: ${strings.sampleVillageValue}',
                  child: InkWell(
                    onTap: onVillagePickerTap ?? () {},
                    borderRadius: VanRozgarTokens.borderPill,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: VanRozgarTokens.minTouchTarget),
                      alignment: Alignment.center,
                      child: Container(
                        height: 38.0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: VanRozgarTokens.space8,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? tokens.card.withValues(alpha: 0.85)
                              : VanRozgarTokens.white.withValues(alpha: 0.85),
                          borderRadius: VanRozgarTokens.borderPill,
                          border: Border.all(
                            color: tokens.borders,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.0,
                              color: tokens.primaryGreen,
                            ),
                            const SizedBox(width: 4.0),
                            Flexible(
                              child: Text(
                                strings.sampleVillageValue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: tokens.heading,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.0,
                              color: tokens.outlinedControl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: VanRozgarTokens.space8),

          // 2. Search Bar (height 44, alpha 0.85 fill)
          Semantics(
            textField: true,
            label: strings.searchSemanticLabel,
            child: SizedBox(
              height: 44.0,
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
                    size: 20.0,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? tokens.card.withValues(alpha: 0.85)
                      : VanRozgarTokens.white.withValues(alpha: 0.85),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: VanRozgarTokens.space16,
                    vertical: 0.0,
                  ),
                  isDense: true,
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
