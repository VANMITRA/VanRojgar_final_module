import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/vr_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/routing/app_router.dart';
import 'features/auth/auth_providers.dart';
import 'l10n/app_localizations.dart';

class VanRozgarApp extends ConsumerWidget {
  const VanRozgarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(activeLocaleProvider);
    // Follow the logged-in user's saved language (login, register, session restore)
    ref.listen(authControllerProvider, (prev, next) {
      final lang = next.valueOrNull?.language;
      if (lang != null && lang != ref.read(activeLocaleProvider)) {
        ref.read(activeLocaleProvider.notifier).setLanguage(lang);
      }
    });
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'VanRozgar • वनरोजगार',
      debugShowCheckedModeBanner: false,
      theme: VrTheme.light(),
      darkTheme: VrTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      locale: Locale(activeLocale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
