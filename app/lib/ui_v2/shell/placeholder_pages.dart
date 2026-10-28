import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';

/// Base layout container for the guest-accessible placeholder screens.
class _PlaceholderShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? extraContent;

  const _PlaceholderShell({
    required this.icon,
    required this.title,
    required this.description,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    return AppBackground(
      categorySlug: 'forest-produce',
      headerHeight: 180.0,
      useSafeArea: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: VanRozgarTokens.space24,
            vertical: VanRozgarTokens.space24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(VanRozgarTokens.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: tokens.chipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32.0,
                        color: tokens.chipText,
                      ),
                    ),
                    const SizedBox(height: VanRozgarTokens.space16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: tokens.heading,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: VanRozgarTokens.space8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.bodyText,
                        height: 1.45,
                      ),
                    ),
                    if (extraContent != null) ...[
                      const SizedBox(height: VanRozgarTokens.space20),
                      extraContent!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Categories placeholder screen.
class CategoriesPlaceholderPage extends ConsumerWidget {
  const CategoriesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    return _PlaceholderShell(
      icon: Icons.category_outlined,
      title: strings.placeholderCategoriesTitle,
      description: strings.placeholderCategoriesDesc,
    );
  }
}

/// Cart placeholder screen.
class CartPlaceholderPage extends ConsumerWidget {
  const CartPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    return _PlaceholderShell(
      icon: Icons.shopping_cart_outlined,
      title: strings.placeholderCartTitle,
      description: strings.placeholderCartDesc,
    );
  }
}

/// Orders placeholder screen.
class OrdersPlaceholderPage extends ConsumerWidget {
  const OrdersPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);

    return _PlaceholderShell(
      icon: Icons.receipt_long_outlined,
      title: strings.placeholderOrdersTitle,
      description: strings.placeholderOrdersDesc,
    );
  }
}

/// Profile and Settings placeholder screen with in-memory theme and language selectors.
class ProfilePlaceholderPage extends ConsumerWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);

    final currentLanguage = ref.watch(uiV2LanguageProvider);
    final currentThemeMode = ref.watch(uiV2ThemeModeProvider);
    final strings = AppStrings.of(currentLanguage);

    return _PlaceholderShell(
      icon: Icons.person_outline,
      title: strings.placeholderProfileTitle,
      description: strings.placeholderProfileDesc,
      extraContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1.0),
          const SizedBox(height: VanRozgarTokens.space16),

          // 1. Theme Setting
          Text(
            strings.settingsThemeTitle,
            style: theme.textTheme.titleMedium?.copyWith(color: tokens.heading),
          ),
          const SizedBox(height: VanRozgarTokens.space8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(strings.themeSystem),
                icon: const Icon(Icons.brightness_auto, size: 18.0),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(strings.themeLight),
                icon: const Icon(Icons.light_mode, size: 18.0),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(strings.themeDark),
                icon: const Icon(Icons.dark_mode, size: 18.0),
              ),
            ],
            selected: {currentThemeMode},
            onSelectionChanged: (newSelection) {
              ref.read(uiV2ThemeModeProvider.notifier).state = newSelection.first;
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.comfortable,
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(borderRadius: VanRozgarTokens.borderPill),
              ),
            ),
          ),

          const SizedBox(height: VanRozgarTokens.space20),

          // 2. Language Setting (English, हिंदी, मराठी)
          Text(
            strings.settingsLanguageTitle,
            style: theme.textTheme.titleMedium?.copyWith(color: tokens.heading),
          ),
          const SizedBox(height: VanRozgarTokens.space8),
          SegmentedButton<AppLanguage>(
            segments: const [
              ButtonSegment<AppLanguage>(
                value: AppLanguage.en,
                label: Text('English'),
              ),
              ButtonSegment<AppLanguage>(
                value: AppLanguage.hi,
                label: Text('हिंदी'),
              ),
              ButtonSegment<AppLanguage>(
                value: AppLanguage.mr,
                label: Text('मराठी'),
              ),
            ],
            selected: {currentLanguage},
            onSelectionChanged: (newSelection) {
              ref.read(uiV2LanguageProvider.notifier).state = newSelection.first;
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.comfortable,
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(borderRadius: VanRozgarTokens.borderPill),
              ),
            ),
          ),

          const SizedBox(height: VanRozgarTokens.space16),

          // Guest mode notice
          Container(
            padding: const EdgeInsets.all(VanRozgarTokens.space12),
            decoration: BoxDecoration(
              color: tokens.chipBg,
              borderRadius: VanRozgarTokens.borderSmall,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18.0,
                  color: tokens.chipText,
                ),
                const SizedBox(width: VanRozgarTokens.space8),
                Expanded(
                  child: Text(
                    strings.guestModeNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.chipText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
