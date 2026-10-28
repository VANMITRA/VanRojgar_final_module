import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';
import 'package:vanrozgar/ui_v2/models/catalog_models.dart';

void main() {
  group('Shop Model and Money Formatting Tests', () {
    test('formatRupees formats paise with correct decimal and Indian grouping', () {
      expect(formatRupees(9900), '₹99');
      expect(formatRupees(9950), '₹99.50');
      expect(formatRupees(120000), '₹1,200');
      expect(formatRupees(12000000), '₹1,20,000');
      expect(formatRupees(0), '₹0');
    });

    test('ShopListing math for discount, available quantity, and percentages', () {
      const listing = ShopListing(
        id: 'test-1',
        sellerType: 'gramsabha',
        pricePerUnitPaise: 8000,
        mrpPerUnitPaise: 10000,
        quantityTotal: 200,
        quantitySold: 50,
        minOrderQuantity: 5,
        daysAgo: 3,
      );

      expect(listing.discountPaise, 2000);
      expect(listing.discountPercent, 20); // 2000 * 100 / 10000 = 20%
      expect(listing.quantityAvailable, 150);
      expect(listing.soldPercent, 25); // 50 * 100 / 200 = 25%
    });
  });

  group('SampleShopRepository Data Engine Tests', () {
    final sampleMap = {
      'note': 'Test catalog',
      'village': {'en': 'Sample village', 'hi': 'नमूना गाँव', 'mr': 'नमुना गाव'},
      'products': [
        // Product 1: Fruit Mango - 2 listings, 10% discount
        {
          'productCode': 'fruit_mango',
          'categorySlug': 'fruit',
          'image': 'assets/catalog/fruit_mango.jpg',
          'notForEating': false,
          'title': {'en': 'Mango', 'hi': 'आम', 'mr': 'आंबा'},
          'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
          'listings': [
            {
              'id': 'm-1',
              'sellerType': 'gramsabha',
              'pricePerUnitPaise': 9000,
              'mrpPerUnitPaise': 10000,
              'quantityTotal': 100,
              'quantitySold': 20,
              'minOrderQuantity': 2,
              'daysAgo': 10,
            },
            {
              'id': 'm-2',
              'sellerType': 'cfrholder',
              'pricePerUnitPaise': 9500,
              'mrpPerUnitPaise': 10000,
              'quantityTotal': 50,
              'quantitySold': 0,
              'minOrderQuantity': 2,
              'daysAgo': 4,
            },
          ],
        },
        // Product 2: Bamboo Basket - 30% discount, high sold
        {
          'productCode': 'bamboo_basket',
          'categorySlug': 'handicrafts-bamboo',
          'image': 'assets/catalog/bamboo_basket.jpg',
          'notForEating': false,
          'title': {'en': 'Bamboo Basket', 'hi': 'बाँस की टोकरी', 'mr': 'बांबूची टोपली'},
          'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
          'listings': [
            {
              'id': 'b-1',
              'sellerType': 'cfrholder',
              'pricePerUnitPaise': 7000,
              'mrpPerUnitPaise': 10000,
              'quantityTotal': 80,
              'quantitySold': 60,
              'minOrderQuantity': 1,
              'daysAgo': 1, // Newest arrival
            },
          ],
        },
        // Product 3: Honey - no discount, sold = 10
        {
          'productCode': 'forest_honey',
          'categorySlug': 'forest-produce',
          'image': 'assets/catalog/forest_honey.jpg',
          'notForEating': false,
          'title': {'en': 'Forest Honey', 'hi': 'जंगली शहद', 'mr': 'रान मध'},
          'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
          'listings': [
            {
              'id': 'h-1',
              'sellerType': 'gramsabha',
              'pricePerUnitPaise': 50000,
              'mrpPerUnitPaise': 50000,
              'quantityTotal': 30,
              'quantitySold': 10,
              'minOrderQuantity': 1,
              'daysAgo': 8,
            },
          ],
        },
        // Product 4: Poisonous Nut (not for eating)
        {
          'productCode': 'nuts_bibba',
          'categorySlug': 'nuts-and-seeds',
          'image': 'assets/catalog/nuts_bibba.jpg',
          'notForEating': true,
          'title': {'en': 'Bibba Nut', 'hi': 'बिब्बा', 'mr': 'बिब्बा'},
          'unit': {'en': 'kg', 'hi': 'किग्रा', 'mr': 'किलो'},
          'listings': [
            {
              'id': 'nb-1',
              'sellerType': 'cfrholder',
              'pricePerUnitPaise': 12000,
              'mrpPerUnitPaise': 15000,
              'quantityTotal': 40,
              'quantitySold': 5,
              'minOrderQuantity': 1,
              'daysAgo': 2,
            },
          ],
        },
        // Product 5: Shade tree with NO listings (not open)
        {
          'productCode': 'shade_banyan',
          'categorySlug': 'shade-trees',
          'image': 'assets/catalog/shade_banyan.jpg',
          'notForEating': false,
          'title': {'en': 'Banyan', 'hi': 'बरगद', 'mr': 'वड'},
          'unit': {'en': 'piece', 'hi': 'नग', 'mr': 'नग'},
          'listings': [],
        },
      ],
    };

    test('topDeals includes only products with discount > 0, sorted by discount DESC then price ASC', () async {
      final repo = SampleShopRepository.fromMap(sampleMap);
      final home = await repo.getHome();

      // Products with discount > 0: bamboo_basket (30%), nuts_bibba (20%), fruit_mango (10%)
      // forest_honey has 0% discount, shade_banyan has 0 listings
      expect(home.topDeals.length, 3);
      expect(home.topDeals[0].productCode, 'bamboo_basket'); // 30%
      expect(home.topDeals[1].productCode, 'nuts_bibba'); // 20%
      expect(home.topDeals[2].productCode, 'fruit_mango'); // 10%
    });

    test('bestSellers includes only listings with quantitySold > 0, sorted DESC', () async {
      final repo = SampleShopRepository.fromMap(sampleMap);
      final home = await repo.getHome();

      // Listings with sold > 0: b-1 (60), m-1 (20), h-1 (10), nb-1 (5)
      expect(home.bestSellers.length, 4);
      expect(home.bestSellers[0].listing.id, 'b-1');
      expect(home.bestSellers[0].listing.quantitySold, 60);
      expect(home.bestSellers[1].listing.id, 'm-1');
      expect(home.bestSellers[1].listing.quantitySold, 20);
      expect(home.bestSellers[2].listing.id, 'h-1');
      expect(home.bestSellers[2].listing.quantitySold, 10);
      expect(home.bestSellers[3].listing.id, 'nb-1');
      expect(home.bestSellers[3].listing.quantitySold, 5);
    });

    test('newArrivals sorts every listing by daysAgo ASC', () async {
      final repo = SampleShopRepository.fromMap(sampleMap);
      final home = await repo.getHome();

      // daysAgo: b-1 (1), nb-1 (2), m-2 (4), h-1 (8), m-1 (10)
      expect(home.newArrivals.length, 5);
      expect(home.newArrivals[0].listing.daysAgo, 1);
      expect(home.newArrivals[1].listing.daysAgo, 2);
      expect(home.newArrivals[2].listing.daysAgo, 4);
      expect(home.newArrivals[3].listing.daysAgo, 8);
      expect(home.newArrivals[4].listing.daysAgo, 10);
    });

    test('categories drops empty categories and retains fixed order', () async {
      final repo = SampleShopRepository.fromMap(sampleMap);
      final home = await repo.getHome();

      // Fixed order: handicrafts-bamboo, fruit, nuts-and-seeds, forest-produce
      // flowers, medicinal-plants, timber-trees, shade-trees have 0 listings and must be omitted
      final slugs = home.categories.map((c) => c.slug).toList();
      expect(slugs, [
        'handicrafts-bamboo',
        'fruit',
        'nuts-and-seeds',
        'forest-produce',
      ]);
      expect(slugs.contains('shade-trees'), isFalse);
    });

    test('getProducts filters by category, matches Hindi or Marathi titles, and ignores case', () async {
      final repo = SampleShopRepository.fromMap(sampleMap);

      // Category with open products
      final fruitProds = await repo.getProducts(categorySlug: 'fruit');
      expect(fruitProds.length, 1);
      expect(fruitProds.first.productCode, 'fruit_mango');

      // Category with no open products (shade-trees has only empty listings)
      final shadeProds = await repo.getProducts(categorySlug: 'shade-trees');
      expect(shadeProds, isEmpty);

      // Search matching English case-insensitively
      final searchEn = await repo.getProducts(query: 'MaNgO');
      expect(searchEn.length, 1);
      expect(searchEn.first.productCode, 'fruit_mango');

      // Search matching Hindi title
      final searchHi = await repo.getProducts(query: 'आम');
      expect(searchHi.length, 1);
      expect(searchHi.first.productCode, 'fruit_mango');

      // Search matching Marathi title
      final searchMr = await repo.getProducts(query: 'आंबा');
      expect(searchMr.length, 1);
      expect(searchMr.first.productCode, 'fruit_mango');
    });
  });
}
