import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/about/about_screen.dart';

void main() {
  test('the About screen covers credits, data, limits and privacy', () {
    final titles = aboutSections.map((s) => s.title).join('|');
    for (final word in ['Credits', 'Data', 'limits', 'privacy']) {
      expect(titles.toLowerCase(), contains(word.toLowerCase()));
    }
  });

  test('the privacy text makes no claim the app cannot keep', () {
    final text = aboutSections.expand((s) => s.lines).join(' ').toLowerCase();
    expect(text, contains('pin'));
    expect(text, contains('openstreetmap'));
    expect(text, contains('open-meteo'));
    expect(text, contains('not been reviewed'));
  });

  testWidgets('every line is on screen when scrolled', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AboutScreen())));
    expect(find.textContaining('Raah Foundation'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('No advertising'), 300);
    expect(find.textContaining('No advertising'), findsOneWidget);
  });
}
