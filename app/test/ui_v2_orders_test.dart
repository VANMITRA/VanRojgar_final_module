import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/orders_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/auth_pages.dart';
import 'package:vanrozgar/ui_v2/shell/orders/order_detail_page.dart';
import 'package:vanrozgar/ui_v2/shell/orders/orders_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// Phase 7 widget tests: Orders tab (`/orders`), Order detail (`/orders/:id`), buyer & seller
/// actions, confirmation sheets, Hindi/Marathi localization, and multi-size overflow checks.
/// Uses small inline data only.

const Map<String, dynamic> _catalogData = {
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
          'sellerId': 'seller-1',
          'sellerName': 'Sample Gram Sabha 1',
          'fulfilment': 'both',
          'sellerType': 'gramsabha',
          'pricePerUnitPaise': 9400,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 150,
          'quantitySold': 15,
          'minOrderQuantity': 5,
          'daysAgo': 2,
        },
      ],
    },
  ],
};

const AuthUser _buyerUser = AuthUser(
  name: 'Asha',
  role: 'buyer',
  phone: '+919876543210',
);

const AuthUser _sellerUser = AuthUser(
  name: 'Dongargaon Sabha',
  role: 'gramsabha',
  phone: '+919876500001',
  villageId: 'dongargaon',
);

List<OrderView> _testOrders() => [
      OrderView(
        id: 'ord-1001',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Sample Buyer',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'delivery',
        dropVillageId: 'dongargaon',
        paymentMethod: 'upi',
        note: 'Sample request for wholesale market supply',
        status: OrderStatus.pending,
        lines: const [
          OrderLine(
            productCode: 'fruit_mango',
            title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 10,
            unitPricePaise: 9400,
            mrpPerUnitPaise: 12000,
            minOrderQuantity: 5,
            availableStock: 100,
          ),
          OrderLine(
            productCode: 'fruit_awla',
            title: {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 5,
            unitPricePaise: 6000,
            mrpPerUnitPaise: 6000,
            minOrderQuantity: 5,
            availableStock: 200,
          ),
        ],
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 26, 10, 0),
          ),
        ],
      ),
      OrderView(
        id: 'ord-1002',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Sample Buyer',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'pickup',
        paymentMethod: 'upi',
        status: OrderStatus.countered,
        lines: const [
          OrderLine(
            productCode: 'fruit_karvand',
            title: {'en': 'Karonda', 'hi': 'करौंदा', 'mr': 'करवंद'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 25,
            unitPricePaise: 9600,
            mrpPerUnitPaise: 12500,
            minOrderQuantity: 5,
            availableStock: 32,
          ),
        ],
        counterOffer: const OrderCounterOffer(
          quantity: 20,
          unitPricePaise: 9000,
          note: 'Current harvest stock is 20 kg at ₹90 per kg',
        ),
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 24, 9, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.countered,
            at: DateTime.utc(2026, 10, 24, 14, 0),
            note: 'Current harvest stock is 20 kg at ₹90 per kg',
          ),
        ],
      ),
      OrderView(
        id: 'ord-1003',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Sample Buyer',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'delivery',
        dropVillageId: 'ambai',
        paymentMethod: 'upi',
        status: OrderStatus.approved,
        lines: const [
          OrderLine(
            productCode: 'fruit_khirni',
            title: {'en': 'Khirni', 'hi': 'खिरनी', 'mr': 'खिरणी'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 10,
            unitPricePaise: 9700,
            mrpPerUnitPaise: 12600,
            minOrderQuantity: 5,
            availableStock: 300,
          ),
        ],
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 23, 11, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.approved,
            at: DateTime.utc(2026, 10, 23, 15, 0),
          ),
        ],
      ),
      OrderView(
        id: 'ord-1004',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Sample Buyer',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'pickup',
        paymentMethod: 'upi',
        paymentReference: '430198765432',
        status: OrderStatus.paymentReported,
        lines: const [
          OrderLine(
            productCode: 'fruit_kawath',
            title: {'en': 'Wood apple', 'hi': 'कैथ', 'mr': 'कवठ'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 15,
            unitPricePaise: 6200,
            mrpPerUnitPaise: 6200,
            minOrderQuantity: 5,
            availableStock: 180,
          ),
        ],
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 21, 8, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.approved,
            at: DateTime.utc(2026, 10, 21, 12, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.paymentReported,
            at: DateTime.utc(2026, 10, 21, 16, 0),
            note: '430198765432',
          ),
        ],
      ),
      OrderView(
        id: 'ord-1006',
        sellerId: 'seller-1',
        sellerName: 'Sample Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Sample Buyer',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'pickup',
        paymentMethod: 'cod',
        status: OrderStatus.completed,
        lines: const [
          OrderLine(
            productCode: 'fruit_awla',
            title: {'en': 'Amla', 'hi': 'आँवला', 'mr': 'आवळा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 20,
            unitPricePaise: 6000,
            mrpPerUnitPaise: 6000,
            minOrderQuantity: 5,
            availableStock: 450,
          ),
        ],
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 14, 9, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.approved,
            at: DateTime.utc(2026, 10, 14, 11, 0),
          ),
          OrderStatusEvent(
            status: OrderStatus.completed,
            at: DateTime.utc(2026, 10, 15, 16, 0),
          ),
        ],
      ),
    ];

Widget _app({
  AppLanguage language = AppLanguage.en,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  AuthUser? user,
  List<OrderView>? orders,
}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => language),
      uiV2ThemeModeProvider.overrideWith((ref) => mode),
      shopRepositoryProvider.overrideWithValue(SampleShopRepository.fromMap(_catalogData)),
      authUserProvider.overrideWith((ref) => user),
      ordersProvider.overrideWith((ref) => orders ?? _testOrders()),
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

/// Asserts that no visible Text widget contains any English word (except "UPI").
void _expectNoEnglishWordsExceptUpi(WidgetTester tester) {
  final wordRe = RegExp(r'[A-Za-z]+');
  for (final widget in tester.widgetList<Text>(find.byType(Text))) {
    final text = widget.data ?? '';
    for (final match in wordRe.allMatches(text)) {
      final word = match.group(0)!;
      expect(
        word,
        equals('UPI'),
        reason: 'Unexpected English word "$word" found in Text("$text")',
      );
    }
  }
}

void main() {
  group('Orders tab (/orders): guest, buyer, seller, and empty states', () {
    testWidgets('guest sees the sign-in card and buttons navigate to /signin and /signup',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: null), '/orders');
      expect(find.byType(OrdersPage), findsOneWidget);
      expect(find.byKey(const Key('orders_guest_card')), findsOneWidget);
      expect(find.text('Sign in to see your orders'), findsOneWidget);
      expect(find.byKey(const Key('orders_seg_active')), findsNothing);

      await tester.tap(find.byKey(const Key('orders_guest_signin')));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);

      await _open(tester, _app(user: null), '/orders');
      await tester.tap(find.byKey(const Key('orders_guest_signup')));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('buyer sees Active and Past segments, cards open /orders/:id, and empty states show',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _buyerUser), '/orders');

      expect(find.byKey(const Key('orders_seg_active')), findsOneWidget);
      expect(find.byKey(const Key('orders_seg_past')), findsOneWidget);
      expect(find.text('Mango x 10 kg + 1 more'), findsOneWidget);
      expect(find.text('Waiting for the seller'), findsOneWidget);
      expect(find.text('Seller sent another offer'), findsOneWidget);

      // Switch to Past segment
      await tester.tap(find.byKey(const Key('orders_seg_past')));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Amla x 20 kg'), findsOneWidget);

      // Tapping a card opens the detail page
      await tester.tap(find.byKey(const Key('order_card_ord-1006')));
      await tester.pumpAndSettle();
      expect(find.byType(OrderDetailPage), findsOneWidget);

      // Empty states for buyer
      await _open(tester, _app(user: _buyerUser, orders: const []), '/orders');
      expect(find.text('No active orders right now.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('orders_seg_past')));
      await tester.pumpAndSettle();
      expect(find.text('No past orders yet.'), findsOneWidget);
    });

    testWidgets('seller sees New requests, In progress, and Done segments and empty states',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _sellerUser), '/orders');

      expect(find.byKey(const Key('orders_seg_new')), findsOneWidget);
      expect(find.byKey(const Key('orders_seg_in_progress')), findsOneWidget);
      expect(find.byKey(const Key('orders_seg_done')), findsOneWidget);

      // New requests: ord-1001 (pending) with buyer name
      expect(find.byKey(const Key('order_card_ord-1001')), findsOneWidget);
      expect(find.text('Sample Buyer'), findsWidgets);

      // In progress: ord-1002, ord-1003, ord-1004
      await tester.tap(find.byKey(const Key('orders_seg_in_progress')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('order_card_ord-1002')), findsOneWidget);
      expect(find.byKey(const Key('order_card_ord-1003')), findsOneWidget);
      expect(find.byKey(const Key('order_card_ord-1004')), findsOneWidget);

      // Done: ord-1006
      await tester.tap(find.byKey(const Key('orders_seg_done')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('order_card_ord-1006')), findsOneWidget);

      // Empty states for seller
      await _open(tester, _app(user: _sellerUser, orders: const []), '/orders');
      expect(find.text('No new requests waiting for you.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('orders_seg_in_progress')));
      await tester.pumpAndSettle();
      expect(find.text('No orders in progress right now.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('orders_seg_done')));
      await tester.pumpAndSettle();
      expect(find.text('No completed or closed requests yet.'), findsOneWidget);
    });
  });

  group('Order detail (/orders/:id): buyer actions', () {
    testWidgets('pending order shows Cancel request, asks to confirm first, and cancels on confirm',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _buyerUser), '/orders/ord-1001');

      expect(find.byKey(const Key('order_action_cancel')), findsOneWidget);
      expect(find.byKey(const Key('order_action_approve')), findsNothing);

      // Tap Cancel request -> confirmation sheet opens
      await tester.tap(find.byKey(const Key('order_action_cancel')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cancel_order_sheet')), findsOneWidget);
      expect(find.text('Cancel this request?'), findsOneWidget);

      // Keep request keeps it pending
      await tester.tap(find.byKey(const Key('cancel_order_keep')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cancel_order_sheet')), findsNothing);
      expect(find.text('Waiting for the seller'), findsWidgets);

      // Confirm cancel transitions to Cancelled and hides the Cancel button
      await tester.tap(find.byKey(const Key('order_action_cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cancel_order_confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled'), findsWidgets);
      expect(find.byKey(const Key('order_action_cancel')), findsNothing);
    });

    testWidgets('countered order lets buyer accept or decline the seller offer', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _buyerUser), '/orders/ord-1002');

      expect(find.byKey(const Key('order_counter_offer_card')), findsOneWidget);
      expect(find.text('20 kg at ₹90 per kg'), findsOneWidget);
      expect(find.byKey(const Key('order_action_accept_counter')), findsOneWidget);
      expect(find.byKey(const Key('order_action_decline_counter')), findsOneWidget);

      // Accept offer -> becomes Approved, total updates to 20 * ₹90 = ₹1,800, and "I have paid" appears
      await tester.tap(find.byKey(const Key('order_action_accept_counter')));
      await tester.pumpAndSettle();
      expect(find.text('Approved'), findsWidgets);
      expect(find.text('₹1,800'), findsWidgets);
      expect(find.byKey(const Key('order_action_paid')), findsOneWidget);

      // Decline offer on a fresh countered order -> becomes Cancelled
      await _open(tester, _app(user: _buyerUser), '/orders/ord-1002');
      await tester.tap(find.byKey(const Key('order_action_decline_counter')));
      await tester.pumpAndSettle();
      expect(find.text('Cancelled'), findsWidgets);
    });

    testWidgets('approved UPI order shows "I have paid" and validates 6 to 30 character reference',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _buyerUser), '/orders/ord-1003');

      expect(find.byKey(const Key('order_action_paid')), findsOneWidget);
      await tester.tap(find.byKey(const Key('order_action_paid')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('paid_reference_sheet')), findsOneWidget);

      // Too short (< 6 chars) shows validation error
      await tester.enterText(find.byKey(const Key('paid_reference_input')), '12345');
      await tester.tap(find.byKey(const Key('paid_reference_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a reference between 6 and 30 characters.'), findsOneWidget);

      // Valid reference updates status to Payment reported and shows reference
      await tester.enterText(find.byKey(const Key('paid_reference_input')), '430199887766');
      await tester.tap(find.byKey(const Key('paid_reference_submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('paid_reference_sheet')), findsNothing);
      expect(find.text('Payment reported'), findsWidgets);
      expect(find.text('430199887766'), findsWidgets);
    });
  });

  group('Order detail (/orders/:id): seller actions', () {
    testWidgets('seller can approve a pending request', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _sellerUser), '/orders/ord-1001');

      expect(find.byKey(const Key('order_action_approve')), findsOneWidget);
      expect(find.byKey(const Key('order_action_counter')), findsOneWidget);
      expect(find.byKey(const Key('order_action_reject')), findsOneWidget);

      await tester.tap(find.byKey(const Key('order_action_approve')));
      await tester.pumpAndSettle();
      expect(find.text('Approved'), findsWidgets);
      expect(find.byKey(const Key('order_action_approve')), findsNothing);
    });

    testWidgets('seller reject sheet requires a reason before rejecting', (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _sellerUser), '/orders/ord-1001');

      await tester.tap(find.byKey(const Key('order_action_reject')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reject_order_sheet')), findsOneWidget);

      // Empty reason -> shows error
      await tester.tap(find.byKey(const Key('reject_order_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a reason.'), findsOneWidget);

      // Enter reason and confirm -> status becomes Rejected
      await tester.enterText(
        find.byKey(const Key('reject_reason_input')),
        'Harvest batch already sold to local mandi',
      );
      await tester.tap(find.byKey(const Key('reject_order_submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reject_order_sheet')), findsNothing);
      expect(find.text('Rejected'), findsWidgets);
      expect(find.text('Harvest batch already sold to local mandi'), findsWidgets);
    });

    testWidgets('seller counter sheet validates quantity (min..stock) and price (<= MRP)',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _sellerUser), '/orders/ord-1001');

      await tester.tap(find.byKey(const Key('order_action_counter')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('counter_offer_sheet')), findsOneWidget);

      // Below minimum order (3 < 5) and above MRP (150 > 120)
      await tester.enterText(find.byKey(const Key('counter_qty_input')), '3');
      await tester.enterText(find.byKey(const Key('counter_price_input')), '150');
      await tester.tap(find.byKey(const Key('counter_offer_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Quantity must be between 5 and 100 kg.'), findsOneWidget);
      expect(find.text('Price must be at least ₹1 and at most MRP (₹120).'), findsOneWidget);

      // Above stock (150 > 100)
      await tester.enterText(find.byKey(const Key('counter_qty_input')), '150');
      await tester.enterText(find.byKey(const Key('counter_price_input')), '90');
      await tester.tap(find.byKey(const Key('counter_offer_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Quantity must be between 5 and 100 kg.'), findsOneWidget);

      // Valid quantity (20) and price (90 <= 120)
      await tester.enterText(find.byKey(const Key('counter_qty_input')), '20');
      await tester.enterText(find.byKey(const Key('counter_price_input')), '90');
      await tester.tap(find.byKey(const Key('counter_offer_submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('counter_offer_sheet')), findsNothing);
      expect(find.text('Seller sent another offer'), findsWidgets);
      expect(find.text('20 kg at ₹90 per kg'), findsOneWidget);
    });

    testWidgets('seller confirms reported UPI payment and then marks order completed',
        (tester) async {
      _tall(tester);
      await _open(tester, _app(user: _sellerUser), '/orders/ord-1004');

      expect(find.byKey(const Key('order_action_confirm_payment')), findsOneWidget);
      expect(find.byKey(const Key('order_action_mark_completed')), findsNothing);

      // Confirm payment received -> status becomes Payment confirmed, Mark completed appears
      await tester.tap(find.byKey(const Key('order_action_confirm_payment')));
      await tester.pumpAndSettle();
      expect(find.text('Payment confirmed'), findsWidgets);
      expect(find.byKey(const Key('order_action_mark_completed')), findsOneWidget);

      // Mark completed -> status becomes Completed
      await tester.tap(find.byKey(const Key('order_action_mark_completed')));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsWidgets);
      expect(find.byKey(const Key('order_action_mark_completed')), findsNothing);
    });
  });

  group('Hindi and Marathi: no English on /orders, /orders/:id, and sheets (except "UPI")', () {
    testWidgets('Hindi and Marathi have zero English words on Orders tab, detail page, and all sheets',
        (tester) async {
      _tall(tester);
      for (final lang in [AppLanguage.hi, AppLanguage.mr]) {
        // 1. Guest /orders
        await _open(tester, _app(language: lang, user: null), '/orders');
        _expectNoEnglishWordsExceptUpi(tester);

        // 2. Buyer /orders (Active & Past)
        await _open(tester, _app(language: lang, user: _buyerUser), '/orders');
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('orders_seg_past')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);

        // 3. Seller /orders (New, In progress, Done)
        await _open(tester, _app(language: lang, user: _sellerUser), '/orders');
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('orders_seg_in_progress')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('orders_seg_done')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);

        // 4. Buyer detail + Cancel sheet + Payment reference sheet
        await _open(tester, _app(language: lang, user: _buyerUser), '/orders/ord-1001');
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('order_action_cancel')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('cancel_order_keep')));
        await tester.pumpAndSettle();

        await _open(tester, _app(language: lang, user: _buyerUser), '/orders/ord-1003');
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('order_action_paid')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('paid_reference_cancel')));
        await tester.pumpAndSettle();

        // 5. Seller detail + Reject sheet + Counter sheet
        await _open(tester, _app(language: lang, user: _sellerUser), '/orders/ord-1001');
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('order_action_reject')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('reject_order_cancel')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('order_action_counter')));
        await tester.pumpAndSettle();
        _expectNoEnglishWordsExceptUpi(tester);
        await tester.tap(find.byKey(const Key('counter_offer_cancel')));
        await tester.pumpAndSettle();
      }
    });
  });

  group('No overflow across sizes, themes, languages, roles, statuses, and sheets at textScaler 1.5', () {
    testWidgets('/orders (3 roles), /orders/:id (3 statuses), and sheets at 320x568, 360x800, 430x932',
        (tester) async {
      const sizes = [Size(320, 568), Size(360, 800), Size(430, 932)];
      final roles = <AuthUser?>[null, _buyerUser, _sellerUser];
      const detailPaths = ['/orders/ord-1001', '/orders/ord-1002', '/orders/ord-1003'];

      for (final size in sizes) {
        for (final lang in AppLanguage.values) {
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            _tall(tester, w: size.width, h: size.height);
            final ctx = '${size.width}x${size.height} $lang $mode';

            // 1. /orders across 3 roles (guest, buyer, seller)
            for (final roleUser in roles) {
              await _open(
                tester,
                _app(language: lang, mode: mode, textScale: 1.5, user: roleUser),
                '/orders',
              );
              expect(tester.takeException(), isNull, reason: '/orders role=${roleUser?.role} $ctx');
            }

            // 2. /orders/:id across 3 statuses (pending, countered, approved)
            for (final path in detailPaths) {
              await _open(
                tester,
                _app(language: lang, mode: mode, textScale: 1.5, user: _buyerUser),
                path,
              );
              expect(tester.takeException(), isNull, reason: '$path buyer $ctx');
              await tester.ensureVisible(find.byKey(const Key('order_detail_timeline_card')));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: '$path buyer bottom $ctx');
            }

            // 3. Sheets on /orders/ord-1001 (seller counter & reject sheets) and /orders/ord-1003 (buyer paid sheet)
            await _open(
              tester,
              _app(language: lang, mode: mode, textScale: 1.5, user: _sellerUser),
              '/orders/ord-1001',
            );
            expect(tester.takeException(), isNull, reason: 'seller detail $ctx');

            final counterBtn = find.byKey(const Key('order_action_counter'));
            await tester.ensureVisible(counterBtn);
            await tester.pumpAndSettle();
            await tester.tap(counterBtn);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'counter sheet $ctx');
            final counterCancel = find.byKey(const Key('counter_offer_cancel'));
            await tester.ensureVisible(counterCancel);
            await tester.tap(counterCancel);
            await tester.pumpAndSettle();

            final rejectBtn = find.byKey(const Key('order_action_reject'));
            await tester.ensureVisible(rejectBtn);
            await tester.pumpAndSettle();
            await tester.tap(rejectBtn);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'reject sheet $ctx');
            final rejectCancel = find.byKey(const Key('reject_order_cancel'));
            await tester.ensureVisible(rejectCancel);
            await tester.tap(rejectCancel);
            await tester.pumpAndSettle();

            await _open(
              tester,
              _app(language: lang, mode: mode, textScale: 1.5, user: _buyerUser),
              '/orders/ord-1003',
            );
            final paidBtn = find.byKey(const Key('order_action_paid'));
            await tester.ensureVisible(paidBtn);
            await tester.pumpAndSettle();
            await tester.tap(paidBtn);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'paid sheet $ctx');
            final paidCancel = find.byKey(const Key('paid_reference_cancel'));
            await tester.ensureVisible(paidCancel);
            await tester.tap(paidCancel);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });
}

