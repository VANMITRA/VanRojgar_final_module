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

// The app names its products with underscores (`fruit_mango`, the names of its pictures); the server only accepts
// lowercase letters and hyphens in a product code (`fruit-mango`). These two convert between them.
final RegExp _groupedCode = RegExp(r'^(fruit|nuts|flowers|herb|forest|timber|shade)[-_]');

/// The code the server stores for an app product code.
String serverProductCode(String appCode) => appCode.replaceAll('_', '-');

/// The app's product code for a code the server sent.
String appProductCode(String serverCode) => _groupedCode.hasMatch(serverCode) ? serverCode.replaceAll('-', '_') : serverCode;

int _wholeNumber(Object? v) => v is num ? v.round() : int.tryParse('$v') ?? 0;

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
/// as a catalog product map. The picture and the Hindi and Marathi names come from the product list the app carries
/// ([bundled], by app product code); what the server sends wins where it has a value.
Map<String, dynamic> productMapFromServer(
  Map<String, dynamic> card,
  List<Map<String, dynamic>> sellers, {
  DateTime? now,
  Map<String, Map<String, dynamic>> bundled = const {},
}) {
  final code = appProductCode((card['productCode'] ?? '').toString());
  final known = bundled[code];
  final category = card['category'] is Map ? (card['category'] as Map)['slug'] : null;
  final serverTitle = card['title'] is Map ? Map<String, dynamic>.from(card['title'] as Map) : <String, dynamic>{};
  final knownTitle = known != null && known['title'] is Map ? Map<String, dynamic>.from(known['title'] as Map) : <String, dynamic>{};
  final title = {
    'en': (serverTitle['en'] ?? knownTitle['en'] ?? serverTitle['mr'] ?? '').toString(),
    'mr': (serverTitle['mr'] ?? knownTitle['mr'] ?? serverTitle['en'] ?? '').toString(),
    'hi': (serverTitle['hi'] ?? knownTitle['hi'] ?? serverTitle['en'] ?? '').toString(),
  };
  return {
    'productCode': code,
    'categorySlug': (category ?? known?['categorySlug'] ?? 'forest-produce').toString(),
    'image': (known?['image'] ?? 'assets/catalog/$code.jpg').toString(),
    'pictureNote': (known?['pictureNote'] ?? '').toString(),
    'notForEating': known?['notForEating'] == true,
    'title': title,
    'unit': unitNames((card['unit'] ?? '').toString()),
    'listings': [for (final s in sellers) listingMapFromServer(s, now: now)],
  };
}
