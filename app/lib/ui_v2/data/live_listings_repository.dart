import '../api/v2_api_client.dart';
import '../models/catalog_models.dart';
import '../models/sell_models.dart';

int _int(Object? v) => v is num ? v.round() : int.tryParse('$v') ?? 0;

/// The unit the server stores (kg, g, quintal, litre, piece, bundle, jar, bag) for a catalog product (its English unit word).
String serverUnitFor(ShopProduct product) {
  const known = {'kg', 'g', 'quintal', 'litre', 'piece', 'bundle', 'jar', 'bag'};
  final en = (product.unit['en'] ?? '').trim().toLowerCase();
  return known.contains(en) ? en : 'kg';
}

/// A seller's own listings on the shop server: read, add, change, pause and resume.
/// (The server has no delete: a listing that is taken down is paused.)
class LiveListingsRepository {
  final V2ApiClient api;
  Map<String, String>? _categoryIds; // slug -> id

  LiveListingsRepository(this.api);

  Future<String?> _categoryId(String slug) async {
    if (_categoryIds == null) {
      final data = await api.get('/categories');
      final list = (data is List ? data : (data is Map ? data['categories'] : null) as List? ?? const []);
      _categoryIds = {
        for (final c in list.whereType<Map>())
          if (c['slug'] != null) c['slug'].toString(): (c['_id'] ?? c['id']).toString(),
      };
    }
    return _categoryIds![slug];
  }

  MyListing _fromServer(Map<String, dynamic> l) {
    final status = (l['status'] ?? 'active').toString();
    final price = _int(l['pricePerUnitPaise']);
    return MyListing(
      id: (l['_id'] ?? l['id'] ?? '').toString(),
      productCode: (l['productCode'] ?? '').toString(),
      quantityTotal: _int(l['quantityTotal']),
      quantitySold: _int(l['quantitySold']),
      mrpPaise: l['mrpPerUnitPaise'] == null ? price : _int(l['mrpPerUnitPaise']),
      pricePaise: price,
      minOrderQuantity: l['minOrderQuantity'] == null ? 1 : _int(l['minOrderQuantity']),
      fulfilment: (l['fulfilment'] ?? 'both').toString(),
      status: status == 'active' ? 'active' : 'paused',
      createdAt: DateTime.tryParse('${l['createdAt'] ?? ''}')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
      isSample: false,
    );
  }

  Future<List<MyListing>> mine() async {
    final data = await api.get('/listings/mine');
    return (data is List ? data : const [])
        .whereType<Map>()
        .map((l) => _fromServer(Map<String, dynamic>.from(l)))
        .toList();
  }

  /// Lists [quantity] of [product]. [sustainableDeclared] must be true: the seller has confirmed that the
  /// produce was collected sustainably (the server refuses without it).
  Future<MyListing> create({
    required ShopProduct product,
    required int quantity,
    required int mrpPaise,
    required int pricePaise,
    required int minOrderQuantity,
    required String fulfilment,
    required bool sustainableDeclared,
  }) async {
    final categoryId = await _categoryId(product.categorySlug);
    if (categoryId == null) {
      throw const V2ApiException(statusCode: 422, code: 'VALIDATION_ERROR', message: 'This product group is not open for selling yet.');
    }
    final data = await api.post('/listings', body: {
      'titleMr': product.title['mr'] ?? product.title['en'] ?? '',
      'titleEn': product.title['en'] ?? product.title['mr'] ?? '',
      'categoryId': categoryId,
      'productCode': product.productCode,
      'quantityAvailable': quantity,
      'unit': serverUnitFor(product),
      'pricePerUnitRupees': pricePaise / 100,
      'mrpPerUnitRupees': mrpPaise / 100,
      'minOrderQuantity': minOrderQuantity,
      'fulfilment': fulfilment,
      'sustainableDeclared': sustainableDeclared,
    });
    return _fromServer(data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
  }

  /// Changes the numbers of a listing. [quantityAvailable] is the stock that is left to sell.
  Future<void> update(
    String id, {
    int? quantityAvailable,
    int? mrpPaise,
    int? pricePaise,
    int? minOrderQuantity,
    String? fulfilment,
  }) =>
      api.patch('/listings/$id', body: {
        if (quantityAvailable != null) 'quantityAvailable': quantityAvailable,
        if (mrpPaise != null) 'mrpPerUnitRupees': mrpPaise / 100,
        if (pricePaise != null) 'pricePerUnitRupees': pricePaise / 100,
        if (minOrderQuantity != null) 'minOrderQuantity': minOrderQuantity,
        if (fulfilment != null) 'fulfilment': fulfilment,
      });

  Future<void> pause(String id) => api.patch('/listings/$id/status', body: {'status': 'paused'});

  Future<void> resume(String id) => api.patch('/listings/$id/status', body: {'status': 'active'});
}
