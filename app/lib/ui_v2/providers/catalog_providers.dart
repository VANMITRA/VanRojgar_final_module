import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shop_repository.dart';
import '../l10n/app_strings.dart';
import '../models/catalog_models.dart';

/// In-memory ThemeMode provider. Defaults to system setting.
final uiV2ThemeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// In-memory language provider. Defaults to English.
final uiV2LanguageProvider = StateProvider<AppLanguage>((ref) {
  return AppLanguage.en;
});

/// Standard 9 categories for the fixed top category tab strip.
const List<CatalogCategory> fixedCatalogCategories = [
  CatalogCategory(slug: 'all', order: 0),
  CatalogCategory(slug: 'handicrafts-bamboo', order: 1),
  CatalogCategory(slug: 'fruit', order: 2),
  CatalogCategory(slug: 'nuts-and-seeds', order: 3),
  CatalogCategory(slug: 'flowers', order: 4),
  CatalogCategory(slug: 'medicinal-plants', order: 5),
  CatalogCategory(slug: 'forest-produce', order: 6),
  CatalogCategory(slug: 'timber-trees', order: 7),
  CatalogCategory(slug: 'shade-trees', order: 8),
];

/// Asynchronous list of categories for the category tab strip.
final categoriesProvider = FutureProvider<List<CatalogCategory>>((ref) async {
  return fixedCatalogCategories;
});

/// Selected category slug provider. Defaults to 'all'.
final selectedCategorySlugProvider = StateProvider<String>((ref) {
  return 'all';
});

/// Search query string provider.
final catalogSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Shop repository provider.
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return SampleShopRepository();
});

/// Asynchronous home feed provider matching GET /shop/home.
final shopHomeProvider = FutureProvider<ShopHome>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.getHome();
});

/// Asynchronous filtered products provider for category or search views.
final shopProductsProvider = FutureProvider<List<ShopProduct>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  final slug = ref.watch(selectedCategorySlugProvider);
  final query = ref.watch(catalogSearchQueryProvider);
  return repo.getProducts(categorySlug: slug, query: query);
});

/// In-memory cart quantities provider mapping productCode -> quantity.
final cartQuantitiesProvider = StateProvider<Map<String, int>>((ref) {
  return <String, int>{};
});

/// Helper extension on the cart StateController for mutating cart quantities.
extension CartControllerX on StateController<Map<String, int>> {
  /// Sets quantity to the item's minimum order quantity.
  void add(String productCode, [int minOrderQuantity = 1]) {
    state = {...state, productCode: minOrderQuantity};
  }

  /// Increments quantity by 1.
  void increment(String productCode) {
    final current = state[productCode] ?? 0;
    state = {...state, productCode: current + 1};
  }

  /// Decrements quantity by 1, removing the item when dropping below minimum order quantity.
  void decrement(String productCode, [int minOrderQuantity = 1]) {
    final current = state[productCode] ?? 0;
    if (current <= minOrderQuantity) {
      final next = Map<String, int>.from(state)..remove(productCode);
      state = next;
    } else {
      state = {...state, productCode: current - 1};
    }
  }
}

/// Number of unique products currently in the cart.
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartQuantitiesProvider);
  return cart.length;
});
