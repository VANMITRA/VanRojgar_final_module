import 'dart:convert';
import 'package:flutter/services.dart';
import '../api/server_mapping.dart';
import '../api/v2_api_client.dart';
import '../models/catalog_models.dart';
import 'shop_repository.dart';

/// The shop with REAL data from the server: products, their sellers, stock and prices.
/// The answers are kept for [ttl], so moving between screens does not call the server again each time.
class LiveShopRepository implements ShopRepository {
  final V2ApiClient _api;
  final Duration ttl;
  final DateTime Function() _clock;
  final Future<Map<String, Map<String, dynamic>>> Function() _bundled;

  SampleShopRepository? _cache;
  DateTime? _loadedAt;
  Future<SampleShopRepository>? _loading;

  LiveShopRepository(
    this._api, {
    this.ttl = const Duration(seconds: 30),
    DateTime Function()? clock,
    Future<Map<String, Map<String, dynamic>>> Function()? bundledProducts,
  })  : _clock = clock ?? DateTime.now,
        _bundled = bundledProducts ?? loadBundledProducts;

  /// Forget the kept answers (after an order, so stock shows the new numbers).
  void refresh() {
    _cache = null;
    _loadedAt = null;
  }

  Future<SampleShopRepository> _load() {
    final cached = _cache;
    final at = _loadedAt;
    if (cached != null && at != null && _clock().difference(at) < ttl) return Future.value(cached);
    return _loading ??= _fetch().whenComplete(() => _loading = null);
  }

  Future<SampleShopRepository> _fetch() async {
    final list = await _api.get('/shop/products', query: {'limit': '50'});
    final cards = ((list is Map ? list['products'] : null) as List? ?? const [])
        .whereType<Map>()
        .map((c) => Map<String, dynamic>.from(c))
        .where((c) => (c['productCode'] ?? '').toString().isNotEmpty)
        .toList();

    final bundled = await _bundled();
    final products = await Future.wait(cards.map((card) async {
      final code = card['productCode'].toString();
      final res = await _api.get('/shop/products/$code/sellers', query: {'unit': card['unit']?.toString()});
      final sellers = ((res is Map ? res['sellers'] : null) as List? ?? const [])
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
      return productMapFromServer(card, sellers, now: _clock(), bundled: bundled);
    }));

    final repo = SampleShopRepository.fromMap({'products': products});
    _cache = repo;
    _loadedAt = _clock();
    return repo;
  }

  @override
  Future<ShopHome> getHome() async => (await _load()).getHome();

  @override
  Future<List<ShopProduct>> getProducts({String? categorySlug, String? query}) async =>
      (await _load()).getProducts(categorySlug: categorySlug, query: query);
}

/// The product list the app carries (names in three languages, pictures), by app product code. Empty if it cannot be read.
Future<Map<String, Map<String, dynamic>>> loadBundledProducts() async {
  try {
    final map = jsonDecode(await rootBundle.loadString('assets/catalog/sample_catalog.json')) as Map<String, dynamic>;
    return {
      for (final p in (map['products'] as List? ?? const []).whereType<Map>())
        (p['productCode'] ?? '').toString(): Map<String, dynamic>.from(p),
    };
  } catch (_) {
    return const {};
  }
}
