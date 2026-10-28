import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/l10n/checkout_strings.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/checkout_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/cart_page.dart';
import 'package:vanrozgar/ui_v2/shell/checkout/checkout_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Phase 6 widget tests for Cart grouping, Change-seller sheet, Checkout, Guest gate,
/// Request sending, Success page, Hindi/Marathi localization and zero-overflow matrix.
/// Only small inline data is used (no asset files are read).

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
        // Listed out of price order to test cheapest-first sorting in the sheet
        {
          'id': 'm2',
          'sellerId': 'seller-2',
          'sellerName': 'Sample CFR holder 2',
          'sellerType': 'cfrholder',
          'fulfilment': 'pickup',
          'pricePerUnitPaise': 10500,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 40,
          'quantitySold': 10, // 30 left
          'minOrderQuantity': 6,
          'daysAgo': 2,
        },
        {
          'id': 'm1',
          'sellerId': 'seller-1',
          'sellerName': 'Sample Gram Sabha 1',
          'sellerType': 'gramsabha',
          'fulfilment': 'both',
          'pricePerUnitPaise': 9000,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 100,
          'quantitySold': 20, // 80 left
          'minOrderQuantity': 2,
          'daysAgo': 3,
        },
        {
          'id': 'm3',
          'sellerId': 'seller-3',
          'sellerName': 'Sample Gram Sabha 3',
          'sellerType': 'gramsabha',
          'fulfilment': 'delivery',
          'pricePerUnitPaise': 11500,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 15,
          'quantitySold': 11, // 4 left
          'minOrderQuantity': 2,
          'daysAgo': 1,
        },
      ],
    },
    {
      'productCode': 'bamboo_basket',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Bamboo basket', 'hi': 'बाँस की टोकरी', 'mr': 'बांबूची टोपली'},
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {
          'id': 'b1',
          'sellerId': 'seller-1',
          'sellerName': 'Sample Gram Sabha 1',
          'sellerType': 'gramsabha',
          'fulfilment': 'both',
          'pricePerUnitPaise': 7000,
          'mrpPerUnitPaise': 8000,
          'quantityTotal': 50,
          'quantitySold': 10, // 40 left
          'minOrderQuantity': 1,
          'daysAgo': 1,
        },
      ],
    },
    {
      'productCode': 'herb_behda',
      'categorySlug': 'medicinal-plants',
      'image': 'assets/catalog/herb_behda.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {'en': 'Baheda', 'hi': 'बहेड़ा', 'mr': 'बेहडा'},
      'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
      'listings': [
        {
          'id': 'h1',
          'sellerId': 'seller-2',
          'sellerName': 'Sample CFR holder 2',
          'sellerType': 'cfrholder',
          'fulfilment': 'pickup',
          'pricePerUnitPaise': 8000,
          'mrpPerUnitPaise': 9000,
          'quantityTotal': 60,
          'quantitySold': 10, // 50 left
          'minOrderQuantity': 2,
          'daysAgo': 5,
        },
        {
          'id': 'h2',
          'sellerId': 'seller-3',
          'sellerName': 'Sample Gram Sabha 3',
          'sellerType': 'gramsabha',
          'fulfilment': 'delivery',
          'pricePerUnitPaise': 9500,
          'mrpPerUnitPaise': 10000,
          'quantityTotal': 50,
          'quantitySold': 10, // 40 left
          'minOrderQuantity': 2,
          'daysAgo': 4,
        },
      ],
    },
  ],
};

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  Map<String, int>? cart,
  Map<String, String>? sellerChoices,
  AuthUser? user,
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_data)),
      if (cart != null) cartQuantitiesProvider.overrideWith((ref) => cart),
      if (cart != null && cart.isNotEmpty)
        lastAddedImageProvider.overrideWith((ref) => 'assets/catalog/fruit_mango.jpg'),
      if (sellerChoices != null)
        cartSellerChoiceProvider.overrideWith((ref) => sellerChoices),
      if (user != null) authUserProvider.overrideWith((ref) => user),
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
  group('1. Cart grouping by seller and totals', () {
    testWidgets(
        'groups lines by seller under one header, shows seller subtotals, grand total and "2 sellers · 2 separate requests"',
        (tester) async {
      _tall(tester);
      // fruit_mango (qty 2 @ ₹90 = ₹180) and bamboo_basket (qty 1 @ ₹70 = ₹70) both belong to seller-1 (subtotal ₹250)
      // herb_behda (qty 2 @ ₹80 = ₹160) belongs to seller-2 (subtotal ₹160)
      // Grand total = ₹410
      await _open(
        tester,
        _app(cart: {'fruit_mango': 2, 'bamboo_basket': 1, 'herb_behda': 2}),
        '/cart',
      );

      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byKey(const Key('cart_seller_group_seller-1')), findsOneWidget);
      expect(find.byKey(const Key('cart_seller_group_seller-2')), findsOneWidget);
      expect(find.text('Sample Gram Sabha 1'), findsOneWidget);
      expect(find.text('Sample CFR holder 2'), findsOneWidget);

      // Seller subtotals
      expect(
        tester.widget<Text>(find.byKey(const Key('seller_subtotal_seller-1'))).data,
        '₹250',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('seller_subtotal_seller-2'))).data,
        '₹160',
      );

      // Sticky bottom bar: Total ₹410 and "2 sellers · 2 separate requests"
      expect(
        tester.widget<Text>(find.byKey(const Key('cart_grand_total'))).data,
        'Total ₹410',
      );
      expect(find.text('2 sellers · 2 separate requests'), findsOneWidget);
      expect(
        find.text(
          'Each seller approves your request, or counters with another quantity or price. Each seller is paid separately.',
        ),
        findsOneWidget,
      );
    });
  });

  group('2. Change seller sheet, quantity clamping and min-order dialog', () {
    testWidgets(
        'lists sellers cheapest first with Lowest price, updates price/groups/totals, clamps to minOrder and stock, and "-" uses chosen seller minOrder',
        (tester) async {
      _tall(tester);
      // Start with fruit_mango qty 3 (seller-1 @ ₹90, minOrder 2) and herb_behda qty 2 (seller-2 @ ₹80)
      await _open(
        tester,
        _app(cart: {'fruit_mango': 3, 'herb_behda': 2}),
        '/cart',
      );

      expect(find.byKey(const Key('cart_seller_group_seller-1')), findsOneWidget);
      expect(find.byKey(const Key('cart_seller_group_seller-2')), findsOneWidget);

      // Open "Change seller" sheet for fruit_mango
      await tester.tap(find.byKey(const Key('change_seller_fruit_mango')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('change_seller_sheet')), findsOneWidget);
      expect(find.text('Choose a seller'), findsOneWidget);
      expect(find.text('Lowest price'), findsOneWidget);

      // Check cheapest-first order: m1 (₹90) < m2 (₹105) < m3 (₹115)
      final yM1 = tester.getTopLeft(find.byKey(const Key('seller_option_m1'))).dy;
      final yM2 = tester.getTopLeft(find.byKey(const Key('seller_option_m2'))).dy;
      final yM3 = tester.getTopLeft(find.byKey(const Key('seller_option_m3'))).dy;
      expect(yM1, lessThan(yM2));
      expect(yM2, lessThan(yM3));

      // Choose m2 (seller-2, ₹105, minOrder 6):
      // 1) Qty 3 is below minOrder 6 -> raised to 6 with inline note
      // 2) Both fruit_mango and herb_behda now belong to seller-2 -> 1 seller group!
      await tester.tap(find.byKey(const Key('seller_option_m2')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(CartPage)));
      expect(container.read(cartSellerChoiceProvider)['fruit_mango'], 'm2');
      expect(container.read(cartQuantitiesProvider)['fruit_mango'], 6);
      expect(find.byKey(const Key('clamp_note_fruit_mango')), findsOneWidget);
      expect(find.text('Quantity raised to minimum order (6 kg).'), findsOneWidget);

      // Only 1 seller group now (seller-2): 6 * ₹105 (₹630) + 2 * ₹80 (₹160) = ₹790
      expect(find.byKey(const Key('cart_seller_group_seller-1')), findsNothing);
      expect(find.byKey(const Key('cart_seller_group_seller-2')), findsOneWidget);
      expect(find.text('1 seller · 1 request'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('cart_grand_total'))).data,
        'Total ₹790',
      );

      // Pressing "-" on fruit_mango at quantity 6 (chosen seller m2's minOrder is 6, even though cheapest m1 is 2)
      // MUST open the minimum-order dialog!
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('min_order_dialog')), findsOneWidget);
      expect(
        find.text(
          "The seller's minimum order for Mango is 6 kg. You can keep 6 kg in your cart or remove it.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('min_order_keep')));
      await tester.pumpAndSettle();

      // Now open "Change seller" for fruit_mango and choose m3 (seller-3, stock = 4 left):
      // Qty 6 is above stock 4 -> lowered to 4 with inline note!
      await tester.tap(find.byKey(const Key('change_seller_fruit_mango')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('seller_option_m3')));
      await tester.pumpAndSettle();

      expect(container.read(cartSellerChoiceProvider)['fruit_mango'], 'm3');
      expect(container.read(cartQuantitiesProvider)['fruit_mango'], 4);
      expect(find.text('Quantity lowered to available stock (4 kg).'), findsOneWidget);
    });
  });

  group('3. Checkout availability, village validation, payment texts and note counter', () {
    testWidgets(
        'disables unsupported fulfilment with reason, blocks mixed pickup+delivery, validates village on delivery, shows payment texts and note counter',
        (tester) async {
      _tall(tester);

      // Case A: Cart with seller-1 ('both') and seller-2 ('pickup' only) -> Delivery is disabled
      await _open(
        tester,
        _app(
          cart: {'fruit_mango': 2, 'herb_behda': 2},
          user: const AuthUser(name: 'Test Buyer', role: 'buyer', phone: '+919876543210'),
        ),
        '/checkout',
      );
      expect(find.byType(CheckoutPage), findsOneWidget);
      expect(find.byKey(const Key('delivery_disabled_reason')), findsOneWidget);
      expect(find.text('Not offered by: Sample CFR holder 2'), findsOneWidget);

      // Case B: Mixed pickup-only (herb_behda -> h1, seller-2) + delivery-only (fruit_mango -> m3, seller-3)
      // Both Pickup and Delivery disabled, clear message shown, Send request button disabled
      await _open(
        tester,
        _app(
          cart: {'fruit_mango': 2, 'herb_behda': 2},
          sellerChoices: {'fruit_mango': 'm3', 'herb_behda': 'h1'},
          user: const AuthUser(name: 'Test Buyer', role: 'buyer', phone: '+919876543210'),
        ),
        '/checkout',
      );
      expect(find.byKey(const Key('pickup_disabled_reason')), findsOneWidget);
      expect(find.byKey(const Key('delivery_disabled_reason')), findsOneWidget);
      expect(find.byKey(const Key('checkout_mixed_fulfilment_error')), findsOneWidget);
      expect(
        find.text(
          'These sellers need different ways of receiving. Remove one product or change the seller.',
        ),
        findsOneWidget,
      );
      final sendBtnMixed = tester.widget<FilledButton>(find.byKey(const Key('checkout_send_button')));
      expect(sendBtnMixed.onPressed, isNull);

      // Case C: Cart with seller-1 ('both') -> both Pickup and Delivery enabled
      await _open(
        tester,
        _app(
          cart: {'fruit_mango': 2, 'bamboo_basket': 1},
          user: const AuthUser(name: 'Test Buyer', role: 'buyer', phone: '+919876543210'),
        ),
        '/checkout',
      );
      expect(find.byKey(const Key('checkout_mixed_fulfilment_error')), findsNothing);

      // Select Delivery -> village dropdown appears; tapping Send request without a village shows error
      await tester.tap(find.byKey(const Key('checkout_pref_delivery')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('checkout_village_dropdown')), findsOneWidget);

      await tester.tap(find.byKey(const Key('checkout_send_button')));
      await tester.pumpAndSettle();
      expect(find.text('Choose a village'), findsOneWidget);
      expect(find.byType(CheckoutPage), findsOneWidget);

      // Payment cards and their one-line explanation texts
      // Default is Cash on delivery
      expect(
        find.text('You pay in cash when you receive your order.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('checkout_pay_upi')));
      await tester.pumpAndSettle();
      expect(
        find.text('You pay by UPI after the seller approves your request.'),
        findsOneWidget,
      );

      // Note field and counter
      await tester.enterText(find.byKey(const Key('checkout_note_field')), 'Call before dispatch');
      await tester.pumpAndSettle();
      expect(find.text('20/300'), findsOneWidget);
    });
  });

  group('4. Guest gate and survival of checkout choices across sign-up', () {
    testWidgets(
        'guest pressing Send request opens gate sheet, nothing is sent, and choices survive after /signup',
        (tester) async {
      _tall(tester);
      await _open(
        tester,
        _app(cart: {'fruit_mango': 2, 'bamboo_basket': 1}),
        '/checkout',
      );

      // Choose Delivery + Dongargaon + UPI + Note
      await tester.tap(find.byKey(const Key('checkout_pref_delivery')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('checkout_village_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dongargaon').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('checkout_pay_upi')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('checkout_note_field')), 'Morning delivery please');
      await tester.pumpAndSettle();

      // Tap Send request as guest -> opens guest gate sheet
      await tester.tap(find.byKey(const Key('checkout_send_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('guest_gate_sheet')), findsOneWidget);
      expect(find.text('Sign in to send your request'), findsOneWidget);

      final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutPage)));
      expect(container.read(requestsProvider), isEmpty);

      // Dismiss with "Not now": choices are still there
      await tester.tap(find.byKey(const Key('guest_gate_not_now')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('guest_gate_sheet')), findsNothing);
      expect(container.read(checkoutChoicesProvider).deliveryPref, 'delivery');
      expect(container.read(checkoutChoicesProvider).dropVillageId, 'dongargaon');
      expect(container.read(checkoutChoicesProvider).paymentMethod, 'upi');
      expect(container.read(checkoutChoicesProvider).note, 'Morning delivery please');

      // Tap Send request again -> tap "Create account" -> complete /signup
      await tester.tap(find.byKey(const Key('checkout_send_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('guest_gate_signup')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('signup_name')), 'Kiran More');
      await tester.enterText(find.byKey(const Key('signup_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('signup_pin')), '123456');
      await tester.tap(find.byKey(const Key('signup_submit')));
      await tester.pumpAndSettle();
      // Let the 2-second "Account created. Welcome!" floating SnackBar dismiss so it does not cover the pill
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Now signed in on /profile; tap the floating cart pill -> /cart -> Continue -> /checkout
      expect(find.byKey(const Key('floating_cart_pill')), findsOneWidget);
      await tester.tap(find.byKey(const Key('floating_cart_pill')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cart_continue_button')));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPage), findsOneWidget);
      expect(find.text('Morning delivery please'), findsOneWidget);
      expect(
        find.text('You pay by UPI after the seller approves your request.'),
        findsOneWidget,
      );
      expect(find.text('Dongargaon'), findsOneWidget);
    });
  });

  group('5 & 6. Sending as signed-in user, success page, empty-cart redirect and direct entry', () {
    testWidgets(
        'creates one request per seller, clears cart & choices, hides pill, shows /checkout/done cards, and redirects empty /checkout to /cart',
        (tester) async {
      _tall(tester);
      const buyer = AuthUser(
        name: 'Meera Joshi',
        role: 'buyer',
        phone: '+919811122233',
      );

      // 2 sellers: seller-1 (fruit_mango qty 2 @ ₹90 = ₹180, bamboo_basket qty 1 @ ₹70 = ₹70 -> ₹250)
      // and seller-2 (herb_behda qty 2 @ ₹80 = ₹160)
      await _open(
        tester,
        _app(
          cart: {'fruit_mango': 2, 'bamboo_basket': 1, 'herb_behda': 2},
          user: buyer,
        ),
        '/checkout',
      );

      await tester.tap(find.byKey(const Key('checkout_send_button')));
      await tester.pumpAndSettle();

      // Landed on /checkout/done
      expect(find.byType(CheckoutDonePage), findsOneWidget);
      expect(find.text('Request sent'), findsOneWidget);
      expect(find.text('Waiting for the seller'), findsNWidgets(2));
      expect(find.byKey(const Key('request_card_req-1')), findsOneWidget);
      expect(find.byKey(const Key('request_card_req-2')), findsOneWidget);

      final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutDonePage)));
      final reqs = container.read(requestsProvider);
      expect(reqs.length, 2);
      expect(reqs[0].sellerId, 'seller-1');
      expect(reqs[0].totalPaise, 25000);
      expect(reqs[1].sellerId, 'seller-2');
      expect(reqs[1].totalPaise, 16000);

      // Cart and seller choices are cleared
      expect(container.read(cartQuantitiesProvider), isEmpty);
      expect(container.read(cartSellerChoiceProvider), isEmpty);

      // "Continue shopping" goes home and the floating cart pill is gone
      await tester.tap(find.byKey(const Key('done_continue_shopping')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('floating_cart_pill')), findsNothing);

      // Opening /checkout with an empty cart redirects to /cart
      uiV2Router.go('/checkout');
      await tester.pumpAndSettle();
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Your cart is empty.'), findsOneWidget);
    });

    testWidgets('direct entry to /checkout with a one-product cart renders properly', (tester) async {
      _tall(tester);
      await _open(tester, _app(cart: {'fruit_mango': 2}), '/checkout');
      expect(find.byType(CheckoutPage), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Mango × 2 kg'), findsOneWidget);
      expect(find.text('1 seller · 1 request'), findsOneWidget);
    });
  });

  group('7. Hindi and Marathi localization (no English except UPI)', () {
    testWidgets(
        'no English words on Cart, Change-seller sheet, Checkout, Guest gate sheet and CheckoutDonePage in Hindi and Marathi',
        (tester) async {
      _tall(tester);
      final englishForbidden = [
        'Change seller',
        'Choose a seller',
        'Continue',
        'Checkout',
        'Your requests',
        'How do you want to receive it?',
        'Pickup',
        'Delivery',
        'How will you pay?',
        'Cash on delivery',
        'Send request',
        'Sign in to send your request',
        'Not now',
        'Request sent',
        'Waiting for the seller',
        'Sample Gram Sabha 1',
        'Sample CFR holder 2',
      ];

      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        final strings = AppStrings.of(lang);

        // 1. Cart page + Change-seller sheet
        await _open(
          tester,
          _app(
            language: lang,
            cart: {'fruit_mango': 2, 'herb_behda': 2},
          ),
          '/cart',
        );
        for (final word in englishForbidden) {
          expect(find.text(word), findsNothing, reason: 'Cart ($lang) had English "$word"');
        }
        expect(find.text(strings.coContinue), findsOneWidget);

        await tester.tap(find.byKey(const Key('change_seller_fruit_mango')));
        await tester.pumpAndSettle();
        expect(find.text(strings.coChooseSeller), findsOneWidget);
        for (final word in englishForbidden) {
          expect(find.text(word), findsNothing, reason: 'Seller sheet ($lang) had English "$word"');
        }
        await tester.tap(find.byKey(const Key('change_seller_close')));
        await tester.pumpAndSettle();

        // 2. Checkout page + Guest gate sheet
        await tester.tap(find.byKey(const Key('cart_continue_button')));
        await tester.pumpAndSettle();
        expect(find.text(strings.coCheckoutTitle), findsOneWidget);
        expect(find.text('UPI'), findsOneWidget);
        for (final word in englishForbidden) {
          expect(find.text(word), findsNothing, reason: 'Checkout ($lang) had English "$word"');
        }

        await tester.tap(find.byKey(const Key('checkout_send_button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('guest_gate_sheet')), findsOneWidget);
        expect(find.text(strings.coSignInToSendTitle), findsOneWidget);
        for (final word in englishForbidden) {
          expect(find.text(word), findsNothing, reason: 'Guest sheet ($lang) had English "$word"');
        }
        await tester.tap(find.byKey(const Key('guest_gate_not_now')));
        await tester.pumpAndSettle();

        // 3. Submit as signed-in user -> /checkout/done
        await _open(
          tester,
          _app(
            language: lang,
            cart: {'fruit_mango': 2},
            user: const AuthUser(name: 'अजय', role: 'buyer', phone: '+919876543210'),
          ),
          '/checkout',
        );
        await tester.tap(find.byKey(const Key('checkout_send_button')));
        await tester.pumpAndSettle();
        expect(find.byType(CheckoutDonePage), findsOneWidget);
        expect(find.text(strings.coRequestSentTitle), findsOneWidget);
        expect(find.text(strings.coWaitingForSeller), findsOneWidget);
        for (final word in englishForbidden) {
          expect(find.text(word), findsNothing, reason: 'Done page ($lang) had English "$word"');
        }
      }
    });
  });

  group('8. No overflow across sizes, languages, themes and textScaler 1.5', () {
    testWidgets(
        '/cart, change-seller sheet, /checkout, guest sheet and /checkout/done at 320x568, 360x800 and 430x932 in light and dark, EN/HI/MR, textScaler 1.5',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            final ctx = '${size.width}x${size.height} $lang $mode';

            // 1. /cart + change-seller sheet
            await _open(
              tester,
              _app(
                language: lang,
                mode: mode,
                textScale: 1.5,
                cart: {'fruit_mango': 2, 'bamboo_basket': 1, 'herb_behda': 2},
              ),
              '/cart',
            );
            expect(tester.takeException(), isNull, reason: '/cart $ctx');

            final changeBtn = find.byKey(const Key('change_seller_fruit_mango'));
            await tester.ensureVisible(changeBtn);
            await tester.tap(changeBtn);
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('change_seller_sheet')), findsOneWidget, reason: 'sheet $ctx');
            expect(tester.takeException(), isNull, reason: 'change_seller_sheet $ctx');

            await tester.tap(find.byKey(const Key('change_seller_close')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'close sheet $ctx');

            // 2. /checkout + guest gate sheet
            await tester.tap(find.byKey(const Key('cart_continue_button')));
            await tester.pumpAndSettle();
            expect(find.byType(CheckoutPage), findsOneWidget, reason: '/checkout $ctx');
            expect(tester.takeException(), isNull, reason: '/checkout $ctx');

            await tester.tap(find.byKey(const Key('checkout_send_button')));
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('guest_gate_sheet')), findsOneWidget, reason: 'guest_gate $ctx');
            expect(tester.takeException(), isNull, reason: 'guest_gate $ctx');

            await tester.tap(find.byKey(const Key('guest_gate_not_now')));
            await tester.pumpAndSettle();

            // 3. Send as signed-in user -> /checkout/done
            await _open(
              tester,
              _app(
                language: lang,
                mode: mode,
                textScale: 1.5,
                cart: {'fruit_mango': 2, 'bamboo_basket': 1},
                user: const AuthUser(name: 'Ramesh', role: 'buyer', phone: '+919876543210'),
              ),
              '/checkout',
            );
            expect(tester.takeException(), isNull, reason: '/checkout signed-in $ctx');
            await tester.tap(find.byKey(const Key('checkout_send_button')));
            await tester.pumpAndSettle();
            expect(find.byType(CheckoutDonePage), findsOneWidget, reason: '/checkout/done $ctx');
            expect(tester.takeException(), isNull, reason: '/checkout/done $ctx');
          }
        }
      }
    });
  });
}

