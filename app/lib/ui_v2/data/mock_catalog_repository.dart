import '../models/catalog_models.dart';
import 'catalog_repository.dart';

/// In-memory mock implementation of [CatalogRepository] for Phase 1.
class MockCatalogRepository implements CatalogRepository {
  const MockCatalogRepository();

  static const List<CatalogCategory> _categories = [
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

  static const List<ProductItem> _sampleProducts = [
    ProductItem(
      id: 'prod_001',
      titleEn: 'Wild Multi-Flora Forest Honey',
      titleHi: 'जंगली बहु-पुष्पीय शहद',
      titleMr: 'रान बहु-फुलांचा मध',
      categorySlug: 'forest-produce',
      pricePaise: 45000, // ₹450
      unitEn: 'kg',
      unitHi: 'किग्रा',
      unitMr: 'किलो',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
    ProductItem(
      id: 'prod_002',
      titleEn: 'Handwoven Bamboo Storage Basket',
      titleHi: 'बाँस की हस्तनिर्मित टोकरी',
      titleMr: 'हातविणलेली बांबूची टोपली',
      categorySlug: 'handicrafts-bamboo',
      pricePaise: 28000, // ₹280
      unitEn: 'piece',
      unitHi: 'नग',
      unitMr: 'नग',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
    ProductItem(
      id: 'prod_003',
      titleEn: 'Sun-Dried Mahua Flowers',
      titleHi: 'धूप में सुखाए महुआ के फूल',
      titleMr: 'वाळवलेली मोहाची फुले',
      categorySlug: 'flowers',
      pricePaise: 12000, // ₹120
      unitEn: 'kg',
      unitHi: 'किग्रा',
      unitMr: 'किलो',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
    ProductItem(
      id: 'prod_004',
      titleEn: 'Raw Ashwagandha Root',
      titleHi: 'कच्ची अश्वगंधा जड़',
      titleMr: 'अश्वगंधा मूळ',
      categorySlug: 'medicinal-plants',
      pricePaise: 35000, // ₹350
      unitEn: '500g',
      unitHi: '500ग्रा',
      unitMr: '500ग्रॅम',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
    ProductItem(
      id: 'prod_005',
      titleEn: 'Wild Chironji (Charoli) Seeds',
      titleHi: 'जंगली चिरौंजी (चारोली) बीज',
      titleMr: 'रान चारोळी बी',
      categorySlug: 'nuts-and-seeds',
      pricePaise: 85000, // ₹850
      unitEn: 'kg',
      unitHi: 'किग्रा',
      unitMr: 'किलो',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
    ProductItem(
      id: 'prod_006',
      titleEn: 'Forest Tamarind Pods',
      titleHi: 'जंगली इमली',
      titleMr: 'रानचिंच',
      categorySlug: 'fruit',
      pricePaise: 9000, // ₹90
      unitEn: 'kg',
      unitHi: 'किग्रा',
      unitMr: 'किलो',
      villageNameEn: 'Sample village',
      villageNameHi: 'नमूना गाँव',
      villageNameMr: 'नमुना गाव',
    ),
  ];

  @override
  Future<List<CatalogCategory>> getCategories() async {
    // Return immediately for demo responsiveness
    return _categories;
  }

  @override
  Future<List<ProductItem>> getProducts({
    String? categorySlug,
    String? searchQuery,
  }) async {
    Iterable<ProductItem> list = _sampleProducts;

    if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
      list = list.where((p) => p.categorySlug == categorySlug);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.titleEn.toLowerCase().contains(query) ||
            p.titleHi.toLowerCase().contains(query) ||
            p.titleMr.toLowerCase().contains(query) ||
            p.villageNameEn.toLowerCase().contains(query) ||
            p.villageNameMr.toLowerCase().contains(query);
      });
    }

    return list.toList(growable: false);
  }
}
