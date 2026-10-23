import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/utils/product_image.dart';

void main() {
  test('every pilot listing gets a matching illustration (never the generic forest)', () {
    final items = jsonDecode(File('../server/src/seed/data/demo_listings.json').readAsStringSync()) as List;
    expect(items.length, 50);
    const expected = {
      'Bamboo planter': 'planter', 'Bamboo utility basket': 'basket', 'Bamboo garden-stake': 'stake',
      'Managed-apiary honey': 'honey', 'Dried cultivated herb': 'herb', 'Fruit preserve': 'preserve',
      'Tamarind preserve': 'tamarind', 'Nursery seed packet': 'seed', 'Leaf plates': 'leaf',
      'Natural-fibre rope': 'rope', 'Dried fruit pack': 'dfruit',
    };
    for (final it in items) {
      final en = it['titleEn'] as String;
      final key = expected.entries.firstWhere((e) => en.startsWith(e.key)).value;
      final path = productAsset(en, it['titleMr'] as String);
      expect(path, 'assets/products/$key.png', reason: en);
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
