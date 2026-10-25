import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/gramsabhas/gs_profile_screen.dart';

Map<String, dynamic> _detail({List<Map<String, dynamic>> species = const []}) => {
      'gramSabha': {
        'name': {'mr': 'ग्रामसभा वाघेरा'},
        'taluka': 'Trimbakeshwar',
        'district': 'Nashik',
        'verificationStatus': 'pending',
        'restoration': {
          'cfrAreaHa': 200,
          'saplings': 27534,
          'forestPonds': 1,
          'waterCapacityLitres': 7790000,
          'looseBoulderStructures': 20,
          'labourDays': 635,
          'cfrmcMeetings': 1,
          'wildlifeSessions': 0,
          'species': species,
          'source': 'Raah Foundation report, 1 October 2026',
        },
      },
    };

Future<void> _pump(WidgetTester tester, Map<String, dynamic> data) async {
  await tester.binding.setSurfaceSize(const Size(420, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [gsDetailProvider('gs1').overrideWith((ref) async => data)],
    child: const MaterialApp(home: GsProfileScreen(gramSabhaId: 'gs1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the village page shows the report figures and species', (tester) async {
    await _pump(tester, _detail(species: [
      {'name': 'Bamboo (Rohini)', 'count': 3191},
      {'name': 'Moha', 'count': null},
    ]));
    expect(find.textContaining('200 ha'), findsOneWidget);
    expect(find.textContaining('27,534'), findsOneWidget);
    expect(find.textContaining('7,790,000 litres'), findsOneWidget);
    expect(find.textContaining('635'), findsOneWidget);
    expect(find.textContaining('Bamboo (Rohini) • 3,191'), findsOneWidget);
    expect(find.text('Moha'), findsOneWidget, reason: 'a species with no count shows its name only');
    expect(find.textContaining('Raah Foundation report, 1 October 2026'), findsWidgets);
  });

  testWidgets('a village the report has no species list for says so and invents nothing', (tester) async {
    await _pump(tester, _detail());
    expect(find.textContaining('no species list'), findsOneWidget);
    expect(find.textContaining('MRSAC'), findsNothing);
    expect(find.textContaining('Demo login'), findsNothing);
  });

  testWidgets('a record with no restoration figures shows "not available"', (tester) async {
    final data = _detail();
    (data['gramSabha'] as Map).remove('restoration');
    await _pump(tester, data);
    expect(find.textContaining('not available'), findsOneWidget);
  });
}
