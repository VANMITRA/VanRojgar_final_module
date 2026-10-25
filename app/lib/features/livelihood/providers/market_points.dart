import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One marketplace listing on the map (GET /listings/map on the marketplace server). The server rounds the position to
/// about 1 km, so a listing never reveals an exact place.
class MarketPoint {
  const MarketPoint({
    required this.id,
    required this.titleMr,
    required this.titleEn,
    required this.village,
    required this.lat,
    required this.lng,
    this.productCode,
  });

  final String id;
  final String titleMr;
  final String titleEn;
  final String village;
  final double lat;
  final double lng;
  final String? productCode;

  String title(String lang) => lang == 'en' || titleMr.isEmpty ? titleEn : titleMr;

  factory MarketPoint.fromJson(Map<String, dynamic> j) {
    final title = (j['title'] as Map?) ?? const {};
    return MarketPoint(
      id: '${j['id']}',
      titleMr: '${title['mr'] ?? ''}',
      titleEn: '${title['en'] ?? ''}',
      village: '${j['village'] ?? ''}',
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      productCode: j['productCode'] as String?,
    );
  }
}

/// How the feature gets the listings. The host replaces it with a call to the marketplace server; the default shows
/// none, so the feature never depends on the marketplace being there.
final marketPointsLoaderProvider = Provider<Future<List<MarketPoint>> Function()>(
  (ref) => () async => const [],
);

/// The listings that have a position, fetched when the map layer is switched on.
final marketPointsProvider = FutureProvider.autoDispose<List<MarketPoint>>(
  (ref) => ref.watch(marketPointsLoaderProvider)(),
);

/// Tile images need the internet and make the map hard to test; tests switch them off.
final mapTilesEnabledProvider = Provider<bool>((ref) => true);
