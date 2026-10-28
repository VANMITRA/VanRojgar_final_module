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

  /// Removes the product from the cart.
  void remove(String productCode) {
    state = Map<String, int>.from(state)..remove(productCode);
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

/// Picture of the product added to the cart most recently (shown in the floating cart pill).
final lastAddedImageProvider = StateProvider<String?>((ref) => null);

/// Which seller (listing id) the buyer chose for a product in the cart: productCode -> listing id.
/// A product with no entry uses its cheapest listing. Set on the Product page and in checkout.
final cartSellerChoiceProvider = StateProvider<Map<String, String>>((ref) => const {});

/// One line of the cart: a product with its quantity and the chosen seller's listing
/// (the cheapest listing when the buyer has not chosen one).
class CartLine {
  final ShopProduct product;
  final int quantity;
  final ShopListing listing;

  const CartLine(this.product, this.quantity, this.listing);

  int get unitPricePaise => listing.pricePerUnitPaise;
  int get lineTotalPaise => unitPricePaise * quantity;
  String get sellerId => listing.sellerId;
}

/// The cart lines in the order the products were added (a Dart map keeps insertion order).
final cartLinesProvider = FutureProvider<List<CartLine>>((ref) async {
  final cart = ref.watch(cartQuantitiesProvider);
  final choice = ref.watch(cartSellerChoiceProvider);
  final products = await ref.watch(shopRepositoryProvider).getProducts();
  final byCode = {for (final p in products) p.productCode: p};
  final lines = <CartLine>[];
  for (final entry in cart.entries) {
    final product = byCode[entry.key];
    if (product == null || product.cheapestListing == null) continue;
    final chosenId = choice[entry.key];
    ShopListing listing = product.cheapestListing!;
    if (chosenId != null) {
      for (final l in product.listings) {
        if (l.id == chosenId) listing = l;
      }
    }
    lines.add(CartLine(product, entry.value, listing));
  }
  return lines;
});

/// Every open product (with at least one seller), most sold first.
final allOpenProductsProvider = FutureProvider<List<ShopProduct>>((ref) async {
  return ref.watch(shopRepositoryProvider).getProducts();
});

/// The open products of one category (slug 'all' = every open product).
final categoryProductsProvider = FutureProvider.family<List<ShopProduct>, String>((ref, slug) async {
  return ref.watch(shopRepositoryProvider).getProducts(categorySlug: slug);
});

/// One open product by its code (for the Product page); null when it is not found.
final productByCodeProvider = FutureProvider.family<ShopProduct?, String>((ref, code) async {
  final products = await ref.watch(shopRepositoryProvider).getProducts();
  for (final p in products) {
    if (p.productCode == code) return p;
  }
  return null;
});

/// The signed-in user (demo only: kept in memory, nothing is sent to a server yet).
class AuthUser {
  final String name;
  final String role; // buyer | gramsabha | cfrholder
  final String phone;
  final String? villageId;

  const AuthUser({
    required this.name,
    required this.role,
    required this.phone,
    this.villageId,
  });
}

/// null = guest.
final authUserProvider = StateProvider<AuthUser?>((ref) => null);

/// An account created in this demo session (phone, 6-digit PIN and the user). Memory only.
class DemoAccount {
  final String pin;
  final AuthUser user;

  const DemoAccount(this.pin, this.user);
}

/// Accounts created during this session, by 10-digit phone number.
final demoAccountsProvider = StateProvider<Map<String, DemoAccount>>((ref) => const {});
