import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/home_demo_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';
import 'package:vanrozgar/ui_v2/widgets/home_top_deals_section.dart';

final Map<String, dynamic> _testCatalogMap = {
  'note': 'Test catalog',
  'village': {'en': 'Nashik', 'hi': 'नाशिक', 'mr': 'नाशिक'},
  'products': [
    {
      'productCode': 'fruit_mango',
      'categorySlug': 'fruit',
      'image': 'assets/catalog/fruit_mango.jpg',
      'notForEating': false,
      'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {
          'id': 'm-1',
          'sellerType': 'gramsabha',
          'pricePerUnitPaise': 9000,
          'mrpPerUnitPaise': 10000,
          'quantityTotal': 100,
          'quantitySold': 25,
          'minOrderQuantity': 2,
          'daysAgo': 5,
        },
      ],
    },
    {
      'productCode': 'bamboo_basket',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo_basket.jpg',
      'notForEating': false,
      'title': {'en': 'Bamboo Basket', 'hi': 'बाँस की टोकरी', 'mr': 'बांबूची टोपली'},
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {
          'id': 'b-1',
          'sellerType': 'cfrholder',
          'pricePerUnitPaise': 7000,
          'mrpPerUnitPaise': 10000,
          'quantityTotal': 50,
          'quantitySold': 40,
          'minOrderQuantity': 1,
          'daysAgo': 1,
        },
      ],
    },
    {
      'productCode': 'nuts_bibba',
      'categorySlug': 'nuts-and-seeds',
      'image': 'assets/catalog/nuts_bibba.jpg',
      'notForEating': true,
      'title': {'en': 'Bibba Nut', 'hi': 'बिब्बा', 'mr': 'बिब्बा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {
          'id': 'nb-1',
          'sellerType': 'cfrholder',
          'pricePerUnitPaise': 12000,
          'mrpPerUnitPaise': 15000,
          'quantityTotal': 40,
          'quantitySold': 5,
          'minOrderQuantity': 1,
          'daysAgo': 2,
        },
      ],
    },
  ],
};

double _relativeLuminance(Color c) {
  double channel(double v) {
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(c.r);
  final g = channel(c.g);
  final b = channel(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

Widget _buildHomeTestApp({
  required ThemeMode themeMode,
  required AppLanguage language,
  double textScale = 1.0,
}) {
  return ProviderScope(
    overrides: [
      uiV2ThemeModeProvider.overrideWith((ref) => themeMode),
      uiV2LanguageProvider.overrideWith((ref) => language),
      shopRepositoryProvider.overrideWithValue(
        SampleShopRepository.fromMap(_testCatalogMap),
      ),
    ],
    child: MaterialApp(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: themeMode,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Material(child: HomeDemoPage()),
        ),
      ),
    ),
  );
}

void main() {
  group('Task 3: Top Deals Tab Strip Contrast, Folder Shape & Overflow Tests', () {
    testWidgets(
      'Text vs background contrast is >= 4.5:1 in all 4 combinations '
      '(selected/unselected x light/dark) and folder tab joins panel below',
      (WidgetTester tester) async {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.physicalSize = const Size(390.0 * 2.0, 1200.0 * 2.0);
        tester.view.devicePixelRatio = 2.0;

        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(
            _buildHomeTestApp(
              themeMode: mode,
              language: AppLanguage.en,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(HomeTopDealsSection), findsOneWidget);

          // Check index 0 (selected) and index 1 (unselected)
          for (final index in [0, 1]) {
            final isSelected = index == 0;
            final stripContainer = tester.widget<Container>(
              find.byKey(Key('top_deal_tab_strip_$index')),
            );
            final tagText = tester.widget<Text>(
              find.byKey(Key('top_deal_tab_tag_$index')),
            );
            final bodyContainer = tester.widget<Container>(
              find.byKey(Key('top_deal_tab_body_$index')),
            );
            final labelText = tester.widget<Text>(
              find.byKey(Key('top_deal_tab_label_$index')),
            );

            final stripBg = stripContainer.color!;
            final stripFg = tagText.style!.color!;
            final stripContrast = _contrastRatio(stripBg, stripFg);

            expect(
              stripContrast,
              greaterThanOrEqualTo(4.5),
              reason:
                  'Top strip contrast ($mode, selected=$isSelected) was $stripContrast (< 4.5:1)',
            );

            final bodyBg = bodyContainer.color!;
            final labelFg = labelText.style!.color!;
            final bodyContrast = _contrastRatio(bodyBg, labelFg);

            expect(
              bodyContrast,
              greaterThanOrEqualTo(4.5),
              reason:
                  'Tab label contrast ($mode, selected=$isSelected) was $bodyContrast (< 4.5:1)',
            );
          }

          // Check folder-tab shape joins panel below when selected
          final selectedTabRect = tester.getRect(find.byKey(const Key('top_deal_tab_0')));
          final unselectedTabRect = tester.getRect(find.byKey(const Key('top_deal_tab_1')));
          final panelRect = tester.getRect(find.byKey(const Key('top_deals_panel')));

          expect(selectedTabRect.bottom, greaterThanOrEqualTo(panelRect.top));
          expect(unselectedTabRect.bottom, lessThan(selectedTabRect.bottom));

          // Tap tab 1 and verify it becomes selected and joins the panel
          await tester.tap(find.byKey(const Key('top_deal_tab_1')));
          await tester.pumpAndSettle();

          final newSelectedRect = tester.getRect(find.byKey(const Key('top_deal_tab_1')));
          final newUnselectedRect = tester.getRect(find.byKey(const Key('top_deal_tab_0')));
          expect(newSelectedRect.bottom, greaterThanOrEqualTo(panelRect.top));
          expect(newUnselectedRect.bottom, lessThan(newSelectedRect.bottom));
        }
      },
    );

    testWidgets(
      'No overflow across 320x568, 360x800, 430x932 in EN, HI, MR, light & dark at textScaler 1.5',
      (WidgetTester tester) async {
        const sizes = <Size>[
          Size(320.0, 568.0),
          Size(360.0, 800.0),
          Size(430.0, 932.0),
        ];

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final size in sizes) {
          for (final lang in AppLanguage.values) {
            for (final mode in [ThemeMode.light, ThemeMode.dark]) {
              tester.view.physicalSize = Size(size.width * 2.0, size.height * 2.0);
              tester.view.devicePixelRatio = 2.0;

              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                _buildHomeTestApp(
                  themeMode: mode,
                  language: lang,
                  textScale: 1.5,
                ),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: 'Overflow on Top Deals at $size, $lang, $mode, textScaler 1.5',
              );
            }
          }
        }
      },
    );
  });
}
