import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/cart_page.dart';
import 'package:vanrozgar/ui_v2/shell/product_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Tests for the floating cart pill, the Cart page, the Product page and sign in / create account.
/// Only small inline data is used (no asset files are read).

const Map<String, dynamic> _data = {
  'products': [
    {
      'productCode': 'bamboo_basket',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Bamboo basket', 'hi': 'बाँस की टोकरी', 'mr': 'बांबूची टोपली'},
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {'id': 'b1', 'sellerType': 'gramsabha', 'pricePerUnitPaise': 7000, 'mrpPerUnitPaise': 8000, 'quantityTotal': 50, 'quantitySold': 10, 'minOrderQuantity': 1, 'daysAgo': 1},
      ],
    },
    {
      'productCode': 'fruit_mango',
      'categorySlug': 'fruit',
      'image': 'assets/catalog/fruit_mango.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {'id': 'm1', 'sellerType': 'gramsabha', 'pricePerUnitPaise': 9900, 'mrpPerUnitPaise': 12000, 'quantityTotal': 300, 'quantitySold': 75, 'minOrderQuantity': 5, 'daysAgo': 3},
        {'id': 'm2', 'sellerType': 'cfrholder', 'pricePerUnitPaise': 9400, 'mrpPerUnitPaise': 9400, 'quantityTotal': 150, 'quantitySold': 15, 'minOrderQuantity': 5, 'daysAgo': 2},
      ],
    },
    {
      'productCode': 'herb_behda',
      'categorySlug': 'medicinal-plants',
      'image': 'assets/catalog/herb_behda.jpg',
      'pictureNote': 'ready, check later',
      'notForEating': false,
      'title': {'en': 'Baheda', 'hi': 'बहेड़ा', 'mr': 'बेहडा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {'id': 'h1', 'sellerType': 'cfrholder', 'pricePerUnitPaise': 8000, 'mrpPerUnitPaise': 9000, 'quantityTotal': 100, 'quantitySold': 20, 'minOrderQuantity': 5, 'daysAgo': 5},
      ],
    },
  ],
};

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  Map<String, int>? cart,
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
      if (cart != null) cartQuantitiesProvider.overrideWith((ref) => cart),
      if (cart != null) lastAddedImageProvider.overrideWith((ref) => 'assets/catalog/fruit_mango.jpg'),
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
  // remove any previous app first, so provider overrides (for example the language) are not reused
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('Navigation and the floating cart pill', () {
    testWidgets('the bottom navigation has 4 destinations and no Cart tab or badge', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/');
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('the pill grows from a circle, shows the count, and opens the Cart page', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/');
      expect(find.byKey(const Key('floating_cart_pill')), findsNothing);

      await tester.tap(find.text('ADD').first);
      await tester.pump(); // first frame: still a circle
      final circleWidth = tester.getSize(find.byKey(const Key('floating_cart_pill'))).width;
      expect(circleWidth, lessThanOrEqualTo(60.0));
      await tester.pumpAndSettle();
      final pillWidth = tester.getSize(find.byKey(const Key('floating_cart_pill'))).width;
      expect(pillWidth, greaterThanOrEqualTo(150.0));
      expect(find.text('View cart'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);

      // it hovers above the bottom navigation
      final pillBottom = tester.getBottomLeft(find.byKey(const Key('floating_cart_pill'))).dy;
      final navTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
      expect(pillBottom, lessThanOrEqualTo(navTop - 8.0));

      // a second product
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();
      expect(find.text('2 items'), findsOneWidget);

      // tap the pill: the Cart page lists both lines
      await tester.tap(find.byKey(const Key('floating_cart_pill')));
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(2));

      // remove every line with "-" : the empty state shows
      while (find.byIcon(Icons.remove).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pumpAndSettle();
        // at the seller's minimum a message asks first; choose "Remove"
        if (find.byKey(const Key('min_order_remove')).evaluate().isNotEmpty) {
          await tester.tap(find.byKey(const Key('min_order_remove')));
          await tester.pumpAndSettle();
        }
      }
      expect(find.text('Your cart is empty.'), findsOneWidget);
      await tester.tap(find.text('Continue shopping'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(ProviderScope.containerOf(tester.element(find.byType(NavigationBar))).read(cartItemCountProvider), 0);
      expect(find.byKey(const Key('floating_cart_pill')), findsNothing);
    });

    testWidgets('with reduce motion the pill is complete at once', (tester) async {
      _tall(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await _open(tester, _app(), '/');
      await tester.tap(find.text('ADD').first);
      await tester.pump();
      await tester.pump();
      expect(tester.getSize(find.byKey(const Key('floating_cart_pill'))).width, greaterThanOrEqualTo(150.0));
    });

    testWidgets('the pill is hidden while the keyboard is open', (tester) async {
      _tall(tester);
      await _open(tester, _app(cart: {'fruit_mango': 5}), '/');
      expect(find.byKey(const Key('floating_cart_pill')), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('floating_cart_pill')), findsNothing);
    });
  });

  group('Minimum order message', () {
    testWidgets('above the minimum "-" just lowers the quantity; at the minimum a message asks first',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/');
      // Mango: the seller's minimum order is 5 kg
      await tester.tap(find.text('ADD').at(1)); // second card in Top Deals = Mango (best discount order)
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(NavigationBar)));
      final code = container.read(cartQuantitiesProvider).keys.first;
      final minOrder = code == 'fruit_mango' ? 5 : 1;

      // go above the minimum, then come back down: no message
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      expect(container.read(cartQuantitiesProvider)[code], minOrder + 1);
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('min_order_dialog')), findsNothing);
      expect(container.read(cartQuantitiesProvider)[code], minOrder);

      // at the minimum: the message appears and the item is still in the cart
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('min_order_dialog')), findsOneWidget);
      expect(find.text('Minimum order'), findsOneWidget);
      expect(container.read(cartQuantitiesProvider)[code], minOrder);

      // "Keep in cart": the dialog closes, the quantity stays
      await tester.tap(find.byKey(const Key('min_order_keep')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('min_order_dialog')), findsNothing);
      expect(container.read(cartQuantitiesProvider)[code], minOrder);

      // "Remove": the item leaves the cart
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('min_order_remove')));
      await tester.pumpAndSettle();
      expect(container.read(cartQuantitiesProvider).containsKey(code), isFalse);
    });

    testWidgets('the message names the minimum in the right language (Mango, 5 kg) and works on the Cart page',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(cart: {'fruit_mango': 5}), '/cart');
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(
        find.text("The seller's minimum order for Mango is 5 kg. You can keep 5 kg in your cart or remove it."),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('min_order_keep')));
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget); // still in the cart

      // Hindi: no English in the message
      await _open(tester, _app(language: AppLanguage.hi, cart: {'fruit_mango': 5}), '/cart');
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(find.text('Minimum order'), findsNothing);
      expect(find.text('न्यूनतम ऑर्डर'), findsOneWidget);
      expect(find.text('Keep in cart'), findsNothing);
      expect(find.text('कार्ट में रखें'), findsOneWidget);
      expect(find.text('हटाएँ'), findsOneWidget);
    });
  });

  group('Product page', () {
    testWidgets('a card opens the Product page with the sellers, cheapest first, and Add to cart', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/');
      await tester.tap(find.text('Mango').first);
      await tester.pumpAndSettle();
      expect(find.byType(ProductPage), findsOneWidget);
      expect(find.text('Sellers (2)'), findsOneWidget);
      expect(find.text('Lowest price'), findsOneWidget);
      expect(find.text('Sample'), findsWidgets);

      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsWidgets); // minimum order of the cheapest seller
      expect(find.text('View cart'), findsOneWidget); // the bar button now opens the cart

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductPage), findsNothing);
      expect(find.byKey(const Key('floating_cart_pill')), findsOneWidget);
    });

    testWidgets('a picture marked "check later" shows the Illustration tag', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/product/herb_behda');
      expect(find.text('Illustration'), findsOneWidget);
    });
  });

  group('Sign in and create account', () {
    testWidgets('create account validates, then signs in, signs out, and signs in again', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/profile');
      expect(find.text('You are browsing as a guest'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile_signup')));
      await tester.pumpAndSettle();

      // empty form: all errors show
      await tester.tap(find.byKey(const Key('signup_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(find.text('Enter a valid 10-digit mobile number.'), findsOneWidget);
      expect(find.text('PIN must be exactly 6 digits.'), findsOneWidget);

      // a Gram Sabha needs a village
      await tester.tap(find.byKey(const Key('role_gramsabha')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('signup_village')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('signup_name')), 'Asha Patil');
      await tester.enterText(find.byKey(const Key('signup_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('signup_pin')), '123456');
      await tester.tap(find.byKey(const Key('signup_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Choose your village.'), findsWidgets);

      await tester.tap(find.byKey(const Key('signup_village')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dongargaon, Deola').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('signup_submit')));
      await tester.pumpAndSettle();

      // back on the Profile page, signed in
      expect(find.text('Hello, Asha Patil'), findsOneWidget);

      await tester.tap(find.byKey(const Key('signout_button')));
      await tester.pumpAndSettle();
      expect(find.text('You are browsing as a guest'), findsOneWidget);

      // sign in: wrong PIN, unknown number, then the right PIN
      await tester.tap(find.byKey(const Key('profile_signin')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('signin_pin')), '000000');
      await tester.tap(find.byKey(const Key('signin_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Wrong PIN.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('signin_phone')), '9123456780');
      await tester.tap(find.byKey(const Key('signin_submit')));
      await tester.pumpAndSettle();
      expect(find.text('No account found. Please create an account.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
      await tester.tap(find.byKey(const Key('signin_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Asha Patil'), findsOneWidget);
    });

    testWidgets('Google is the first option and says it is coming soon', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/signin');
      final googleY = tester.getTopLeft(find.byKey(const Key('google_button'))).dy;
      final phoneY = tester.getTopLeft(find.byKey(const Key('signin_phone'))).dy;
      expect(googleY, lessThan(phoneY));
      await tester.tap(find.byKey(const Key('google_button')));
      await tester.pump();
      expect(find.text('Google sign-in is coming soon.'), findsOneWidget);
    });

    testWidgets('English is the default; switching to Hindi leaves no English on the pages', (tester) async {
      _tall(tester);
      await _open(tester, _app(), '/signin');
      expect(find.text('Sign in'), findsWidgets);
      await tester.tap(find.text('हिं'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsNothing);
      expect(find.text('साइन इन करें'), findsWidgets);
      expect(find.text('Mobile number'), findsNothing);
      expect(find.text('मोबाइल नंबर'), findsOneWidget);

      uiV2Router.go('/signup');
      await tester.pumpAndSettle();
      expect(find.text('Create account'), findsNothing);
      expect(find.text('खाता बनाएँ'), findsWidgets);
      expect(find.text('Buyer'), findsNothing);
      expect(find.text('खरीदार'), findsOneWidget);
    });
  });

  group('No overflow on the new pages', () {
    testWidgets('pill, Cart page, Product page and the two sign-in pages at 3 sizes, 3 languages, light and dark, text x1.5',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            for (final path in ['/', '/cart', '/product/fruit_mango', '/signin', '/signup', '/profile']) {
              await _open(
                tester,
                _app(language: lang, mode: mode, textScale: 1.5, cart: {'fruit_mango': 5, 'bamboo_basket': 1}),
                path,
              );
              expect(tester.takeException(), isNull, reason: '$path ${size.width}x${size.height} $lang $mode');
            }
          }
        }
      }
    });
  });
}
