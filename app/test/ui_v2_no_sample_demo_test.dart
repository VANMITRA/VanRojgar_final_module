import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/sell_catalog.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';
import 'package:vanrozgar/ui_v2/models/sell_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/orders_providers.dart';
import 'package:vanrozgar/ui_v2/providers/sell_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

const Map<String, dynamic> _inlineData = {
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
          'sellerName': 'Dongargaon Gram Sabha 1',
          'sellerType': 'gramsabha',
          'fulfilment': 'both',
          'pricePerUnitPaise': 9000,
          'mrpPerUnitPaise': 12000,
          'quantityTotal': 100,
          'quantitySold': 20,
          'minOrderQuantity': 2,
          'daysAgo': 2,
        },
      ],
    },
    {
      'productCode': 'bamboo_basket',
      'categorySlug': 'handicrafts-bamboo',
      'image': 'assets/catalog/bamboo.jpg',
      'pictureNote': 'ready',
      'notForEating': false,
      'title': {
        'en': 'Bamboo basket',
        'hi': 'बाँस की टोकरी',
        'mr': 'बांबूची टोपली',
      },
      'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
      'listings': [
        {
          'id': 'b1',
          'sellerId': 'seller-1',
          'sellerName': 'Dongargaon Gram Sabha 1',
          'sellerType': 'gramsabha',
          'fulfilment': 'both',
          'pricePerUnitPaise': 7000,
          'mrpPerUnitPaise': 9000,
          'quantityTotal': 50,
          'quantitySold': 10,
          'minOrderQuantity': 1,
          'daysAgo': 1,
        },
      ],
    },
  ],
};

const AuthUser _sellerUser = AuthUser(
  name: 'Dongargaon Sabha',
  role: 'gramsabha',
  phone: '+919876543210',
  villageId: 'dongargaon',
);

List<OrderView> _inlineOrders() => [
      OrderView(
        id: 'ord-1',
        sellerId: 'seller-1',
        sellerName: 'Dongargaon Gram Sabha 1',
        sellerType: 'gramsabha',
        buyerName: 'Asha Patil',
        buyerPhone: '+919876543210',
        isSample: true,
        isDemoBuyer: true,
        deliveryPref: 'delivery',
        dropVillageId: 'dongargaon',
        paymentMethod: 'upi',
        status: OrderStatus.pending,
        lines: const [
          OrderLine(
            productCode: 'fruit_mango',
            title: {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
            unit: {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
            quantity: 5,
            unitPricePaise: 9000,
            mrpPerUnitPaise: 12000,
            minOrderQuantity: 2,
            availableStock: 80,
          ),
        ],
        events: [
          OrderStatusEvent(
            status: OrderStatus.pending,
            at: DateTime.utc(2026, 10, 26, 10, 0),
          ),
        ],
      ),
    ];

List<MyListing> _inlineListings() => [
      MyListing(
        id: 'my-1',
        productCode: 'fruit_mango',
        quantityTotal: 100,
        quantitySold: 20,
        mrpPaise: 12000,
        pricePaise: 9000,
        minOrderQuantity: 2,
        fulfilment: 'both',
        status: 'active',
        createdAt: DateTime.utc(2026, 10, 20),
        isSample: true,
      ),
    ];

Widget _buildApp(AppLanguage lang) {
  final inlineCatalog = parseSellCatalogMap(_inlineData);
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => lang),
      uiV2ThemeModeProvider.overrideWith((ref) => ThemeMode.light),
      shopRepositoryProvider.overrideWithValue(
        SampleShopRepository.fromMap(_inlineData),
      ),
      sellCatalogProvider.overrideWith((ref) async => inlineCatalog),
      authUserProvider.overrideWith((ref) => _sellerUser),
      cartQuantitiesProvider.overrideWith((ref) => {'fruit_mango': 2}),
      ordersProvider.overrideWith((ref) => _inlineOrders()),
      myListingsProvider.overrideWith((ref) => _inlineListings()),
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      routerConfig: uiV2Router,
    ),
  );
}

void _assertNoSampleOrDemo(WidgetTester tester, String route, AppLanguage lang) {
  final forbidden = RegExp(
    r'(sample|demo|नमूना|नमुना|डेमो)',
    caseSensitive: false,
  );
  for (final widget in tester.widgetList<Text>(find.byType(Text))) {
    final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
    expect(
      forbidden.hasMatch(text),
      isFalse,
      reason: 'Forbidden sample/demo text "$text" found on $route ($lang)',
    );
  }
}

void main() {
  testWidgets(
    'No visible text contains Sample or Demo across Home, Product, Cart, Checkout, Orders, Sell, and Profile in EN, HI, MR',
    (tester) async {
      tester.view.physicalSize = const Size(720, 3600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const routes = <String>[
        '/home',
        '/product/fruit_mango',
        '/cart',
        '/checkout',
        '/orders',
        '/orders/ord-1',
        '/sell',
        '/sell/new',
        '/profile',
        '/about',
        '/credits',
      ];

      for (final lang in AppLanguage.values) {
        uiV2LandingSeen.value = true;
        uiV2Router.go('/home');
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_buildApp(lang));
        await tester.pumpAndSettle();

        for (final route in routes) {
          uiV2Router.go(route);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$route ($lang)');
          _assertNoSampleOrDemo(tester, route, lang);
        }
      }
    },
  );
}
