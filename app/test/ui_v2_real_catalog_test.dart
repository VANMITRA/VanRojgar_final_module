import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/data/shop_repository.dart';

/// Loads the REAL asset assets/catalog/sample_catalog.json (the data the phone shows) and checks
/// that it parses, that the Home feed rules give sensible results, and that every picture exists.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the real sample catalog parses and gives a sensible Home feed', () async {
    final repo = SampleShopRepository();
    final open = await repo.getProducts();
    final home = await repo.getHome();

    // 43 products in the file, 29 of them have sellers (the 14 trees have none)
    expect(open.length, 29);
    expect(home.openListings, 63);

    expect(home.topDeals, isNotEmpty);
    expect(home.topDeals.length, lessThanOrEqualTo(12));
    for (final p in home.topDeals) {
      expect(p.bestDiscountPercent, greaterThan(0));
    }
    // sorted by best discount, highest first
    for (var i = 1; i < home.topDeals.length; i++) {
      expect(home.topDeals[i - 1].bestDiscountPercent, greaterThanOrEqualTo(home.topDeals[i].bestDiscountPercent));
    }

    expect(home.bestSellers.length, 12);
    expect(home.newArrivals.length, 12);

    // only categories that have sellers, in the fixed order (trees are hidden)
    expect(home.categories.map((c) => c.slug).toList(), [
      'handicrafts-bamboo',
      'fruit',
      'nuts-and-seeds',
      'flowers',
      'medicinal-plants',
      'forest-produce',
    ]);

    // trees have pictures but no sellers: the category tabs show the empty state
    expect(await repo.getProducts(categorySlug: 'timber-trees'), isEmpty);
    expect(await repo.getProducts(categorySlug: 'shade-trees'), isEmpty);

    // search works in Hindi and Marathi
    expect((await repo.getProducts(query: 'आम')).map((p) => p.productCode), contains('fruit_mango'));
    expect((await repo.getProducts(query: 'आंबा')).map((p) => p.productCode), contains('fruit_mango'));

    // the two products that are not for eating are flagged
    final flagged = open.where((p) => p.notForEating).map((p) => p.productCode).toSet();
    expect(flagged, {'nuts_bibba', 'herb_gunj'});
  });

  test('every picture the Home page can show exists as an asset', () async {
    final repo = SampleShopRepository();
    final open = await repo.getProducts();
    final paths = <String>{
      ...open.map((p) => p.imageAsset),
      // the hero banner pictures
      'assets/catalog/bamboo.jpg',
      'assets/catalog/fruit_mango.jpg',
      'assets/catalog/fruit_awla.jpg',
    };
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000), reason: path);
    }
  });
}
