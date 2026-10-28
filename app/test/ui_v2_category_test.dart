import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/category_query.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/categories_page.dart';
import 'package:vanrozgar/ui_v2/shell/category_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';
import 'package:vanrozgar/ui_v2/widgets/product_card.dart';

/// Phase 4: Categories tab, Category page, sort and filters, quantity picker. Small inline data only.

Map<String, dynamic> _p(String code, String slug, String en, String hi, int price, int mrp,
    {int sold = 10, int total = 100, int min = 1, int days = 5, int sellers = 1}) {
  return {
    'productCode': code,
    'categorySlug': slug,
    'image': 'assets/catalog/$code.jpg',
    'pictureNote': 'ready',
    'notForEating': false,
    'title': {'en': en, 'hi': hi, 'mr': en},
    'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
    'listings': [
      for (var i = 0; i < sellers; i++)
        {
          'id': '$code-$i',
          'sellerType': i == 0 ? 'gramsabha' : 'cfrholder',
          'pricePerUnitPaise': price + i * 500,
          'mrpPerUnitPaise': mrp,
          'quantityTotal': total,
          'quantitySold': sold,
          'minOrderQuantity': min,
          'daysAgo': days,
        },
    ],
  };
}

final Map<String, dynamic> _data = {
  'products': [
    _p('fruit_mango', 'fruit', 'Mango', 'आम', 9900, 12000, sold: 75, total: 300, min: 5, days: 3),
    _p('fruit_awla', 'fruit', 'Amla', 'आँवला', 6000, 6000, sold: 10, total: 100, min: 5, days: 9),
    _p('fruit_bel', 'fruit', 'Bael', 'बेल', 5000, 7000, sold: 40, total: 100, min: 5, days: 1),
    _p('bamboo', 'handicrafts-bamboo', 'Bamboo pole', 'बाँस', 12000, 12000, sold: 5, total: 50, min: 2, days: 2),
    {
      'productCode': 'timber_shisu',
      'categorySlug': 'timber-trees',
      'image': 'assets/catalog/timber_shisu.jpg',
      'title': {'en': 'Sissoo', 'hi': 'शिसू', 'mr': 'शिसू'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [],
    },
  ],
};

Widget _app({AppLanguage language = AppLanguage.en, ThemeMode mode = ThemeMode.light, double textScale = 1.0}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      themeMode: mode,
      routerConfig: uiV2Router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}

void _tall(WidgetTester tester, {double w = 360, double h = 1800}) {
  tester.view.physicalSize = Size(w * 2.0, h * 2.0);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _open(WidgetTester tester, Widget app, String path) async {
  uiV2LandingSeen.value = true;
  uiV2Router.go(path);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

List<ShopProduct> _products() => [
      for (final m in (_data['products'] as List)) ShopProduct.fromJson(m as Map<String, dynamic>),
    ].where((p) => p.listings.isNotEmpty).toList();

/// The product codes of the cards on screen, in grid order (left to right, top to bottom).
List<String> _cards(WidgetTester tester) =>
    tester.widgetList<ProductCard>(find.byType(ProductCard)).map((c) => c.product.productCode).toList();

void main() {
  group('Sort and filter rules', () {
    test('every sort order', () {
      final list = _products();
      const none = CategoryFilters();
      expect(applyCategoryQuery(list, CategorySort.popular, none).map((p) => p.productCode).first, 'fruit_mango');
      expect(applyCategoryQuery(list, CategorySort.priceAsc, none).map((p) => p.productCode).first, 'fruit_bel');
      expect(applyCategoryQuery(list, CategorySort.discount, none).map((p) => p.productCode).first, 'fruit_bel');
      expect(applyCategoryQuery(list, CategorySort.newest, none).map((p) => p.productCode).first, 'fruit_bel');
      // price ascending is really ascending
      final asc = applyCategoryQuery(list, CategorySort.priceAsc, none).map((p) => p.startingAtPaise).toList();
      expect(asc, [...asc]..sort());
    });

    test('price range and only discounted, alone and together', () {
      final list = _products();
      final inRange = applyCategoryQuery(
        list,
        CategorySort.priceAsc,
        const CategoryFilters(priceRupees: RangeValues(55, 100)),
      );
      expect(inRange.map((p) => p.productCode), ['fruit_awla', 'fruit_mango']);
      final disc = applyCategoryQuery(list, CategorySort.popular, const CategoryFilters(onlyDiscounted: true));
      expect(disc.map((p) => p.productCode), isNot(contains('fruit_awla')));
      expect(disc.map((p) => p.productCode), isNot(contains('bamboo')));
      final both = applyCategoryQuery(
        list,
        CategorySort.popular,
        const CategoryFilters(priceRupees: RangeValues(55, 100), onlyDiscounted: true),
      );
      expect(both.map((p) => p.productCode), ['fruit_mango']);
      expect(const CategoryFilters().isActive, isFalse);
      expect(const CategoryFilters(onlyDiscounted: true).activeCount, 1);
    });

    test('price bounds are rounded outwards and an empty list is safe', () {
      final b = categoryPriceBounds(_products());
      expect(b.start, 50);
      expect(b.end, 120);
      expect(categoryPriceBounds(const []).start, 0);
    });
  });

  group('Categories tab and Category page', () {
    testWidgets('the Categories tab lists "All products" and only categories with sellers', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories');
      expect(find.byType(CategoriesPage), findsOneWidget);
      expect(find.byKey(const Key('category_tile_all')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_fruit')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_handicrafts-bamboo')), findsOneWidget);
      expect(find.byKey(const Key('category_tile_timber-trees')), findsNothing); // no sellers
      expect(find.text('3 products'), findsWidgets);
    });

    testWidgets('a tile opens the category page; back returns to the tab', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories');
      await tester.tap(find.byKey(const Key('category_tile_fruit')));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryPage), findsOneWidget);
      expect(find.text('Fruit'), findsWidgets);
      expect(find.text('3 products'), findsOneWidget);
      // the live bar is on every card
      expect(find.textContaining('sold ·'), findsNWidgets(3));
      expect(find.byType(NavigationBar), findsOneWidget); // still inside the shell

      await tester.tap(find.byKey(const Key('category_back')));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesPage), findsOneWidget);
    });

    testWidgets('a category without sellers shows the empty state', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories/timber-trees');
      expect(find.text('No sample sellers yet'), findsOneWidget);
    });

    testWidgets('sort and filters through the sheet: order, only discounted, price range, clear', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories/fruit');
      expect(_cards(tester).first, 'fruit_mango'); // popular: most sold first

      // sort: price low to high
      await tester.tap(find.byKey(const Key('sort_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort_priceAsc')));
      await tester.tap(find.byKey(const Key('filters_apply')));
      await tester.pumpAndSettle();
      expect(find.text('Price: low to high'), findsOneWidget);
      expect(_cards(tester), ['fruit_bel', 'fruit_awla', 'fruit_mango']);

      // only discounted: Amla (no discount) disappears and the button shows "(1)"
      await tester.tap(find.byKey(const Key('sort_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('only_discounted_switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filters_apply')));
      await tester.pumpAndSettle();
      expect(find.text('Amla'), findsNothing);
      expect(find.text('2 products'), findsOneWidget);
      expect(find.text('Sort and filter (1)'), findsOneWidget);

      // Clear in the sheet: everything is back and the sort is popular again
      await tester.tap(find.byKey(const Key('sort_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filters_clear')));
      await tester.pumpAndSettle();
      expect(find.text('3 products'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
    });

    testWidgets('a filter that matches nothing shows "Nothing found." and "Clear filters" brings the products back',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories/handicrafts-bamboo'); // its only product has no discount
      expect(find.text('1 product'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sort_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('only_discounted_switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filters_apply')));
      await tester.pumpAndSettle();
      expect(find.text('Nothing found.'), findsOneWidget);
      expect(find.text('0 products'), findsOneWidget);
      await tester.tap(find.byKey(const Key('clear_filters')));
      await tester.pumpAndSettle();
      expect(find.text('Nothing found.'), findsNothing);
      expect(find.text('1 product'), findsOneWidget);
    });

    testWidgets('ADD on a category card opens the picker at the minimum order and adds that quantity',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/categories/fruit');
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quantity_picker')), findsOneWidget);
      expect(find.text('Choose quantity'), findsOneWidget);
      expect(find.text('Minimum order: 5 kg'), findsOneWidget);

      // "-" stops at the minimum; "+" goes up; the total follows
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(find.text('5'), findsWidgets);
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      expect(find.text('6'), findsWidgets);

      final container = ProviderScope.containerOf(tester.element(find.byType(NavigationBar)));
      await tester.tap(find.byKey(const Key('quantity_picker_add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quantity_picker')), findsNothing);
      expect(container.read(cartQuantitiesProvider).values.single, 6);
      expect(find.byKey(const Key('floating_cart_pill')), findsOneWidget);
    });

    testWidgets('Hindi: no English on the Categories tab, the Category page and the sheet', (tester) async {
      _tall(tester);
      await _open(tester, _app(language: AppLanguage.hi), '/categories');
      expect(find.text('Categories'), findsNothing);
      expect(find.text('All products'), findsNothing);
      await tester.tap(find.byKey(const Key('category_tile_fruit')));
      await tester.pumpAndSettle();
      expect(find.textContaining('sold'), findsNothing);
      expect(find.text('Sort and filter'), findsNothing);
      expect(find.text('क्रमबद्ध और फ़िल्टर'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sort_filter_button')));
      await tester.pumpAndSettle();
      expect(find.text('Sort by'), findsNothing);
      expect(find.text('क्रमबद्ध करें'), findsOneWidget);
      expect(find.text('Apply'), findsNothing);
      expect(find.text('लागू करें'), findsOneWidget);
    });
  });

  group('No overflow', () {
    testWidgets('Categories tab, Category page, sheet and picker at 3 sizes, 3 languages, light and dark, text x1.5',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            final reason = '${size.width}x${size.height} $lang $mode';
            await _open(tester, _app(language: lang, mode: mode, textScale: 1.5), '/categories');
            expect(tester.takeException(), isNull, reason: 'categories $reason');
            await _open(tester, _app(language: lang, mode: mode, textScale: 1.5), '/categories/fruit');
            expect(tester.takeException(), isNull, reason: 'category $reason');
            await tester.tap(find.byKey(const Key('sort_filter_button')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'sheet $reason');
            await tester.tap(find.byKey(const Key('filters_apply')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'after apply $reason');
            // the quantity picker
            await _open(tester, _app(language: lang, mode: mode, textScale: 1.5), '/categories/fruit');
            final add = find.text(AppStrings.of(lang).addButton).first;
            await tester.ensureVisible(add);
            await tester.tap(add);
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('quantity_picker')), findsOneWidget, reason: 'picker $reason');
            expect(tester.takeException(), isNull, reason: 'picker $reason');
          }
        }
      }
    });
  });
}
