import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/live_shop_repository.dart';
import 'package:vanrozgar/ui_v2/data/token_storage.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/order_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/orders_providers.dart';
import 'package:vanrozgar/ui_v2/shell/app_shell.dart';
import 'package:vanrozgar/ui_v2/shell/checkout/checkout_done_page.dart';
import 'package:vanrozgar/ui_v2/theme/van_rozgar_theme.dart';

/// The whole shop against a faked server: sign in, send the cart, see the request in Orders.
/// The server is faked at the HTTP level, so this runs the real repositories and screens.

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json; charset=utf-8'});

class _FakeServer {
  final List<String> calls = [];
  Map<String, dynamic>? checkoutBody;
  Map<String, dynamic>? loginBody;
  bool refuseLogin = false;
  bool checkoutFails = false;
  bool offline = false;

  Map<String, dynamic> get _listing => {
        '_id': 'l1',
        'ownerId': 'u1',
        'ownerType': 'gramsabha',
        'pricePerUnitPaise': 9000,
        'mrpPerUnitPaise': 12000,
        'quantityTotal': 100,
        'quantitySold': 20,
        'minOrderQuantity': 2,
        'fulfilment': 'both',
        'village': 'Dongargaon',
        'createdAt': '2026-10-20T10:00:00.000Z',
        'seller': {'ownerId': 'u1', 'name': 'Dongargaon Gram Sabha', 'type': 'gramsabha', 'village': 'Dongargaon', 'taluka': 'Deola'},
      };

  Future<http.Response> handle(http.Request r) async {
    if (offline) throw http.ClientException('offline');
    final path = r.url.path.replaceFirst('/api/v1', '');
    calls.add('${r.method} $path');
    if (path == '/shop/products') {
      return _json({
        'products': [
          {'productCode': 'fruit_mango', 'title': {'en': 'Mango', 'mr': 'आंबा'}, 'category': {'slug': 'fruit'}, 'unit': 'kg'},
        ],
      });
    }
    if (path == '/shop/products/fruit_mango/sellers') return _json({'sellers': [_listing]});
    if (path == '/auth/login') {
      loginBody = jsonDecode(r.body) as Map<String, dynamic>;
      if (refuseLogin) {
        return http.Response(jsonEncode({'success': false, 'error': {'code': 'UNAUTHENTICATED', 'message': 'Invalid phone number or password'}}), 401);
      }
      return _json({'token': 'tok', 'user': {'name': 'Asha', 'role': 'buyer', 'phone': '+919876543210'}});
    }
    if (path == '/shop/cart/checkout') {
      if (checkoutFails) {
        return http.Response(jsonEncode({'success': false, 'error': {'code': 'CONFLICT', 'message': 'None could be requested'}}), 409);
      }
      checkoutBody = jsonDecode(r.body) as Map<String, dynamic>;
      return _json({
        'created': [
          {'listingId': 'l1', 'quantity': 3, 'request': {'_id': 'r1'}},
        ],
        'failed': [],
      }, 201);
    }
    if (path == '/requests') {
      return _json([
        {
          '_id': 'r1',
          'status': 'pending',
          'quantity': 3,
          'unit': 'kg',
          'deliveryPref': 'pickup',
          'paymentMethod': 'cod',
          'createdAt': '2026-10-29T10:00:00.000Z',
          'history': [],
          'listingId': {..._listing, 'productCode': 'fruit_mango', 'title': {'en': 'Mango'}, 'unit': 'kg', 'quantityAvailable': 80},
          'requesterId': {'_id': 'b', 'name': 'Asha', 'phone': '+919876543210'},
          'sellerId': {'_id': 'u1', 'name': 'Dongargaon Gram Sabha'},
        },
      ]);
    }
    if (path == '/orders') return _json([]);
    return http.Response('{}', 404);
  }
}

Widget _app(_FakeServer server, {Map<String, int>? cart}) {
  return ProviderScope(
    overrides: [
      uiV2LanguageProvider.overrideWith((ref) => AppLanguage.en),
      uiV2ThemeModeProvider.overrideWith((ref) => ThemeMode.light),
      shopApiClientProvider.overrideWith((ref) => V2ApiClient(
            baseUrl: 'https://shop.test',
            tokenProvider: MemoryTokenStorage().read,
            client: MockClient(server.handle),
          )),
      // the product list the app carries is read from an asset file, which a widget test cannot wait for
      shopRepositoryProvider.overrideWith(
        (ref) => LiveShopRepository(ref.watch(shopApiClientProvider)!, bundledProducts: () async => const {}),
      ),
      tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
      if (cart != null) cartQuantitiesProvider.overrideWith((ref) => cart),
    ],
    child: MaterialApp.router(
      theme: VanRozgarTheme.lightTheme,
      darkTheme: VanRozgarTheme.darkTheme,
      routerConfig: uiV2Router,
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget app, String path) async {
  tester.view.physicalSize = const Size(720, 3600);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  uiV2LandingSeen.value = true;
  uiV2Router.go(path);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the shop shows products from the server, not the bundled catalog', (tester) async {
    final server = _FakeServer();
    await _open(tester, _app(server), '/');
    expect(find.text('Mango'), findsWidgets);
    expect(server.calls, contains('GET /shop/products'));
    expect(find.text('Dongargaon Gram Sabha'), findsNothing); // sellers show on the product page, not on the card
  });

  testWidgets('sign in goes to the server with the phone and PIN and signs the user in', (tester) async {
    final server = _FakeServer();
    await _open(tester, _app(server), '/signin');
    await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
    await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
    await tester.tap(find.byKey(const Key('signin_submit')));
    await tester.pumpAndSettle();
    expect(server.loginBody, {'phone': '9876543210', 'password': '123456'});
    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    expect(container.read(authUserProvider)!.name, 'Asha');
  });

  testWidgets('a wrong PIN shows the message and does not sign in', (tester) async {
    final server = _FakeServer()..refuseLogin = true;
    await _open(tester, _app(server), '/signin');
    await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
    await tester.enterText(find.byKey(const Key('signin_pin')), '000000');
    await tester.tap(find.byKey(const Key('signin_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Mobile number or PIN is wrong.'), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    expect(container.read(authUserProvider), isNull);
  });

  testWidgets('no network on sign in shows the network message', (tester) async {
    final server = _FakeServer();
    await _open(tester, _app(server), '/signin');
    server.offline = true;
    await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
    await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
    await tester.tap(find.byKey(const Key('signin_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Cannot reach the server. Check your internet and try again.'), findsOneWidget);
  });

  testWidgets('sending the cart creates the request on the server, empties the cart and shows it in Orders', (tester) async {
    final server = _FakeServer();
    await _open(tester, _app(server, cart: {'fruit_mango': 3}), '/signin');
    await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
    await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
    await tester.tap(find.byKey(const Key('signin_submit')));
    await tester.pumpAndSettle();

    uiV2Router.go('/checkout');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout_send_button')));
    await tester.pumpAndSettle();

    expect(server.checkoutBody, {
      'items': [
        {'listingId': 'l1', 'quantity': 3},
      ],
      'deliveryPref': 'pickup',
      'paymentMethod': 'cod',
    });
    expect(find.byType(CheckoutDonePage), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(find.byType(CheckoutDonePage)));
    expect(container.read(cartQuantitiesProvider), isEmpty);

    uiV2Router.go('/orders');
    await tester.pumpAndSettle();
    expect(server.calls, contains('GET /requests'));
    final orders = container.read(ordersProvider);
    expect(orders.single.id, 'r1');
    expect(orders.single.status, OrderStatus.pending);
    expect(orders.single.sellerName, 'Dongargaon Gram Sabha');
    expect(tester.takeException(), isNull);
  });

  testWidgets('when the server refuses the whole cart nothing is cleared and the user stays on checkout', (tester) async {
    final server = _FakeServer()..checkoutFails = true;
    await _open(tester, _app(server, cart: {'fruit_mango': 3}), '/signin');
    await tester.enterText(find.byKey(const Key('signin_phone')), '9876543210');
    await tester.enterText(find.byKey(const Key('signin_pin')), '123456');
    await tester.tap(find.byKey(const Key('signin_submit')));
    await tester.pumpAndSettle();
    uiV2Router.go('/checkout');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout_send_button')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutDonePage), findsNothing);
    final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    expect(container.read(cartQuantitiesProvider), {'fruit_mango': 3});
  });
}
