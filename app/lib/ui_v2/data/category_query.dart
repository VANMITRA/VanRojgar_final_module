import 'dart:math' as math;
import 'package:flutter/material.dart' show RangeValues;
import '../models/catalog_models.dart';

/// The four ways to sort a category page.
enum CategorySort { popular, priceAsc, discount, newest }

/// The filters of a category page: a price range (in rupees) and "only discounted".
class CategoryFilters {
  /// null = no price filter.
  final RangeValues? priceRupees;
  final bool onlyDiscounted;

  const CategoryFilters({this.priceRupees, this.onlyDiscounted = false});

  bool get isActive => priceRupees != null || onlyDiscounted;
  int get activeCount => (priceRupees != null ? 1 : 0) + (onlyDiscounted ? 1 : 0);

  CategoryFilters copyWith({RangeValues? priceRupees, bool clearPrice = false, bool? onlyDiscounted}) {
    return CategoryFilters(
      priceRupees: clearPrice ? null : (priceRupees ?? this.priceRupees),
      onlyDiscounted: onlyDiscounted ?? this.onlyDiscounted,
    );
  }
}

/// The lowest and highest "starting at" price of [products], in whole rupees (rounded outwards).
RangeValues categoryPriceBounds(List<ShopProduct> products) {
  if (products.isEmpty) return const RangeValues(0, 0);
  var lo = products.first.startingAtPaise;
  var hi = lo;
  for (final p in products) {
    lo = math.min(lo, p.startingAtPaise);
    hi = math.max(hi, p.startingAtPaise);
  }
  return RangeValues((lo ~/ 100).toDouble(), ((hi + 99) ~/ 100).toDouble());
}

/// Applies the filters and then the sort. Does not change the list that is passed in.
List<ShopProduct> applyCategoryQuery(
  List<ShopProduct> products,
  CategorySort sort,
  CategoryFilters filters,
) {
  Iterable<ShopProduct> list = products;

  final range = filters.priceRupees;
  if (range != null) {
    final lo = (range.start * 100).round();
    final hi = (range.end * 100).round();
    list = list.where((p) => p.startingAtPaise >= lo && p.startingAtPaise <= hi);
  }
  if (filters.onlyDiscounted) {
    list = list.where((p) => p.bestDiscountPercent > 0);
  }

  final result = list.toList();
  switch (sort) {
    case CategorySort.popular:
      result.sort((a, b) {
        final c = b.totalSold.compareTo(a.totalSold);
        return c != 0 ? c : b.sellerCount.compareTo(a.sellerCount);
      });
      break;
    case CategorySort.priceAsc:
      result.sort((a, b) => a.startingAtPaise.compareTo(b.startingAtPaise));
      break;
    case CategorySort.discount:
      result.sort((a, b) {
        final c = b.bestDiscountPercent.compareTo(a.bestDiscountPercent);
        return c != 0 ? c : a.startingAtPaise.compareTo(b.startingAtPaise);
      });
      break;
    case CategorySort.newest:
      result.sort((a, b) => a.newestDaysAgo.compareTo(b.newestDaysAgo));
      break;
  }
  return result;
}
