import 'package:flutter/material.dart';
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
    // The language chosen on this phone stays in charge. Logging in never switches it, because the demo
    // and older accounts are stored as Marathi and that overrode what the person had just chosen.
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
