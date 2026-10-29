import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanrozgar/ui_v2/api/v2_api_client.dart';
import 'package:vanrozgar/ui_v2/data/sell_catalog.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';
import 'package:vanrozgar/ui_v2/models/sell_models.dart';
import 'package:vanrozgar/ui_v2/providers/catalog_providers.dart';
import 'package:vanrozgar/ui_v2/providers/sell_live.dart';
import 'package:vanrozgar/ui_v2/providers/sell_providers.dart';

/// The Sell screens against a faked server: load, add (with the sustainability confirmation), pause, and a refusal.

http.Response _json(Object data, [int status = 200]) =>
    http.Response(jsonEncode({'success': true, 'data': data}), status, headers: {'content-type': 'application/json'});

final _honey = ShopProduct.fromJson({
  'productCode': 'honey',
  'categorySlug': 'forest-produce',
  'title': {'en': 'Honey', 'mr': 'मध'},
  'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
  'listings': [],
});

class _Server {
  final calls = <String>[];
  Map<String, dynamic>? lastBody;
  bool refuse = false;

  Future<http.Response> handle(http.Request r) async {
    final path = r.url.path.replaceFirst('/api/v1', '');
    calls.add('${r.method} $path');
    lastBody = r.body.isEmpty ? null : jsonDecode(r.body) as Map<String, dynamic>;
    if (refuse && r.method != 'GET') {
      return http.Response(jsonEncode({'success': false, 'error': {'code': 'FORBIDDEN', 'message': 'no'}}), 403);
    }
    if (path == '/listings/mine') {
      return _json([
        {'_id': 'a', 'productCode': 'honey', 'quantityTotal': 10, 'quantitySold': 2, 'pricePerUnitPaise': 50000, 'mrpPerUnitPaise': 60000, 'status': 'active', 'createdAt': '2026-10-20T10:00:00.000Z'},
      ]);
    }
    if (path == '/categories') return _json([{'_id': 'c2', 'slug': 'forest-produce'}]);
    if (path == '/listings' && r.method == 'POST') {
      return _json({'_id': 'srv1', 'productCode': 'honey', 'quantityTotal': 30, 'pricePerUnitPaise': 50000, 'mrpPerUnitPaise': 60000, 'status': 'active', 'createdAt': '2026-10-29T10:00:00.000Z'}, 201);
    }
    return _json({});
  }
}

ProviderContainer _container(_Server server) {
  final c = ProviderContainer(overrides: [
    shopApiClientProvider.overrideWith((ref) => V2ApiClient(baseUrl: 'https://s.test', client: MockClient(server.handle))),
    sellCatalogProvider.overrideWith((ref) async => [_honey]),
  ]);
  addTearDown(c.dispose);
  c.listen(liveSellSyncProvider, (_, __) {});
  return c;
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 50));

MyListing _new() => MyListing(
      id: 'my-1',
      productCode: 'honey',
      quantityTotal: 30,
      mrpPaise: 60000,
      pricePaise: 50000,
      minOrderQuantity: 2,
      fulfilment: 'both',
      createdAt: DateTime.utc(2026, 10, 29),
    );

void main() {
  test('the seller\'s listings are loaded from the server and the bundled ones are not used', () async {
    final server = _Server();
    final c = _container(server);
    expect(c.read(myListingsProvider), isEmpty);
    await _settle();
    expect(c.read(myListingsProvider).single.id, 'a');
    expect(server.calls, contains('GET /listings/mine'));
  });

  test('a new listing is sent with the confirmation and gets the server id', () async {
    final server = _Server();
    final c = _container(server);
    await _settle();
    c.read(sellSustainableDeclaredProvider.notifier).state = true;
    c.read(myListingsProvider.notifier).state = createListing(c.read(myListingsProvider), _new());
    await _settle();
    expect(server.calls, contains('POST /listings'));
    expect(c.read(myListingsProvider).map((l) => l.id), containsAll(['a', 'srv1']));
    expect(c.read(myListingsProvider).any((l) => l.id == 'my-1'), isFalse);
    expect(c.read(sellSustainableDeclaredProvider), isFalse);
  });

  test('pausing and changing a listing go to the server', () async {
    final server = _Server();
    final c = _container(server);
    await _settle();
    c.read(myListingsProvider.notifier).state = pauseListing(c.read(myListingsProvider), 'a');
    await _settle();
    expect(server.calls.last, 'PATCH /listings/a/status');
    expect(server.lastBody, {'status': 'paused'});
    final item = c.read(myListingsProvider).single;
    c.read(myListingsProvider.notifier).state = updateListing(c.read(myListingsProvider), item.copyWith(pricePaise: 52500, status: 'paused'));
    await _settle();
    expect(server.calls.last, 'PATCH /listings/a');
    expect(server.lastBody!['pricePerUnitRupees'], 525.0);
  });

  test('when the server refuses a new listing it is taken off the list again', () async {
    final server = _Server();
    final c = _container(server);
    await _settle();
    server.refuse = true;
    c.read(myListingsProvider.notifier).state = createListing(c.read(myListingsProvider), _new());
    await _settle();
    expect(c.read(myListingsProvider).map((l) => l.id), ['a']);
  });
}
