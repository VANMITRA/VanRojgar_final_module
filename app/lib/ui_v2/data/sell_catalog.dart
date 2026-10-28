import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalog_models.dart';

/// Parses every product from a decoded catalog JSON map (including products without sellers).
List<ShopProduct> parseSellCatalogMap(Map<String, dynamic> map) {
  final rawList = map['products'] as List<dynamic>? ?? const [];
  return rawList
      .whereType<Map<String, dynamic>>()
      .map(ShopProduct.fromJson)
      .toList(growable: false);
}

/// Loads all 43 products (including those with no existing sellers) from `assets/catalog/sample_catalog.json`.
Future<List<ShopProduct>> loadSellCatalogAsset() async {
  try {
    final jsonStr = await rootBundle.loadString('assets/catalog/sample_catalog.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return parseSellCatalogMap(map);
  } catch (_) {
    return const <ShopProduct>[];
  }
}

/// Asynchronous provider for the full catalog of products a seller can list.
final sellCatalogProvider = FutureProvider<List<ShopProduct>>((ref) async {
  return loadSellCatalogAsset();
});
