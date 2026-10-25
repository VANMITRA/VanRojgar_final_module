import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_repository.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/models/profile.dart';
import 'package:vanrozgar/features/livelihood/models/report.dart';
import 'package:vanrozgar/features/livelihood/providers/livelihood_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/market_points.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';
import 'package:vanrozgar/features/livelihood/screens/map_screen.dart';

/// The sample report with positions added to its first two resources (the third stays without one).
Report _report() {
  final json = jsonDecode(File('assets/livelihood/sample_report.json').readAsStringSync()) as Map<String, dynamic>;
  final resources = (json['resources'] as List).cast<Map<String, dynamic>>();
  resources[0]['lat'] = 19.781;
  resources[0]['lng'] = 73.222;
  resources[1]['lat'] = 19.775;
  resources[1]['lng'] = 73.215;
  for (final r in resources.skip(2)) {
    r.remove('lat');
    r.remove('lng');
  }
  return Report.fromJson(json);
}

class _Repo implements LivelihoodRepository {
  final List<int?> radii = [];

  @override
  Future<ReportResult> report({int? radiusM}) async {
    radii.add(radiusM);
    return ReportResult(_report());
  }
}

const _plot = LivelihoodProfile(
  areaValue: 2,
  lat: 19.7805,
  lng: 73.2210,
  locationSource: LocationSource.gps,
);

Future<_Repo> _pump(
  WidgetTester tester, {
  LivelihoodProfile? profile = _plot,
  MemoryProfileRepository? profiles,
  List<MarketPoint> listings = const [],
}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final repo = _Repo();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        livelihoodRepositoryProvider.overrideWithValue(repo),
        profileRepositoryProvider.overrideWithValue(profiles ?? MemoryProfileRepository(profile)),
        mapTilesEnabledProvider.overrideWithValue(false),
        marketPointsLoaderProvider.overrideWithValue(() async => listings),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: ThemeData(fontFamily: 'NotoSansDevanagari'),
        supportedLocales: const [Locale('en'), Locale('mr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MapScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('draws the plot and only the resources the server gave a position for', (tester) async {
    final repo = await _pump(tester);
    expect(find.byKey(const ValueKey('my_plot')), findsOneWidget);
    final report = _report();
    final withPosition = report.resources.where((r) => r.lat != null).toList();
    expect(withPosition, hasLength(2));
    for (final r in withPosition) {
      expect(find.byKey(ValueKey('resource_${r.id}')), findsOneWidget);
    }
    for (final r in report.resources.where((r) => r.lat == null)) {
      expect(find.byKey(ValueKey('resource_${r.id}')), findsNothing);
    }
    expect(repo.radii.first, 5000, reason: 'the default search distance is 5 km');
  });

  testWidgets('credits OpenStreetMap and says when the pins are sample data', (tester) async {
    await _pump(tester);
    expect(find.text('Map data: OpenStreetMap contributors'), findsOneWidget);
    expect(find.text('Resource pins are SAMPLE data, not a real survey.'), findsOneWidget);
  });

  testWidgets('the slider covers 2 to 10 km and a new distance asks the server again', (tester) async {
    final repo = await _pump(tester);
    final slider = tester.widget<Slider>(find.byKey(const ValueKey('radius_slider')));
    expect((slider.min, slider.max, slider.divisions), (2.0, 10.0, 8));
    expect(find.text('Search distance: 5 km'), findsOneWidget);

    await tester.drag(find.byKey(const ValueKey('radius_slider')), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(repo.radii.length, 2);
    expect(repo.radii.last, isNot(5000));
    expect(repo.radii.last! % 1000, 0);
    expect(repo.radii.last! <= 10000, isTrue);
  });

  testWidgets('tapping the map offers a new plot, and saving it keeps his other details', (tester) async {
    final profiles = MemoryProfileRepository(_plot);
    await _pump(tester, profiles: profiles);
    expect(find.byKey(const ValueKey('use_pin')), findsNothing);
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)) + const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 600)); // flutter_map waits to rule out a double tap
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('new_pin')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('use_pin')));
    await tester.pumpAndSettle();

    final saved = (await profiles.load())!;
    expect(saved.locationSource, LocationSource.manual);
    expect(saved.lat, isNot(_plot.lat));
    expect(saved.areaValue, 2, reason: 'his land size is kept');
    expect(find.byKey(const ValueKey('new_pin')), findsNothing);
  });

  testWidgets('with no saved plot it says so and still lets him pick one', (tester) async {
    await _pump(tester, profile: null);
    expect(find.text('Add your details first to see your land on the map.'), findsOneWidget);
    expect(find.byKey(const ValueKey('my_plot')), findsNothing);
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('use_pin')), findsOneWidget);
  });

  testWidgets('marketplace listings appear only when the layer is switched on', (tester) async {
    await _pump(tester, listings: const [
      MarketPoint(id: 'l1', titleMr: 'मध', titleEn: 'Honey', village: 'दहेगांव', lat: 19.78, lng: 73.22),
    ]);
    expect(find.byKey(const ValueKey('listing_l1')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('listings_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('listing_l1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('listings_toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('listing_l1')), findsNothing);
  });

  test('a listing point is read from the server answer', () {
    final p = MarketPoint.fromJson({
      'id': 'x', 'title': {'mr': 'मध', 'en': 'Honey'}, 'village': 'V', 'lat': 20.01, 'lng': 73.78, 'productCode': 'honey',
    });
    expect((p.lat, p.lng, p.productCode), (20.01, 73.78, 'honey'));
    expect(p.title('en'), 'Honey');
    expect(p.title('mr'), 'मध');
  });
}
