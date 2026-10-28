import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/catalog_models.dart';

/// Abstract repository defining the shop and catalog data contract.
abstract class ShopRepository {
  /// Fetches aggregated home feed sections matching GET /shop/home.
  Future<ShopHome> getHome();

  /// Fetches products filtered by category and search text, sorted by totalSold DESC.
  Future<List<ShopProduct>> getProducts({String? categorySlug, String? query});
}

/// Realistic repository implementation supporting asset JSON loading and inline test maps.
class SampleShopRepository implements ShopRepository {
  final Map<String, dynamic>? _initialData;
  List<ShopProduct>? _loadedProducts;

  SampleShopRepository([this._initialData]);

  /// Factory constructor for unit tests that pass an inline map.
  factory SampleShopRepository.fromMap(Map<String, dynamic> map) {
    return SampleShopRepository(map);
  }

  /// Fixed server order for Community Forest Rights categories.
  static const List<String> categoryFixedOrder = [
    'handicrafts-bamboo',
    'fruit',
    'nuts-and-seeds',
    'flowers',
    'medicinal-plants',
    'forest-produce',
    'timber-trees',
    'shade-trees',
  ];

  Future<List<ShopProduct>> _ensureProducts() async {
    if (_loadedProducts != null) return _loadedProducts!;

    Map<String, dynamic> map;
    if (_initialData != null) {
      map = _initialData!;
    } else {
      try {
        final jsonStr = await rootBundle.loadString('assets/catalog/sample_catalog.json');
        map = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {
        map = const {'products': []};
      }
    }

    final rawList = map['products'] as List<dynamic>? ?? [];
    _loadedProducts = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ShopProduct.fromJson(item))
        .toList(growable: false);

    return _loadedProducts!;
  }

  @override
  Future<ShopHome> getHome() async {
    final all = await _ensureProducts();
    // Only products with at least one listing are "open"
    final openProducts = all.where((p) => p.listings.isNotEmpty).toList();

    // topDeals = open products with bestDiscountPercent > 0, sorted by bestDiscountPercent DESC then startingAtPaise ASC, first 12
    final dealsList = openProducts
        .where((p) => p.bestDiscountPercent > 0)
        .toList()
      ..sort((a, b) {
        final cmp = b.bestDiscountPercent.compareTo(a.bestDiscountPercent);
        if (cmp != 0) return cmp;
        return a.startingAtPaise.compareTo(b.startingAtPaise);
      });
    final topDeals = dealsList.take(12).toList(growable: false);

    // bestSellers = every listing with quantitySold > 0, sorted by quantitySold DESC, first 12
    final soldList = <ShopListingCard>[];
    for (final p in openProducts) {
      for (final l in p.listings) {
        if (l.quantitySold > 0) {
          soldList.add(ShopListingCard(product: p, listing: l));
        }
      }
    }
    soldList.sort((a, b) => b.listing.quantitySold.compareTo(a.listing.quantitySold));
    final bestSellers = soldList.take(12).toList(growable: false);

    // newArrivals = every listing sorted by daysAgo ASC (newest first), first 12
    final arrivalsList = <ShopListingCard>[];
    for (final p in openProducts) {
      for (final l in p.listings) {
        arrivalsList.add(ShopListingCard(product: p, listing: l));
      }
    }
    arrivalsList.sort((a, b) => a.listing.daysAgo.compareTo(b.listing.daysAgo));
    final newArrivals = arrivalsList.take(12).toList(growable: false);

    // categories = categories with listingCount > 0 ONLY (count = number of listings), in fixed order
    final categories = <ShopCategoryCount>[];
    for (final slug in categoryFixedOrder) {
      int count = 0;
      for (final p in openProducts) {
        if (p.categorySlug == slug) {
          count += p.listings.length;
        }
      }
      if (count > 0) {
        categories.add(ShopCategoryCount(slug: slug, listingCount: count));
      }
    }

    final openListingsCount = openProducts.fold<int>(0, (sum, p) => sum + p.listings.length);

    return ShopHome(
      topDeals: topDeals,
      bestSellers: bestSellers,
      newArrivals: newArrivals,
      categories: categories,
      openListings: openListingsCount,
    );
  }

  @override
  Future<List<ShopProduct>> getProducts({String? categorySlug, String? query}) async {
    final all = await _ensureProducts();
    Iterable<ShopProduct> list = all;

    if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
      list = list.where((p) => p.categorySlug == categorySlug && p.listings.isNotEmpty);
    } else {
      list = list.where((p) => p.listings.isNotEmpty);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        final en = p.title['en']?.toLowerCase() ?? '';
        final hi = p.title['hi']?.toLowerCase() ?? '';
        final mr = p.title['mr']?.toLowerCase() ?? '';
        return en.contains(q) || hi.contains(q) || mr.contains(q);
      });
    }

    final result = list.toList();
    // sorted by totalSold DESC
    result.sort((a, b) => b.totalSold.compareTo(a.totalSold));
    return result;
  }
}
