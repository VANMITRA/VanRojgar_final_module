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

  SampleShopRepository? _cache;
  DateTime? _loadedAt;
  Future<SampleShopRepository>? _loading;

  LiveShopRepository(this._api, {this.ttl = const Duration(seconds: 30), DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

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

    final products = await Future.wait(cards.map((card) async {
      final code = card['productCode'].toString();
      final res = await _api.get('/shop/products/$code/sellers', query: {'unit': card['unit']?.toString()});
      final sellers = ((res is Map ? res['sellers'] : null) as List? ?? const [])
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
      return productMapFromServer(card, sellers, now: _clock());
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
