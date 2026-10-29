import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/server_mapping.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/live_shop_repository.dart';
import 'package:vanrozgar/ui_v2/l10n/app_strings.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';

/// The shop with real server data: the answers of the server (faked here) become the products the screens read.

Map<String, dynamic> _listing(String id, String owner, String name, int price, int mrp, int total, int sold, {int min = 1}) => {
      '_id': id,
      'ownerId': owner,
      'ownerType': 'gramsabha',
      'pricePerUnitPaise': price,
      'mrpPerUnitPaise': mrp,
      'quantityTotal': total,
      'quantitySold': sold,
      'quantityAvailable': total - sold,
      'minOrderQuantity': min,
      'fulfilment': 'both',
      'village': 'Dongargaon',
      'isSample': true, // an old flag on the server: the app must ignore it
      'createdAt': '2026-10-20T10:00:00.000Z',
      'seller': {'ownerId': owner, 'name': name, 'type': 'gramsabha', 'village': 'Dongargaon', 'taluka': 'Peth'},
    };

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json; charset=utf-8'});

Future<http.Response> Function(http.Request) _handler({int? failStatus}) {
  return (req) async {
    if (failStatus != null) {
      return http.Response(jsonEncode({'success': false, 'error': {'code': 'NOPE', 'message': 'Not allowed'}}), failStatus);
    }
    final path = req.url.path;
    if (path.endsWith('/shop/products')) {
      return _json({
        'products': [
          {
            'productCode': 'honey',
            'title': {'en': 'Honey', 'mr': 'मध'},
            'category': {'slug': 'forest-produce'},
            'unit': 'kg',
          },
          {'productCode': '', 'title': {'en': 'No code'}, 'unit': 'kg'},
        ],
      });
    }
    if (path.endsWith('/shop/products/honey/sellers')) {
      return _json({
        'sellers': [
          _listing('l1', 'u1', 'Dongargaon Gram Sabha', 50000, 60000, 100, 25, min: 2),
          _listing('l2', 'u2', 'Asha Patil', 52000, 52000, 40, 0),
        ],
      });
    }
    return http.Response('{}', 404);
  };
}

MockClient _server({int? failStatus}) => MockClient(_handler(failStatus: failStatus));

void main() {
  group('server mapping', () {
    test('a server listing becomes a catalog listing and the old sample flag is ignored', () {
      final m = listingMapFromServer(_listing('l1', 'u1', 'Dongargaon Gram Sabha', 50000, 60000, 100, 25, min: 2),
          now: DateTime.utc(2026, 10, 22, 10));
      expect(m['id'], 'l1');
      expect(m['sellerId'], 'u1');
      expect(m['sellerName'], 'Dongargaon Gram Sabha');
      expect(m['sellerType'], 'gramsabha');
      expect(m['quantityTotal'], 100);
      expect(m['quantitySold'], 25);
      expect(m['minOrderQuantity'], 2);
      expect(m['daysAgo'], 2);
      expect(m['isSample'], false);
    });

    test('a seller without a name shows the village; an old villager is a CFR holder; no MRP means no discount', () {
      final m = listingMapFromServer({
        '_id': 'x',
        'ownerId': 'u9',
        'ownerType': 'villager',
        'pricePerUnitPaise': 1000,
        'village': 'Harsul',
        'quantityTotal': 5,
        'quantitySold': 0,
      });
      expect(m['sellerName'], 'Harsul');
      expect(m['sellerType'], 'cfrholder');
      expect(m['mrpPerUnitPaise'], 1000);
    });

    test('units are named in three languages', () {
      expect(unitNames('kg'), {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'});
      expect(unitNames('xyz')['hi'], 'xyz');
    });
  });

  group('product codes and the product list the app carries', () {
    test('app codes with underscores and server codes with hyphens convert both ways', () {
      expect(serverProductCode('fruit_mango'), 'fruit-mango');
      expect(appProductCode('fruit-mango'), 'fruit_mango');
      expect(appProductCode('timber-pandhara-khair'), 'timber_pandhara_khair');
      expect(appProductCode('bamboo'), 'bamboo');
      expect(appProductCode('honey'), 'honey');
      expect(appProductCode('leaf-plate'), 'leaf-plate');
    });

    test('the Hindi name and the picture come from the app, what the server sends wins', () {
      final m = productMapFromServer(
        {'productCode': 'fruit-mango', 'title': {'en': 'Mango', 'mr': 'आंबा'}, 'category': {'slug': 'fruit'}, 'unit': 'kg'},
        const [],
        bundled: {
          'fruit_mango': {
            'image': 'assets/catalog/fruit_mango.jpg',
            'pictureNote': 'ready, check later',
            'title': {'en': 'Mango (old)', 'hi': 'आम', 'mr': 'आम'},
          },
        },
      );
      expect(m['productCode'], 'fruit_mango');
      expect(m['image'], 'assets/catalog/fruit_mango.jpg');
      expect(m['title'], {'en': 'Mango', 'mr': 'आंबा', 'hi': 'आम'});
      expect(ShopProduct.fromJson(m).isIllustration, true);
    });

    test('a product the app has no picture for still works', () {
      final m = productMapFromServer({'productCode': 'honey', 'title': {'en': 'Honey'}, 'unit': 'kg'}, const []);
      expect(m['image'], 'assets/catalog/honey.jpg');
      expect(m['title'], {'en': 'Honey', 'mr': 'Honey', 'hi': 'Honey'});
    });
  });

  group('live shop repository', () {
    test('builds products with their sellers from the server answers (a product without a code is left out)', () async {
      final repo = LiveShopRepository(V2ApiClient(baseUrl: 'https://shop.test', client: _server()));
      final products = await repo.getProducts();
      expect(products, hasLength(1));
      final honey = products.single;
      expect(honey.productCode, 'honey');
      expect(honey.localizedTitle(AppLanguage.mr), 'मध');
      expect(honey.localizedTitle(AppLanguage.hi), 'Honey'); // no Hindi title on the server: English is shown
      expect(honey.listings, hasLength(2));
      expect(honey.startingAtPaise, 50000);
      expect(honey.cheapestListing!.quantityAvailable, 75);
      expect(honey.bestDiscountPercent, 17);
    });

    test('the home feed is built from the same data', () async {
      final repo = LiveShopRepository(V2ApiClient(baseUrl: 'https://shop.test', client: _server()));
      final home = await repo.getHome();
      expect(home.openListings, 2);
      expect(home.topDeals.single.productCode, 'honey');
      expect(home.bestSellers.single.listing.id, 'l1');
    });

    test('answers are kept for a while, and refresh() asks the server again', () async {
      var calls = 0;
      final counting = MockClient((req) async {
        calls++;
        return _handler()(req);
      });
      var now = DateTime.utc(2026, 10, 29, 10);
      final repo = LiveShopRepository(V2ApiClient(baseUrl: 'https://shop.test', client: counting), clock: () => now);
      await repo.getProducts();
      final first = calls;
      await repo.getProducts();
      expect(calls, first);
      now = now.add(const Duration(seconds: 31));
      await repo.getProducts();
      expect(calls, greaterThan(first));
      final before = calls;
      repo.refresh();
      await repo.getProducts();
      expect(calls, greaterThan(before));
    });

    test('a server error is reported with its code and message', () async {
      final repo = LiveShopRepository(V2ApiClient(baseUrl: 'https://shop.test', client: _server(failStatus: 403)));
      await expectLater(
        repo.getProducts(),
        throwsA(isA<V2ApiException>().having((e) => e.code, 'code', 'NOPE').having((e) => e.statusCode, 'status', 403)),
      );
    });

    test('no network is reported as a network problem', () async {
      final down = MockClient((req) async => throw http.ClientException('no route'));
      final repo = LiveShopRepository(V2ApiClient(baseUrl: 'https://shop.test', client: down));
      await expectLater(repo.getProducts(), throwsA(isA<V2NetworkException>()));
    });
  });

  group('api client', () {
    test('adds /api/v1, the sign-in token and drops empty query values', () async {
      late http.Request seen;
      final client = V2ApiClient(
        baseUrl: 'https://shop.test/',
        tokenProvider: () async => 'tok',
        client: MockClient((req) async {
          seen = req;
          return _json({'ok': true});
        }),
      );
      final data = await client.get('/shop/stock', query: {'ids': 'a,b', 'x': '', 'y': null});
      expect(data, {'ok': true});
      expect(seen.url.toString(), 'https://shop.test/api/v1/shop/stock?ids=a%2Cb');
      expect(seen.headers['Authorization'], 'Bearer tok');
    });

    test('a 204 answer returns null', () async {
      final client = V2ApiClient(baseUrl: 'https://shop.test/api/v1', client: MockClient((req) async => http.Response('', 204)));
      expect(await client.post('/auth/logout'), isNull);
    });
  });
}
