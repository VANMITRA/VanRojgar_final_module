import 'dart:math' as math;
import '../l10n/app_strings.dart';

/// Represents a produce category under Community Forest Rights.
class CatalogCategory {
  final String slug;
  final int order;

  const CatalogCategory({
    required this.slug,
    required this.order,
  });

  String label(AppLanguage lang) => AppStrings.of(lang).categoryLabel(slug);
}

/// Represents an individual seller's listing for a produce item.
class ShopListing {
  final String id;
  final String sellerType; // "gramsabha" | "cfrholder"
  final int pricePerUnitPaise;
  final int mrpPerUnitPaise;
  final int quantityTotal;
  final int quantitySold;
  final int minOrderQuantity;
  final int daysAgo;
  final bool isSample;

  const ShopListing({
    required this.id,
    required this.sellerType,
    required this.pricePerUnitPaise,
    required this.mrpPerUnitPaise,
    required this.quantityTotal,
    required this.quantitySold,
    required this.minOrderQuantity,
    required this.daysAgo,
    this.isSample = true,
  });

  factory ShopListing.fromJson(Map<String, dynamic> json) {
    final price = json['pricePerUnitPaise'] as int? ?? 0;
    return ShopListing(
      id: json['id'] as String? ?? '',
      sellerType: json['sellerType'] as String? ?? 'gramsabha',
      pricePerUnitPaise: price,
      mrpPerUnitPaise: json['mrpPerUnitPaise'] as int? ?? price,
      quantityTotal: json['quantityTotal'] as int? ?? 0,
      quantitySold: json['quantitySold'] as int? ?? 0,
      minOrderQuantity: json['minOrderQuantity'] as int? ?? 1,
      daysAgo: json['daysAgo'] as int? ?? 0,
      isSample: json['isSample'] as bool? ?? true,
    );
  }

  int get discountPaise => math.max(0, mrpPerUnitPaise - pricePerUnitPaise);

  int get discountPercent =>
      mrpPerUnitPaise > 0 ? ((discountPaise * 100) / mrpPerUnitPaise).round() : 0;

  int get quantityAvailable => math.max(0, quantityTotal - quantitySold);

  int get soldPercent =>
      quantityTotal > 0 ? ((quantitySold * 100) / quantityTotal).round() : 0;
}

/// Represents a catalog product with its listings.
class ShopProduct {
  final String productCode;
  final String categorySlug;
  final String imageAsset;
  final Map<String, String> title;
  final Map<String, String> unit;
  final bool notForEating;
  final List<ShopListing> listings;

  const ShopProduct({
    required this.productCode,
    required this.categorySlug,
    required this.imageAsset,
    required this.title,
    required this.unit,
    required this.notForEating,
    required this.listings,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final rawListings = json['listings'] as List<dynamic>? ?? [];
    final listings = rawListings
        .whereType<Map<String, dynamic>>()
        .map((l) => ShopListing.fromJson(l))
        .toList(growable: false);

    final rawTitle = json['title'] as Map<String, dynamic>? ?? {};
    final title = rawTitle.map((k, v) => MapEntry(k.toString(), v.toString()));

    final rawUnit = json['unit'] as Map<String, dynamic>? ?? {};
    final unit = rawUnit.map((k, v) => MapEntry(k.toString(), v.toString()));

    final code = json['productCode'] as String? ?? '';
    final image = json['image'] as String? ?? 'assets/catalog/$code.jpg';

    return ShopProduct(
      productCode: code,
      categorySlug: json['categorySlug'] as String? ?? 'forest-produce',
      imageAsset: image,
      title: title,
      unit: unit,
      notForEating: json['notForEating'] as bool? ?? false,
      listings: listings,
    );
  }

  int get sellerCount => listings.length;

  ShopListing? get cheapestListing {
    if (listings.isEmpty) return null;
    ShopListing lowest = listings.first;
    for (final l in listings) {
      if (l.pricePerUnitPaise < lowest.pricePerUnitPaise) {
        lowest = l;
      }
    }
    return lowest;
  }

  int get startingAtPaise => cheapestListing?.pricePerUnitPaise ?? 0;

  int get bestDiscountPercent {
    if (listings.isEmpty) return 0;
    int maxDiscount = 0;
    for (final l in listings) {
      if (l.discountPercent > maxDiscount) {
        maxDiscount = l.discountPercent;
      }
    }
    return maxDiscount;
  }

  int get totalAvailable =>
      listings.fold(0, (sum, l) => sum + l.quantityAvailable);

  int get totalSold =>
      listings.fold(0, (sum, l) => sum + l.quantitySold);

  int get newestDaysAgo {
    if (listings.isEmpty) return 999999;
    int minDays = listings.first.daysAgo;
    for (final l in listings) {
      if (l.daysAgo < minDays) minDays = l.daysAgo;
    }
    return minDays;
  }

  String localizedTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return title['en'] ?? '';
      case AppLanguage.hi:
        return title['hi'] ?? title['en'] ?? '';
      case AppLanguage.mr:
        return title['mr'] ?? title['en'] ?? '';
    }
  }

  String localizedUnit(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return unit['en'] ?? '';
      case AppLanguage.hi:
        return unit['hi'] ?? unit['en'] ?? '';
      case AppLanguage.mr:
        return unit['mr'] ?? unit['en'] ?? '';
    }
  }
}

/// A specific listing combined with its parent product for listing-centric rows.
class ShopListingCard {
  final ShopProduct product;
  final ShopListing listing;

  const ShopListingCard({
    required this.product,
    required this.listing,
  });
}

/// Category slug with its active listing count.
class ShopCategoryCount {
  final String slug;
  final int listingCount;

  const ShopCategoryCount({
    required this.slug,
    required this.listingCount,
  });
}

/// Aggregated home feed data matching GET /shop/home.
class ShopHome {
  final List<ShopProduct> topDeals;
  final List<ShopListingCard> bestSellers;
  final List<ShopListingCard> newArrivals;
  final List<ShopCategoryCount> categories;
  final int openListings;

  const ShopHome({
    required this.topDeals,
    required this.bestSellers,
    required this.newArrivals,
    required this.categories,
    required this.openListings,
  });
}

/// Formats paise integer into a localized Rupee string with Indian numbering grouping.
///
/// Examples:
/// - 9900 paise -> "₹99"
/// - 9950 paise -> "₹99.50"
/// - 120000 paise -> "₹1,200"
/// - 12000000 paise (1,20,000 rupees) -> "₹1,20,000"
String formatRupees(int paise) {
  final bool isNegative = paise < 0;
  final int absPaise = paise.abs();
  final int rupees = absPaise ~/ 100;
  final int remPaise = absPaise % 100;

  final rupeesStr = formatIndianNumber(rupees);
  final prefix = isNegative ? '-₹' : '₹';
  if (remPaise == 0) {
    return '$prefix$rupeesStr';
  } else if (remPaise % 10 == 0) {
    return '$prefix$rupeesStr.${remPaise ~/ 10}0';
  } else {
    return '$prefix$rupeesStr.${remPaise.toString().padLeft(2, '0')}';
  }
}

/// Formats integer into standard Indian numbering grouping (e.g. 120000 -> "1,20,000").
String formatIndianNumber(int n) {
  if (n < 0) return '-${formatIndianNumber(-n)}';
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final buffer = StringBuffer();
  for (int i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(rest[i]);
  }
  buffer.write(',');
  buffer.write(last3);
  return buffer.toString();
}
