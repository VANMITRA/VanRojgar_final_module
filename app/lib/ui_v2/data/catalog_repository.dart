import '../models/catalog_models.dart';

/// Abstract repository defining the catalog contract for VanRozgar.
abstract class CatalogRepository {
  /// Fetches all available produce categories.
  Future<List<CatalogCategory>> getCategories();

  /// Fetches sample products, optionally filtered by category slug and search text.
  Future<List<ProductItem>> getProducts({
    String? categorySlug,
    String? searchQuery,
  });
}
