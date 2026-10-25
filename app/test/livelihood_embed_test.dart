import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_repository.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/livelihood_embed.dart';
import 'package:vanrozgar/features/livelihood/providers/host_hooks.dart';
import 'package:vanrozgar/features/livelihood/providers/livelihood_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';

/// The feature inside the portal shell: no second header of its own, a slim title row with a back
/// arrow only once it is not on its first screen, and the back button going back inside it first.
Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // the frame hook as main.dart sets it (not the feature's server)
        hostFrameBuilderProvider.overrideWithValue(embeddedLivelihoodFrame),
        livelihoodRepositoryProvider.overrideWithValue(const SeedLivelihoodRepository()),
        profileRepositoryProvider.overrideWithValue(MemoryProfileRepository()),
      ],
      // ignore: prefer_const_constructors
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: LivelihoodShell()),
      ),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('the hub opens without a header of its own and without Ask', (tester) async {
    await _pump(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Show my report'), findsOneWidget);
    expect(find.text('Government schemes'), findsOneWidget);
    expect(find.textContaining('Ask'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing); // first screen: nothing to go back to
  });

  testWidgets('a screen of the feature shows its title row and goes back', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Government schemes'));
    await _settle(tester);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Government schemes'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await _settle(tester);
    expect(find.text('Government schemes'), findsOneWidget);
  });

  testWidgets('the system back button goes back inside the feature first', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Government schemes'));
    await _settle(tester);
    final handled = await tester.binding.handlePopRoute();
    await _settle(tester);
    expect(handled, isTrue);
    expect(find.text('Government schemes'), findsOneWidget); // back on the hub, still in the app
  });
}
