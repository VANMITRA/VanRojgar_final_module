import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/catalog_repository.dart';
import '../data/mock_catalog_repository.dart';
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

/// Catalog repository provider.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return const MockCatalogRepository();
});

/// Selected category slug provider. Defaults to 'all'.
final selectedCategorySlugProvider = StateProvider<String>((ref) {
  return 'all';
});

/// Search query string provider.
final catalogSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Asynchronous list of categories.
final categoriesProvider = FutureProvider<List<CatalogCategory>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCategories();
});

/// Asynchronous list of sample products based on selected category and search text.
final productsProvider = FutureProvider<List<ProductItem>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final slug = ref.watch(selectedCategorySlugProvider);
  final query = ref.watch(catalogSearchQueryProvider);
  return repo.getProducts(categorySlug: slug, searchQuery: query);
});
