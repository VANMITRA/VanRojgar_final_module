import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/catalog_providers.dart';
import 'shell/app_shell.dart';
import 'theme/van_rozgar_theme.dart';
import 'widgets/app_background.dart';

/// Entry point for running the VanRozgar Phase 1 UI demo.
///
/// Run with:
/// ```bash
/// flutter run -t lib/ui_v2/main_demo.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: VanRozgarDemoApp(),
    ),
  );
}

/// The root application widget for the Phase 1 UI demo.
class VanRozgarDemoApp extends ConsumerStatefulWidget {
  const VanRozgarDemoApp({super.key});

  @override
  ConsumerState<VanRozgarDemoApp> createState() => _VanRozgarDemoAppState();
}

class _VanRozgarDemoAppState extends ConsumerState<VanRozgarDemoApp> {
  bool _artworkPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_artworkPrecached) {
      _artworkPrecached = true;
      // Precache header images before first visible interaction
      AppBackground.precacheArtwork(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(uiV2ThemeModeProvider);

    return MaterialApp.router(
      title: 'VanRozgar',
      debugShowCheckedModeBanner: false,
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: uiV2Router,
    );
  }
}
