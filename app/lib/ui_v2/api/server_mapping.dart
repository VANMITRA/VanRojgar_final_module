// Turns what the shop server sends into the shape the screens already read (the catalog map that
// `ShopProduct.fromJson` understands). Pure functions: no network, easy to test.

const Map<String, Map<String, String>> _unitNames = {
  'kg': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
  'g': {'en': 'g', 'hi': 'ग्राम', 'mr': 'ग्रॅम'},
  'quintal': {'en': 'quintal', 'hi': 'क्विंटल', 'mr': 'क्विंटल'},
  'litre': {'en': 'litre', 'hi': 'लीटर', 'mr': 'लिटर'},
  'piece': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
  'bundle': {'en': 'bundle', 'hi': 'गट्ठा', 'mr': 'गठ्ठा'},
  'jar': {'en': 'jar', 'hi': 'जार', 'mr': 'बरणी'},
  'bag': {'en': 'bag', 'hi': 'थैला', 'mr': 'पिशवी'},
};

/// The unit in the three languages (an unknown unit is shown as it is).
Map<String, String> unitNames(String unit) => _unitNames[unit] ?? {'en': unit, 'hi': unit, 'mr': unit};

int _wholeNumber(Object? v) => v is num ? v.round() : int.tryParse('$v') ?? 0;

Map<String, String> _titleOf(Object? raw) {
  final m = raw is Map ? raw : const {};
  final en = (m['en'] ?? m['mr'] ?? m['hi'] ?? '').toString();
  return {
    'en': en,
    'hi': (m['hi'] ?? en).toString(),
    'mr': (m['mr'] ?? en).toString(),
  };
}

/// One listing of the server (a seller row, as sent by /shop/products/:code/sellers) as a catalog listing map.
Map<String, dynamic> listingMapFromServer(Map<String, dynamic> l, {DateTime? now}) {
  final seller = l['seller'] is Map ? Map<String, dynamic>.from(l['seller'] as Map) : const <String, dynamic>{};
  final owner = (seller['ownerId'] ?? l['ownerId'] ?? '').toString();
  final type = (seller['type'] ?? l['ownerType'] ?? 'gramsabha').toString();
  final village = (seller['village'] ?? l['village'] ?? '').toString();
  final name = (seller['name'] as String?)?.trim();
  final created = DateTime.tryParse('${l['createdAt'] ?? ''}');
  final daysAgo = created == null ? 0 : (now ?? DateTime.now()).difference(created).inDays.clamp(0, 100000);
  final price = _wholeNumber(l['pricePerUnitPaise']);
  return {
    'id': (l['_id'] ?? l['id'] ?? '').toString(),
    'sellerId': owner,
    'sellerName': (name != null && name.isNotEmpty) ? name : village,
    'sellerType': type == 'villager' ? 'cfrholder' : type,
    'fulfilment': (l['fulfilment'] ?? 'both').toString(),
    'pricePerUnitPaise': price,
    'mrpPerUnitPaise': l['mrpPerUnitPaise'] == null ? price : _wholeNumber(l['mrpPerUnitPaise']),
    'quantityTotal': _wholeNumber(l['quantityTotal']),
    'quantitySold': _wholeNumber(l['quantitySold']),
    'minOrderQuantity': l['minOrderQuantity'] == null ? 1 : _wholeNumber(l['minOrderQuantity']),
    'daysAgo': daysAgo,
    'isSample': false,
  };
}

/// One product (a card of /shop/products) and its sellers (the `sellers` of /shop/products/:code/sellers)
/// as a catalog product map. The picture is the one the app carries for that product code.
Map<String, dynamic> productMapFromServer(Map<String, dynamic> card, List<Map<String, dynamic>> sellers, {DateTime? now}) {
  final code = (card['productCode'] ?? '').toString();
  final category = card['category'] is Map ? (card['category'] as Map)['slug'] : null;
  return {
    'productCode': code,
    'categorySlug': (category ?? 'forest-produce').toString(),
    'image': 'assets/catalog/$code.jpg',
    'pictureNote': '',
    'notForEating': false,
    'title': _titleOf(card['title']),
    'unit': unitNames((card['unit'] ?? '').toString()),
    'listings': [for (final s in sellers) listingMapFromServer(s, now: now)],
  };
}
