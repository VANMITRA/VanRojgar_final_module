import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanrozgar/features/auth/auth_providers.dart';
import 'package:vanrozgar/features/auth/register_portal_screen.dart';
import 'package:vanrozgar/shared/widgets/vr_text.dart';

final _devanagari = RegExp(r'[ऀ-ॿ]');

Future<ProviderContainer> _open(WidgetTester tester, String lang) async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(activeLocaleProvider.notifier).setLanguage(lang);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: RegisterPortalScreen()),
  ));
  await tester.pump();
  return container;
}

void main() {
  test('tr3 picks English, Hindi or Marathi', () {
    expect(tr3('en', en: 'a', hi: 'b', mr: 'c'), 'a');
    expect(tr3('hi', en: 'a', hi: 'b', mr: 'c'), 'b');
    expect(tr3('mr', en: 'a', hi: 'b', mr: 'c'), 'c');
    expect(tr3('xx', en: 'a', hi: 'b', mr: 'c'), 'a', reason: 'an unknown language falls back to English');
  });

  testWidgets('sign-up role picker is all English when English is chosen (no Marathi left over)', (tester) async {
    await _open(tester, 'en');
    expect(find.text('Choose your role'), findsOneWidget);
    expect(find.text('Gram Sabha'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('CFR holder'), findsOneWidget);
    expect(find.text('General Buyer'), findsOneWidget);
    final shown = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join(' ');
    expect(_devanagari.hasMatch(shown), isFalse, reason: 'English screen must not show Devanagari text: $shown');
  });

  testWidgets('sign-up role picker follows Hindi', (tester) async {
    await _open(tester, 'hi');
    expect(find.text('अपनी भूमिका चुनें'), findsOneWidget);
    expect(find.text('किसान'), findsOneWidget);
    expect(find.text('Choose your role'), findsNothing);
  });

  testWidgets('sign-up role picker follows Marathi', (tester) async {
    await _open(tester, 'mr');
    expect(find.text('आपली भूमिका निवडा'), findsOneWidget);
    expect(find.text('शेतकरी'), findsOneWidget);
  });

  testWidgets('changing the language changes the open screen', (tester) async {
    final c = await _open(tester, 'en');
    expect(find.text('Choose your role'), findsOneWidget);
    await c.read(activeLocaleProvider.notifier).setLanguage('hi');
    await tester.pump();
    expect(find.text('अपनी भूमिका चुनें'), findsOneWidget);
  });
}
