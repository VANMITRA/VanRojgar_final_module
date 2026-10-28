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

/// Represents a sample forest product in the Phase 1 catalog.
///
/// Prices are stored as strict integers in paise (1 INR = 100 paise)
/// as required by the financial architecture.
class ProductItem {
  final String id;
  final String titleEn;
  final String titleHi;
  final String titleMr;
  final String categorySlug;
  final int pricePaise; // Strict integer in paise
  final String unitEn;
  final String unitHi;
  final String unitMr;
  final String villageNameEn;
  final String villageNameHi;
  final String villageNameMr;
  final bool isSample;

  const ProductItem({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.titleMr,
    required this.categorySlug,
    required this.pricePaise,
    required this.unitEn,
    required this.unitHi,
    required this.unitMr,
    required this.villageNameEn,
    required this.villageNameHi,
    required this.villageNameMr,
    this.isSample = true,
  });

  String localizedTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return titleEn;
      case AppLanguage.hi:
        return titleHi;
      case AppLanguage.mr:
        return titleMr;
    }
  }

  String localizedUnit(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return unitEn;
      case AppLanguage.hi:
        return unitHi;
      case AppLanguage.mr:
        return unitMr;
    }
  }

  String localizedVillage(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return villageNameEn;
      case AppLanguage.hi:
        return villageNameHi;
      case AppLanguage.mr:
        return villageNameMr;
    }
  }

  /// Formatted rupee string from integer paise (e.g., 45000 -> "₹450").
  String get formattedRupees {
    final rupees = pricePaise ~/ 100;
    final remainderPaise = pricePaise % 100;
    if (remainderPaise == 0) {
      return '₹$rupees';
    } else {
      return '₹$rupees.${remainderPaise.toString().padLeft(2, '0')}';
    }
  }
}
