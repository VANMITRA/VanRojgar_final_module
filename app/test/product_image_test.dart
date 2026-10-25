import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/utils/product_image.dart';

void main() {
  test('every pilot listing gets a matching illustration (never the generic forest)', () {
    // Typical titles of each product; the app ships no demo listings any more.
    final items = [
      for (final t in const [
        ['Bamboo planter', 'बांबू कुंडी'],
        ['Bamboo utility basket', 'बांबूची टोपली'],
        ['Bamboo garden-stake', 'बांबू काठी'],
        ['Managed-apiary honey (500 g jar)', 'मधपेटीतील मध'],
        ['Dried cultivated herb sachet (100 g)', 'औषधी वनस्पती'],
        ['Fruit preserve (200 g jar)', 'फळांचा मुरांबा'],
        ['Tamarind preserve (200 g jar)', 'चिंचेचा मुरांबा'],
        ['Nursery seed packet', 'बियाणे'],
        ['Leaf plates (pack of 25)', 'पत्रावळी'],
        ['Natural-fibre rope', 'दोरी'],
        ['Dried fruit pack (100 g)', 'सुकामेवा'],
      ])
        {'titleEn': t[0], 'titleMr': t[1]},
    ];
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
