import 'package:flutter/material.dart';

const _dir = 'assets/products';

/// Picks the bundled illustration that matches the product name (English or Marathi).
/// Order matters: the most specific words are checked first.
String productAsset(String titleEn, String titleMr) {
  final en = titleEn.toLowerCase();
  final mr = titleMr;
  bool has(List<String> words) => words.any((w) => en.contains(w) || mr.contains(w));

  if (has(['stake'])) return '$_dir/stake.png';
  if (has(['planter', 'कुंडी'])) return '$_dir/planter.png';
  if (has(['basket', 'टोपली', 'टोपल्या'])) return '$_dir/basket.png';
  if (has(['leaf plate', 'पत्रावळी'])) return '$_dir/leaf.png';
  if (has(['rope', 'दोरी'])) return '$_dir/rope.png';
  if (has(['seed packet', 'बियाणे'])) return '$_dir/seed.png';
  if (has(['dried fruit', 'वाळवलेली फळे'])) return '$_dir/dfruit.png';
  if (has(['tamarind', 'चिंच'])) return '$_dir/tamarind.png';
  if (has(['preserve', 'मुरांबा'])) return '$_dir/preserve.png';
  if (has(['herb', 'ashwa', 'औषधी', 'अश्व'])) return '$_dir/herb.png';
  if (has(['honey', ' मध', 'मधपेटी'])) return '$_dir/honey.png';
  if (has(['bamboo', 'बांबू'])) return '$_dir/basket.png';
  return '$_dir/forest.png';
}

/// Shows a bundled asset (path starting with `assets/`) or a network image.
class ProductImage extends StatelessWidget {
  final String src;
  final BoxFit fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  const ProductImage(this.src, {super.key, this.fit = BoxFit.cover, this.errorBuilder, this.loadingBuilder});

  @override
  Widget build(BuildContext context) {
    if (src.startsWith('assets/')) {
      // Prefer a real photo (assets/products/photos/<name>.jpg) when one has been added;
      // otherwise fall back to the bundled illustration.
      final photo = src.replaceFirst('assets/products/', 'assets/products/photos/').replaceFirst('.png', '.jpg');
      return Image.asset(photo, fit: fit, errorBuilder: (_, __, ___) => Image.asset(src, fit: fit, errorBuilder: errorBuilder));
    }
    return Image.network(src, fit: fit, errorBuilder: errorBuilder, loadingBuilder: loadingBuilder);
  }
}
