import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/shop_repository.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';

/// The Categories tab: a grid of category tiles (picture and name). Only categories that have
/// sellers are shown, so no tile opens an empty page. "All products" comes first.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final products = ref.watch(allOpenProductsProvider).valueOrNull ?? const <ShopProduct>[];
    final cartCount = ref.watch(cartItemCountProvider);

    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Tiles: "All products", then the categories that have open products, in the fixed order
    final tiles = <_Tile>[
      _Tile(slug: 'all', label: strings.allProductsTitle, count: products.length, imageAsset: null),
    ];
    for (final slug in SampleShopRepository.categoryFixedOrder) {
      final inCategory = products.where((p) => p.categorySlug == slug).toList();
      if (inCategory.isEmpty) continue;
      tiles.add(_Tile(
        slug: slug,
        label: strings.categoryLabel(slug),
        count: inCategory.length,
        imageAsset: inCategory.first.imageAsset,
      ));
    }

    const columns = 3;
    final rows = <List<_Tile>>[];
    for (var i = 0; i < tiles.length; i += columns) {
      rows.add(tiles.sublist(i, i + columns > tiles.length ? tiles.length : i + columns));
    }

    return AppBackground(
      categorySlug: 'all',
      useSafeArea: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 16.0 * s, 16.0 * s, 8.0 * s),
            child: Text(
              strings.navCategories,
              style: TextStyle(
                fontSize: 24.0 * s,
                fontWeight: FontWeight.w800,
                color: tokens.heading,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.0 * s,
                8.0 * s,
                16.0 * s,
                bottomInset + 24.0 * s + (cartCount > 0 ? 76.0 * s : 0.0),
              ),
              child: Column(
                children: [
                  for (final row in rows) ...[
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var c = 0; c < columns; c++) ...[
                            if (c > 0) SizedBox(width: 12.0 * s),
                            Expanded(
                              child: c < row.length
                                  ? _CategoryTile(tile: row[c], tokens: tokens, strings: strings, s: s)
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0 * s),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile {
  final String slug;
  final String label;
  final int count;
  final String? imageAsset;

  const _Tile({required this.slug, required this.label, required this.count, required this.imageAsset});
}

class _CategoryTile extends StatelessWidget {
  final _Tile tile;
  final VanRozgarColorTokens tokens;
  final AppStrings strings;
  final double s;

  const _CategoryTile({required this.tile, required this.tokens, required this.strings, required this.s});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${tile.label}, ${strings.resultsCount(tile.count)}',
      child: InkWell(
        key: Key('category_tile_${tile.slug}'),
        borderRadius: BorderRadius.circular(16.0 * s),
        onTap: () => context.push('/categories/${tile.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.chipBg,
                  borderRadius: BorderRadius.circular(16.0 * s),
                ),
                padding: EdgeInsets.all(8.0 * s),
                child: tile.imageAsset == null
                    ? Icon(Icons.apps_rounded, size: 36.0 * s, color: tokens.chipText)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10.0 * s),
                        child: Image.asset(
                          tile.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.eco_outlined,
                            color: tokens.primaryGreen.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 6.0 * s),
            Text(
              tile.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5 * s,
                fontWeight: FontWeight.w700,
                color: tokens.heading,
              ),
            ),
            Text(
              strings.resultsCount(tile.count),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.0 * s, color: tokens.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
