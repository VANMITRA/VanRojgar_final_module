import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/checkout/checkout_page.dart';
import 'package:vanrozgar/ui_v2/shell/product_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Tests for Phase 5: choosing a seller, quantity from the seller's minimum, the bill, Add to cart,
/// Buy now (guest sign-in gate and return). Small inline data only.

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
        {'id': 'm1', 'sellerId': 's1', 'sellerName': 'Sample Seller One', 'fulfilment': 'pickup', 'sellerType': 'gramsabha', 'pricePerUnitPaise': 9900, 'mrpPerUnitPaise': 12000, 'quantityTotal': 300, 'quantitySold': 75, 'minOrderQuantity': 5, 'daysAgo': 3},
        {'id': 'm2', 'sellerId': 's2', 'sellerName': 'Sample Seller Two', 'fulfilment': 'both', 'sellerType': 'cfrholder', 'pricePerUnitPaise': 9400, 'mrpPerUnitPaise': 9400, 'quantityTotal': 150, 'quantitySold': 15, 'minOrderQuantity': 2, 'daysAgo': 2},
      ],
    },
  ],
};

Widget _app({AppLanguage language = AppLanguage.en, ThemeMode mode = ThemeMode.light, double textScale = 1.0, bool signedIn = false}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
      demoAccountsProvider.overrideWith((ref) => const {
        '9876543210': DemoAccount('123456', AuthUser(name: 'Asha', role: 'buyer', phone: '9876543210')),
      }),
      if (signedIn)
        authUserProvider.overrideWith((ref) => const AuthUser(name: 'Asha', role: 'buyer', phone: '9876543210')),
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

void main() {
  group('Product page: sellers, quantity and bill', () {
    testWidgets('the cheapest seller is selected first and the bill uses its minimum order', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('Sample Seller Two'), findsOneWidget);
      expect(find.text('Bill'), findsOneWidget);
      expect(find.text('₹94 × 2 kg'), findsOneWidget);
      expect(find.text('₹188'), findsOneWidget);
    });

    testWidgets('tapping another seller changes the price, the minimum and the bill', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      await tester.tap(find.text('Sample Seller One'));
      await tester.pumpAndSettle();
      expect(find.text('₹99 × 5 kg'), findsOneWidget);
      expect(find.text('₹495'), findsOneWidget);
    });

    testWidgets('the stepper changes the bill; "-" stops at the minimum before the item is in the cart', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('₹94 × 3 kg'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('₹94 × 2 kg'), findsOneWidget);
    });

    testWidgets('Add to cart stores the chosen seller and quantity; the button becomes View cart', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      await tester.tap(find.text('Sample Seller One'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(ProductPage)));
      expect(container.read(cartQuantitiesProvider)['fruit_mango'], 6);
      expect(container.read(cartSellerChoiceProvider)['fruit_mango'], 'm1');
      expect(find.text('View cart'), findsOneWidget);
    });
  });

  group('Product page: Buy now', () {
    testWidgets('a guest is asked to sign in; Not now stays on the page', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      await tester.tap(find.text('Buy now'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to place your order'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('a guest who signs in is brought back to the same product', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/fruit_mango');
      await tester.tap(find.text('Buy now'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
      await tester.tap(find.byKey(const Key('signin_submit')));
      await tester.pumpAndSettle();
      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('a signed-in buyer goes on to the checkout page with the item in the cart', (tester) async {
      _tall(tester);
      await _open(tester, _app(signedIn: true), '/product/fruit_mango');
      await tester.tap(find.text('Buy now'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutPage), findsOneWidget);
      final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutPage)));
      expect(container.read(cartQuantitiesProvider)['fruit_mango'], 2);
    });
  });

  group('Product page: layout', () {
    testWidgets('no overflow at 3 sizes, 3 languages, light and dark, text x1.5', (tester) async {
      for (final size in [const Size(320, 640), const Size(360, 800), const Size(412, 915)]) {
        for (final language in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            await _open(tester, _app(language: language, mode: mode, textScale: 1.5), '/product/fruit_mango');
            expect(tester.takeException(), isNull, reason: '$size $language $mode');
          }
        }
      }
    });
  });
}
