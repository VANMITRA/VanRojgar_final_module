import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/live_listings_repository.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json'});

final _honey = ShopProduct.fromJson({
  'productCode': 'honey',
  'categorySlug': 'forest-produce',
  'title': {'en': 'Honey', 'hi': 'शहद', 'mr': 'मध'},
  'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
  'listings': [],
});

void main() {
  test('my listings are read from the server (a sold-out or rejected listing counts as paused)', () async {
    final repo = LiveListingsRepository(V2ApiClient(
      baseUrl: 'https://s.test',
      client: MockClient((r) async => _json([
            {'_id': 'a', 'productCode': 'honey', 'quantityTotal': 100, 'quantitySold': 40, 'pricePerUnitPaise': 50000, 'mrpPerUnitPaise': 60000, 'minOrderQuantity': 2, 'fulfilment': 'pickup', 'status': 'active', 'createdAt': '2026-10-20T10:00:00.000Z'},
            {'_id': 'b', 'productCode': 'bamboo', 'quantityTotal': 10, 'pricePerUnitPaise': 1000, 'status': 'sold_out'},
          ])),
    ));
    final list = await repo.mine();
    expect(list, hasLength(2));
    expect(list.first.quantityAvailable, 60);
    expect(list.first.mrpPaise, 60000);
    expect(list.first.fulfilment, 'pickup');
    expect(list.first.isSample, false);
    expect(list.last.status, 'paused');
    expect(list.last.mrpPaise, 1000);
  });

  test('adding a listing sends the product, the category id and the seller confirmation', () async {
    final calls = <String>[];
    Map<String, dynamic>? body;
    final repo = LiveListingsRepository(V2ApiClient(
      baseUrl: 'https://s.test',
      client: MockClient((r) async {
        calls.add('${r.method} ${r.url.path}');
        if (r.url.path.endsWith('/categories')) {
          return _json([
            {'_id': 'c1', 'slug': 'fruit'},
            {'_id': 'c2', 'slug': 'forest-produce'},
          ]);
        }
        body = jsonDecode(r.body) as Map<String, dynamic>;
        return _json({'_id': 'new1', 'productCode': 'honey', 'quantityTotal': 30, 'pricePerUnitPaise': 50000, 'mrpPerUnitPaise': 60000, 'status': 'active'}, 201);
      }),
    ));
    final created = await repo.create(
      product: _honey,
      quantity: 30,
      mrpPaise: 60000,
      pricePaise: 50050,
      minOrderQuantity: 2,
      fulfilment: 'both',
      sustainableDeclared: true,
    );
    expect(created.id, 'new1');
    expect(body, {
      'titleMr': 'मध',
      'titleEn': 'Honey',
      'categoryId': 'c2',
      'productCode': 'honey',
      'quantityAvailable': 30,
      'unit': 'kg',
      'pricePerUnitRupees': 500.5,
      'mrpPerUnitRupees': 600.0,
      'minOrderQuantity': 2,
      'fulfilment': 'both',
      'sustainableDeclared': true,
    });
    // the categories are asked once
    await repo.create(product: _honey, quantity: 1, mrpPaise: 100, pricePaise: 100, minOrderQuantity: 1, fulfilment: 'pickup', sustainableDeclared: true);
    expect(calls.where((c) => c.endsWith('/categories')), hasLength(1));
  });

  test('a product group the server does not know is refused before anything is sent', () async {
    final repo = LiveListingsRepository(V2ApiClient(baseUrl: 'https://s.test', client: MockClient((r) async => _json([]))));
    await expectLater(
      repo.create(product: _honey, quantity: 1, mrpPaise: 100, pricePaise: 100, minOrderQuantity: 1, fulfilment: 'both', sustainableDeclared: true),
      throwsA(isA<V2ApiException>().having((e) => e.statusCode, 'status', 422)),
    );
  });

  test('change, pause and resume send the right requests; an unknown unit falls back to kg', () async {
    final seen = <String>[];
    Map<String, dynamic>? body;
    final repo = LiveListingsRepository(V2ApiClient(
      baseUrl: 'https://s.test',
      client: MockClient((r) async {
        seen.add('${r.method} ${r.url.path}');
        body = r.body.isEmpty ? null : jsonDecode(r.body) as Map<String, dynamic>;
        return _json({});
      }),
    ));
    await repo.update('a', quantityAvailable: 20, pricePaise: 52500, fulfilment: 'delivery');
    expect(body, {'quantityAvailable': 20, 'pricePerUnitRupees': 525.0, 'fulfilment': 'delivery'});
    await repo.pause('a');
    expect(body, {'status': 'paused'});
    await repo.resume('a');
    expect(body, {'status': 'active'});
    expect(seen, ['PATCH /api/v1/listings/a', 'PATCH /api/v1/listings/a/status', 'PATCH /api/v1/listings/a/status']);
    final odd = ShopProduct.fromJson({'productCode': 'x', 'unit': {'en': 'tonne'}, 'title': {'en': 'X'}, 'listings': []});
    expect(serverUnitFor(odd), 'kg');
    expect(serverUnitFor(_honey), 'kg');
  });
}
