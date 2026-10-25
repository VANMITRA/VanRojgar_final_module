import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_api.dart';
import 'package:vanrozgar/features/livelihood/data/livelihood_repository.dart';
import 'package:vanrozgar/features/livelihood/data/profile_repository.dart';
import 'package:vanrozgar/features/livelihood/data/schemes_repository.dart';
import 'package:vanrozgar/features/livelihood/livelihood_routes.dart';
import 'package:vanrozgar/features/livelihood/models/scheme.dart';
import 'package:vanrozgar/features/livelihood/product_links.dart';
import 'package:vanrozgar/features/livelihood/providers/detail_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/launch_provider.dart';
import 'package:vanrozgar/features/livelihood/providers/livelihood_providers.dart';
import 'package:vanrozgar/features/livelihood/providers/profile_providers.dart';
import 'package:vanrozgar/features/livelihood/screens/idea_detail_screen.dart';
import 'package:vanrozgar/features/livelihood/screens/livelihood_home_screen.dart';
import 'package:vanrozgar/features/livelihood/widgets/market_link.dart';

IdeaDetail _detail(String code, String nameEn) => IdeaDetail.fromJson({
      'code': code,
      'name_en': nameEn,
      'name_mr': nameEn,
      'status': 'in_report',
      'rank': 1,
      'group': 'ranked',
      'fit': 'fair',
      'reason': {'key': 'idea.reason.good_resources_nearby', 'params': {'nearest_m': 420}},
      'cost_level': 'medium',
      'best_season': 'year_round',
      'wildlife_risk': 'low',
      'needs': <Object>[],
      'checks': [
        {
          'check': 'law',
          'result': 'passed',
          'reason': {'key': 'detail.check.law', 'params': {}},
        },
      ],
      'resources': <Object>[],
      'flags': <Object>[],
      'weather_note': null,
      'schemes': <Object>[],
      'draft': true,
      'is_sample_data': true,
    });

class _Schemes implements SchemesRepository {
  _Schemes(this.known);

  /// code -> name for the ideas that are in his report; any other code is a 404.
  final Map<String, String> known;

  @override
  Future<IdeaDetail> idea(String code) async {
    final name = known[code];
    if (name == null) {
      throw ApiException(statusCode: 404, error: 'NOT_FOUND', messageKey: 'livelihood.idea_not_found');
    }
    return _detail(code, name);
  }

  @override
  Future<SchemesResult> schemes(SchemeFilter filter) async => const SchemesResult(
        schemes: [],
        helpTypes: [],
        audiences: [],
        isSampleData: true,
        registerEmpty: true,
      );
}

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required Map<String, String> ideasInReport,
  LivelihoodLaunch? launch,
  void Function(String route)? onNavigate,
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        livelihoodRepositoryProvider.overrideWithValue(const SeedLivelihoodRepository()),
        profileRepositoryProvider.overrideWithValue(MemoryProfileRepository()),
        schemesRepositoryProvider.overrideWithValue(_Schemes(ideasInReport)),
        if (launch != null) livelihoodLaunchProvider.overrideWith((ref) => launch),
        if (onNavigate != null)
          marketNavigatorProvider.overrideWithValue((context, route) => onNavigate(route)),
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
        routes: livelihoodRoutes,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('product codes', () {
    test('the app knows exactly the product codes the server accepts', () {
      final js = File('../server/src/core/productCode.js').readAsStringSync();
      final match = RegExp(r"PRODUCT_CODES = \[([^\]]*)\]").firstMatch(js)!;
      final serverCodes = RegExp(r"'([a-z-]+)'").allMatches(match.group(1)!).map((m) => m.group(1)!).toSet();
      expect(marketProducts.keys.toSet(), serverCodes);
    });

    test('every idea product exists, and units are valid listing units', () {
      const units = {'kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'};
      for (final entry in ideaProducts.entries) {
        for (final code in entry.value) {
          expect(marketProducts.containsKey(code), isTrue, reason: '${entry.key} -> $code');
        }
      }
      for (final p in marketProducts.values) {
        expect(units, contains(p.unit));
        expect(p.titleEn, isNotEmpty);
        expect(p.titleMr, isNotEmpty);
      }
    });

    test('no-harm rule: honey is managed-apiary honey and the produce group never lists honey', () {
      expect(marketProducts['honey']!.titleEn, 'Managed-apiary honey');
      expect(ideaProducts['mfp_collection_group'], isNot(contains('honey')));
      for (final p in marketProducts.values) {
        expect(p.titleEn.toLowerCase(), isNot(contains('wild')));
        expect(p.titleEn.toLowerCase(), isNot(contains('lac')));
      }
    });

    test('looking up in both directions', () {
      expect(productsForIdea('beekeeping_box').map((p) => p.code), ['honey']);
      expect(productsForIdea('plant_nursery').map((p) => p.code), ['seed', 'herb']);
      expect(productsForIdea('dairy_small'), isEmpty);
      expect(ideasForProduct('honey'), ['beekeeping_box']);
      expect(ideasForProduct('herb'), containsAll(['mfp_collection_group', 'plant_nursery']));
      expect(ideasForProduct('fibre'), isEmpty);
      expect(addListingRouteFor('leaf-plate'), '/gs/listings/new?product=leaf-plate');
    });
  });

  group('launch context', () {
    test('is read from the query and compared by value', () {
      final a = LivelihoodLaunch.fromQuery({'village': 'दहेगांव', 'taluka': 'Nashik', 'product': 'honey'});
      expect(a, LivelihoodLaunch.fromQuery({'village': 'दहेगांव', 'taluka': 'Nashik', 'product': 'honey'}));
      expect(a.isEmpty, isFalse);
      expect(LivelihoodLaunch.fromQuery(const {}).isEmpty, isTrue);
    });
  });

  group('the banner on the Livelihood home', () {
    testWidgets('says where the person came from and offers only ideas that are in his report', (tester) async {
      await _pump(
        tester,
        const LivelihoodHomeScreen(),
        ideasInReport: {'plant_nursery': 'Plant nursery'}, // beekeeping is NOT in his report
        launch: const LivelihoodLaunch(village: 'दहेगांव', taluka: 'Nashik', product: 'honey'),
      );
      expect(find.byKey(const ValueKey('market_launch_banner')), findsOneWidget);
      expect(
        find.text('You opened this from a listing: Managed-apiary honey in दहेगांव.'),
        findsOneWidget,
      );
      expect(find.byType(ActionChip), findsNothing, reason: 'beekeeping is not in his report, so it is not offered');
    });

    testWidgets('an idea that is in his report opens from the banner', (tester) async {
      await _pump(
        tester,
        const LivelihoodHomeScreen(),
        ideasInReport: {'plant_nursery': 'Plant nursery'},
        launch: const LivelihoodLaunch(product: 'seed'),
      );
      expect(find.widgetWithText(ActionChip, 'Plant nursery'), findsOneWidget);
      await tester.tap(find.widgetWithText(ActionChip, 'Plant nursery'));
      await tester.pumpAndSettle();
      expect(find.byType(IdeaDetailScreen), findsOneWidget);
    });

    testWidgets('can be dismissed, and is absent when the tab is opened normally', (tester) async {
      await _pump(
        tester,
        const LivelihoodHomeScreen(),
        ideasInReport: const {},
        launch: const LivelihoodLaunch(product: 'honey'),
      );
      expect(find.byKey(const ValueKey('market_launch_banner')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('market_launch_banner')), findsNothing);
    });

    testWidgets('is absent when the tab is opened normally', (tester) async {
      await _pump(tester, const LivelihoodHomeScreen(), ideasInReport: const {});
      expect(find.byKey(const ValueKey('market_launch_banner')), findsNothing);
    });
  });

  group('List this on the marketplace', () {
    testWidgets('one product goes straight to the add-listing screen for it', (tester) async {
      final routes = <String>[];
      await _pump(
        tester,
        const IdeaDetailScreen(code: 'beekeeping_box'),
        ideasInReport: {'beekeeping_box': 'Box beekeeping'},
        onNavigate: routes.add,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('market_list_button')));
      await tester.tap(find.byKey(const ValueKey('market_list_button')));
      await tester.pumpAndSettle();
      expect(routes, ['/gs/listings/new?product=honey']);
    });

    testWidgets('several products ask which one first', (tester) async {
      final routes = <String>[];
      await _pump(
        tester,
        const IdeaDetailScreen(code: 'plant_nursery'),
        ideasInReport: {'plant_nursery': 'Plant nursery'},
        onNavigate: routes.add,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('market_list_button')));
      await tester.tap(find.byKey(const ValueKey('market_list_button')));
      await tester.pumpAndSettle();
      expect(find.text('Which product do you want to list?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pick_herb')));
      await tester.pumpAndSettle();
      expect(routes, ['/gs/listings/new?product=herb']);
    });

    testWidgets('an idea with no produce shows no button', (tester) async {
      await _pump(
        tester,
        const IdeaDetailScreen(code: 'dairy_small'),
        ideasInReport: {'dairy_small': 'Small dairy'},
      );
      expect(find.byKey(const ValueKey('market_list_button')), findsNothing);
    });
  });
}
