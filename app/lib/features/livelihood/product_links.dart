/// The link between livelihood ideas and marketplace listings (docs/plan.md section 3).
///
/// A produce idea carries one or more PRODUCT CODES; a listing carries one product code
/// (server/src/core/productCode.js, the same eight values). The code is what lets
/// "List this on the marketplace" (idea to listing) and "See what land near here can produce"
/// (listing to ideas) find each other.
///
/// No-harm rule: honey is always "managed-apiary honey", and wild-hive honey, lac and anything from
/// a reserve are never offered. That is why the community produce group idea does not list honey.
library;

/// What a new listing for a product starts with. The person can change every field.
class MarketProduct {
  const MarketProduct({
    required this.code,
    required this.titleMr,
    required this.titleEn,
    required this.unit,
    required this.categorySlug,
  });

  final String code;
  final String titleMr;
  final String titleEn;
  final String unit; // one of the listing units: kg, g, quintal, litre, piece, bundle, jar, bag
  final String categorySlug; // forest-produce | handicrafts-bamboo | medicinal-plants

  String title(String lang) => lang == 'en' ? titleEn : titleMr;
}

const Map<String, MarketProduct> marketProducts = {
  'honey': MarketProduct(
    code: 'honey',
    titleMr: 'मधपेटीतील मध',
    titleEn: 'Managed-apiary honey',
    unit: 'jar',
    categorySlug: 'forest-produce',
  ),
  'bamboo': MarketProduct(
    code: 'bamboo',
    titleMr: 'बांबूच्या वस्तू',
    titleEn: 'Bamboo products',
    unit: 'piece',
    categorySlug: 'handicrafts-bamboo',
  ),
  'herb': MarketProduct(
    code: 'herb',
    titleMr: 'लागवडीची औषधी वनस्पती (वाळवलेली)',
    titleEn: 'Cultivated herbs (dried)',
    unit: 'bag',
    categorySlug: 'medicinal-plants',
  ),
  'preserve': MarketProduct(
    code: 'preserve',
    titleMr: 'फळांचा मुरांबा',
    titleEn: 'Fruit preserve',
    unit: 'jar',
    categorySlug: 'forest-produce',
  ),
  'seed': MarketProduct(
    code: 'seed',
    titleMr: 'रोपवाटिका बियाणे',
    titleEn: 'Nursery seed packet',
    unit: 'bag',
    categorySlug: 'forest-produce',
  ),
  'leaf-plate': MarketProduct(
    code: 'leaf-plate',
    titleMr: 'पत्रावळी',
    titleEn: 'Leaf plates',
    unit: 'bag',
    categorySlug: 'forest-produce',
  ),
  'fibre': MarketProduct(
    code: 'fibre',
    titleMr: 'नैसर्गिक धाग्याची दोरी',
    titleEn: 'Natural-fibre rope',
    unit: 'piece',
    categorySlug: 'handicrafts-bamboo',
  ),
  'dried-fruit': MarketProduct(
    code: 'dried-fruit',
    titleMr: 'वाळवलेली फळे',
    titleEn: 'Dried fruit',
    unit: 'bag',
    categorySlug: 'forest-produce',
  ),
};

/// Which products each livelihood idea can lead to. Ideas that make no sellable produce are absent.
const Map<String, List<String>> ideaProducts = {
  'beekeeping_box': ['honey'],
  'mfp_collection_group': ['bamboo', 'herb', 'leaf-plate', 'dried-fruit', 'preserve'],
  'plant_nursery': ['seed', 'herb'],
  'agroforestry_fruit': ['dried-fruit', 'preserve'],
};

/// The products an idea can be listed as (empty when it has none).
List<MarketProduct> productsForIdea(String ideaCode) => [
      for (final code in ideaProducts[ideaCode] ?? const <String>[]) marketProducts[code]!,
    ];

/// The ideas a product comes from, in a stable order.
List<String> ideasForProduct(String productCode) => [
      for (final e in ideaProducts.entries)
        if (e.value.contains(productCode)) e.key,
    ];

/// The route that opens the add-listing screen already filled for [productCode].
String addListingRouteFor(String productCode) =>
    Uri(path: '/gs/listings/new', queryParameters: {'product': productCode}).toString();
