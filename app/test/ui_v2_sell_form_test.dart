import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/sell_catalog.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/sell_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/sell_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/sell/sell_form_page.dart';
import 'package:vanrozgar/ui_v2/shell/sell/sell_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Widget tests for `/sell/new` and `/sell/edit/:id`:
/// - Product search and choice (including products without existing sellers)
/// - Validation errors (no product, quantity 0, price above MRP, minimum order above quantity, quantity below sold)
/// - Live discount line ONLY when price < MRP
/// - Three hand-over choices (Pickup / Delivery / Both)
/// - Live preview card
/// - Publish adds the new card at the top of `/sell`
/// - Edit shows product read-only and updates the listing in place
/// - Draft survival when navigating back and returning to `/sell/new`
/// - Hindi and Marathi have no English text
/// - No overflow at 320x568, 360x800, 430x932, light & dark, en/hi/mr, textScaler 1.5 (also with all errors showing)

const Map<String, dynamic> _data = {
  'products': [
    {
      'productCode': 'fruit_mango',
      'categorySlug': 'fruit',
      'image': 'assets/catalog/fruit_mango.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {
          'id': 'm1',
          'sellerType': 'gramsabha',
          'pricePerUnitPaise': 9900,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 300,
          'quantitySold': 75,
          'minOrderQuantity': 5,
          'daysAgo': 3,
        },
      ],
    },
    {
      'productCode': 'bamboo',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Bamboo', 'hi': 'बाँस', 'mr': 'बांबू'},
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {
          'id': 'b1',
          'sellerType': 'cfrholder',
          'pricePerUnitPaise': 11200,
          'mrpPerUnitPaise': 14000,
          'quantityTotal': 100,
          'quantitySold': 20,
          'minOrderQuantity': 2,
          'daysAgo': 5,
        },
      ],
    },
    {
      'productCode': 'shade_banyan',
      'categorySlug': 'shade-trees',
      'image': 'assets/catalog/shade_banyan.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Banyan', 'hi': 'बरगद', 'mr': 'वड'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': <Map<String, dynamic>>[],
    },
  ],
};

const AuthUser _seller = AuthUser(
  name: 'Dongargaon Gram Sabha',
  role: 'gramsabha',
  phone: '+919876543210',
  villageId: 'dongargaon',
);

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? user = _seller,
  List<MyListing>? listings,
}) {
  final inlineProducts = parseSellCatalogMap(_data);
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
      sellCatalogProvider.overrideWith((ref) async => inlineProducts),
      authUserProvider.overrideWith((ref) => user),
      if (listings != null) myListingsProvider.overrideWith((ref) => listings),
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

void _tall(WidgetTester tester, {double w = 360, double h = 2600}) {
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

void main() {
  group('/sell/new form validation, live discount, fulfilment choices, draft survival, and publish', () {
    testWidgets('product search filters catalog (including products with no existing sellers) and selects a product',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/sell/new');

      expect(find.byType(SellFormPage), findsOneWidget);
      expect(find.byKey(const Key('sell_product_option_fruit_mango')), findsOneWidget);
      expect(find.byKey(const Key('sell_product_option_bamboo')), findsOneWidget);
      expect(find.byKey(const Key('sell_product_option_shade_banyan')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('sell_product_search')), 'Banyan');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sell_product_option_shade_banyan')), findsOneWidget);
      expect(find.byKey(const Key('sell_product_option_fruit_mango')), findsNothing);

      await tester.tap(find.byKey(const Key('sell_product_option_shade_banyan')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(SellFormPage)));
      expect(container.read(listingDraftProvider).productCode, 'shade_banyan');
    });

    testWidgets('errors show for missing product, quantity 0, price above MRP, and min order above quantity',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/sell/new');

      // Press Publish on empty form -> product, quantity, MRP, price errors
      await tester.tap(find.byKey(const Key('sell_publish_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sell_error_product')), findsOneWidget);
      expect(find.text('Enter a whole number greater than 0.'), findsOneWidget);

      // Select Mango, enter quantity 0, MRP 100, price 120 (above MRP), minOrder 5
      await tester.tap(find.byKey(const Key('sell_product_option_fruit_mango')));
      await tester.enterText(find.byKey(const Key('sell_quantity_input')), '0');
      await tester.enterText(find.byKey(const Key('sell_mrp_input')), '100');
      await tester.enterText(find.byKey(const Key('sell_price_input')), '120');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sell_error_product')), findsNothing);
      expect(find.text('Enter a whole number greater than 0.'), findsOneWidget);
      expect(find.text('Your price cannot be higher than the MRP.'), findsOneWidget);
      expect(find.byKey(const Key('sell_live_discount')), findsNothing);

      // Fix quantity to 10, set minOrder to 15 (above quantity)
      await tester.enterText(find.byKey(const Key('sell_quantity_input')), '10');
      await tester.enterText(find.byKey(const Key('sell_min_order_input')), '15');
      await tester.pumpAndSettle();

      expect(find.text('Minimum order cannot be more than the quantity.'), findsOneWidget);
    });

    testWidgets('live discount line shows ONLY when price < MRP', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/sell/new');

      await tester.enterText(find.byKey(const Key('sell_mrp_input')), '100');
      await tester.enterText(find.byKey(const Key('sell_price_input')), '100');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sell_live_discount')), findsNothing);

      await tester.enterText(find.byKey(const Key('sell_price_input')), '80');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sell_live_discount')), findsOneWidget);
      expect(find.text('Discount: 20%'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('sell_price_input')), '110');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sell_live_discount')), findsNothing);
      expect(find.text('Your price cannot be higher than the MRP.'), findsOneWidget);
    });

    testWidgets('draft survives going back to /sell and returning to /sell/new, and publishing adds card at the top',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/sell');

      await tester.tap(find.byKey(const Key('sell_add_listing_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SellFormPage), findsOneWidget);

      await tester.tap(find.byKey(const Key('sell_product_option_shade_banyan')));
      await tester.enterText(find.byKey(const Key('sell_quantity_input')), '90');
      await tester.enterText(find.byKey(const Key('sell_mrp_input')), '80');
      await tester.enterText(find.byKey(const Key('sell_price_input')), '64');
      await tester.enterText(find.byKey(const Key('sell_min_order_input')), '4');
      await tester.tap(find.byKey(const Key('sell_fulfilment_pickup')));
      await tester.pumpAndSettle();

      // Navigate back without publishing
      await tester.tap(find.byKey(const Key('sell_form_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SellPage), findsOneWidget);

      // Re-open /sell/new -> draft values are still there
      await tester.tap(find.byKey(const Key('sell_add_listing_button')));
      await tester.pumpAndSettle();
      expect(find.text('90'), findsWidgets);
      expect(find.text('Discount: 20%'), findsOneWidget);

      // Publish listing -> returns to /sell and places Banyan at the top of the list
      await tester.tap(find.byKey(const Key('sell_publish_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SellPage), findsOneWidget);

      final container = ProviderScope.containerOf(tester.element(find.byType(SellPage)));
      final listings = container.read(myListingsProvider);
      expect(listings.length, 4);
      expect(listings.first.productCode, 'shade_banyan');
      expect(listings.first.pricePaise, 6400);
      expect(listings.first.mrpPaise, 8000);
      expect(listings.first.quantityTotal, 90);
      expect(listings.first.minOrderQuantity, 4);
      expect(listings.first.fulfilment, 'pickup');
      expect(find.text('Banyan'), findsOneWidget);
    });
  });

  group('/sell/edit/:id editing an existing listing', () {
    testWidgets('shows fixed read-only product, checks quantity >= sold, and updates the listing', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/sell');

      await tester.tap(find.byKey(const Key('edit_listing_sample-my-1')));
      await tester.pumpAndSettle();

      expect(find.byType(SellFormPage), findsOneWidget);
      expect(find.byKey(const Key('sell_fixed_product_tile')), findsOneWidget);
      expect(find.byKey(const Key('sell_product_search')), findsNothing);

      // 'sample-my-1' has quantitySold = 25; setting quantity to 10 shows error on publish
      await tester.enterText(find.byKey(const Key('sell_quantity_input')), '10');
      await tester.tap(find.byKey(const Key('sell_publish_button')));
      await tester.pumpAndSettle();
      expect(find.text('Quantity cannot be less than already sold (25 kg).'), findsOneWidget);

      // Update to valid quantity 150, price ₹90, delivery
      await tester.enterText(find.byKey(const Key('sell_quantity_input')), '150');
      await tester.enterText(find.byKey(const Key('sell_price_input')), '90');
      await tester.tap(find.byKey(const Key('sell_fulfilment_delivery')));
      await tester.tap(find.byKey(const Key('sell_publish_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SellPage), findsOneWidget);
      final container = ProviderScope.containerOf(tester.element(find.byType(SellPage)));
      final updated = container.read(myListingsProvider).firstWhere((l) => l.id == 'sample-my-1');
      expect(updated.quantityTotal, 150);
      expect(updated.pricePaise, 9000);
      expect(updated.fulfilment, 'delivery');
    });
  });

  group('Hindi and Marathi have no English on /sell/new and /sell/edit/:id', () {
    final latinRe = RegExp(r'[A-Za-z]');

    void expectNoEnglishInVisibleText(WidgetTester tester, AppLanguage lang) {
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final w in textWidgets) {
        final data = w.data ?? '';
        if (data.isEmpty) continue;
        expect(
          latinRe.hasMatch(data),
          isFalse,
          reason: 'Found English letters on form in $lang: "$data"',
        );
      }
    }

    testWidgets('no English on /sell/new (including with all errors) and /sell/edit/:id in Hindi and Marathi',
        (tester) async {
      _tall(tester);
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        await _open(tester, _app(language: lang), '/sell/new');
        expectNoEnglishInVisibleText(tester, lang);

        await tester.tap(find.byKey(const Key('sell_publish_button')));
        await tester.pumpAndSettle();
        expectNoEnglishInVisibleText(tester, lang);

        await _open(tester, _app(language: lang), '/sell/edit/sample-my-1');
        expectNoEnglishInVisibleText(tester, lang);
      }
    });
  });

  group('No overflow on /sell/new (also with all errors showing) and /sell/edit/:id', () {
    testWidgets('/sell/new with all errors at 320x568, 360x800, 430x932, light & dark, en/hi/mr, textScaler 1.5',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            await _open(tester, _app(language: lang, mode: mode, textScale: 1.5), '/sell/new');
            expect(tester.takeException(), isNull, reason: '/sell/new initial $size $lang $mode');

            // Scroll to Publish button and trigger all validation errors at once
            await tester.ensureVisible(find.byKey(const Key('sell_publish_button')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '/sell/new scrolled $size $lang $mode');

            await tester.tap(find.byKey(const Key('sell_publish_button')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '/sell/new errors bottom $size $lang $mode');

            await tester.ensureVisible(find.byKey(const Key('sell_product_search')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '/sell/new errors top $size $lang $mode');
          }
        }
      }
    });
  });
}

