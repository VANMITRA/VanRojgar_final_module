import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/category_query.dart';
import '../l10n/app_strings.dart';
import '../l10n/shop_extra_strings.dart';
import '../models/catalog_models.dart';
import '../providers/catalog_providers.dart';
import '../theme/van_rozgar_tokens.dart';
import '../widgets/app_background.dart';
import '../widgets/product_card.dart';

/// One category (or "all"): a grid of product cards with sort and filters. Opened from the
/// Categories tab. Each card shows the live "sold / left" bar, and ADD opens the quantity picker.
class CategoryPage extends ConsumerStatefulWidget {
  final String slug;

  const CategoryPage({super.key, required this.slug});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  CategorySort _sort = CategorySort.popular;
  CategoryFilters _filters = const CategoryFilters();

  Future<void> _openSheet(List<ShopProduct> products) async {
    final result = await showModalBottomSheet<(CategorySort, CategoryFilters)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SortFilterSheet(
        sort: _sort,
        filters: _filters,
        bounds: categoryPriceBounds(products),
        language: ref.read(uiV2LanguageProvider),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _sort = result.$1;
        _filters = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final products = ref.watch(categoryProductsProvider(widget.slug)).valueOrNull ?? const <ShopProduct>[];
    final cartCount = ref.watch(cartItemCountProvider);
    final shown = applyCategoryQuery(products, _sort, _filters);

    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 360.0).clamp(0.85, 1.25);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final title = widget.slug == 'all' ? strings.allProductsTitle : strings.categoryLabel(widget.slug);
    final crossAxisCount = width >= 960 ? 4 : (width >= 600 ? 3 : 2);
    final spacing = 12.0 * s;
    final rowCount = (shown.length / crossAxisCount).ceil();

    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/categories');
      }
    }

    Widget emptyCard(String text, {Widget? action}) => SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24.0 * s),
            child: Container(
              padding: EdgeInsets.all(24.0 * s),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(16.0 * s),
                border: Border.all(color: tokens.borders),
              ),
              child: Column(
                children: [
                  Icon(Icons.eco_outlined, size: 36.0 * s, color: tokens.primaryGreen.withValues(alpha: 0.6)),
                  SizedBox(height: 12.0 * s),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.0 * s, color: tokens.mutedText),
                  ),
                  if (action != null) ...[SizedBox(height: 12.0 * s), action],
                ],
              ),
            ),
          ),
        );

    return AppBackground(
      categorySlug: widget.slug,
      useSafeArea: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar: back arrow, the category name, and how many products are shown
          Padding(
            padding: EdgeInsets.fromLTRB(4.0 * s, 4.0 * s, 16.0 * s, 0),
            child: Row(
              children: [
                IconButton(
                  key: const Key('category_back'),
                  tooltip: strings.backLabel,
                  onPressed: goBack,
                  icon: Icon(Icons.arrow_back, color: tokens.heading),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0 * s,
                      fontWeight: FontWeight.w800,
                      color: tokens.heading,
                    ),
                  ),
                ),
                Text(
                  strings.resultsCount(shown.length),
                  key: const Key('category_count'),
                  style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                ),
              ],
            ),
          ),
          // Sort and filter button, and the current sort
          Padding(
            padding: EdgeInsets.fromLTRB(16.0 * s, 4.0 * s, 16.0 * s, 8.0 * s),
            child: Row(
              children: [
                Flexible(
                  child: OutlinedButton.icon(
                    key: const Key('sort_filter_button'),
                    onPressed: products.isEmpty ? null : () => _openSheet(products),
                    icon: Icon(Icons.tune, size: 18.0 * s),
                    label: Text(
                      _filters.isActive
                          ? '${strings.sortAndFilter} (${_filters.activeCount})'
                          : strings.sortAndFilter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.primaryGreen,
                      side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                      minimumSize: Size(0, 44.0 * s),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10.0 * s),
                Flexible(
                  child: Text(
                    strings.sortLabel(_sort.name),
                    key: const Key('current_sort'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5 * s, color: tokens.mutedText),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (products.isEmpty)
                  emptyCard(strings.noSellersYet)
                else if (shown.isEmpty)
                  emptyCard(
                    strings.nothingFound,
                    action: FilledButton(
                      key: const Key('clear_filters'),
                      onPressed: () => setState(() => _filters = const CategoryFilters()),
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.primaryGreen,
                        foregroundColor: tokens.onPrimaryGreen,
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(strings.clearFilters, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * s),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, rowIndex) {
                          final start = rowIndex * crossAxisCount;
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var c = 0; c < crossAxisCount; c++) ...[
                                    if (c > 0) SizedBox(width: spacing),
                                    Expanded(
                                      child: start + c < shown.length
                                          ? ProductCard(
                                              product: shown[start + c],
                                              cardType: ProductCardType.grid,
                                              showStockBar: true,
                                              useQuantityPicker: true,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: rowCount,
                      ),
                    ),
                  ),
                // Room for the floating cart pill
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomInset + 24.0 * s + (cartCount > 0 ? 76.0 * s : 0.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with the sort options (chips), the price range, "only discounted", Clear and Apply.
class _SortFilterSheet extends StatefulWidget {
  final CategorySort sort;
  final CategoryFilters filters;
  final RangeValues bounds;
  final AppLanguage language;

  const _SortFilterSheet({
    required this.sort,
    required this.filters,
    required this.bounds,
    required this.language,
  });

  @override
  State<_SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<_SortFilterSheet> {
  late CategorySort _sort = widget.sort;
  late RangeValues _range = widget.filters.priceRupees ?? widget.bounds;
  late bool _onlyDiscounted = widget.filters.onlyDiscounted;

  bool get _hasSlider => widget.bounds.end > widget.bounds.start;

  CategoryFilters _currentFilters() {
    final fullRange = _range.start <= widget.bounds.start && _range.end >= widget.bounds.end;
    return CategoryFilters(
      priceRupees: (_hasSlider && !fullRange) ? _range : null,
      onlyDiscounted: _onlyDiscounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tokens = theme.extension<VanRozgarColorTokens>() ??
        (isDark ? VanRozgarColorTokens.dark : VanRozgarColorTokens.light);
    final strings = AppStrings.of(widget.language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    String sortName(CategorySort sort) => strings.sortLabel(sort.name);

    return SafeArea(
      top: false,
      // A Material (not a plain decorated Container) so the switch and chips can paint their ink
      child: Material(
        key: const Key('sort_filter_sheet'),
        color: tokens.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0 * s)),
          side: BorderSide(color: tokens.borders),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0 * s, 12.0 * s, 20.0 * s, 20.0 * s),
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0 * s,
                  height: 4.0 * s,
                  decoration: BoxDecoration(color: tokens.borders, borderRadius: BorderRadius.circular(2.0)),
                ),
              ),
              SizedBox(height: 14.0 * s),
              Text(
                strings.sortTitle,
                style: TextStyle(fontSize: 18.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 8.0 * s),
              Wrap(
                spacing: 8.0 * s,
                runSpacing: 4.0 * s,
                children: [
                  for (final option in CategorySort.values)
                    ChoiceChip(
                      key: Key('sort_${option.name}'),
                      label: Text(sortName(option)),
                      selected: _sort == option,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _sort = option),
                      selectedColor: tokens.primaryGreen,
                      backgroundColor: tokens.chipBg,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _sort == option ? tokens.onPrimaryGreen : tokens.chipText,
                      ),
                      shape: const StadiumBorder(),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                ],
              ),
              SizedBox(height: 16.0 * s),
              Text(
                strings.filtersTitle,
                style: TextStyle(fontSize: 18.0 * s, fontWeight: FontWeight.w800, color: tokens.heading),
              ),
              SizedBox(height: 8.0 * s),
              if (_hasSlider) ...[
                Text(
                  '${strings.priceRangeLabel}: ${formatRupees((_range.start * 100).round())} – ${formatRupees((_range.end * 100).round())}',
                  style: TextStyle(fontSize: 13.0 * s, color: tokens.mutedText),
                ),
                RangeSlider(
                  key: const Key('price_slider'),
                  values: _range,
                  min: widget.bounds.start,
                  max: widget.bounds.end,
                  divisions: (widget.bounds.end - widget.bounds.start).round().clamp(1, 200),
                  activeColor: tokens.primaryGreen,
                  inactiveColor: tokens.borders,
                  onChanged: (values) => setState(() => _range = RangeValues(
                        values.start.roundToDouble(),
                        values.end.roundToDouble(),
                      )),
                ),
              ],
              SwitchListTile(
                key: const Key('only_discounted_switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  strings.onlyDiscounted,
                  style: TextStyle(fontWeight: FontWeight.w600, color: tokens.heading),
                ),
                value: _onlyDiscounted,
                activeThumbColor: tokens.primaryGreen,
                onChanged: (value) => setState(() => _onlyDiscounted = value),
              ),
              SizedBox(height: 8.0 * s),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('filters_clear'),
                      onPressed: () => Navigator.of(context).pop((CategorySort.popular, const CategoryFilters())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.primaryGreen,
                        side: BorderSide(color: tokens.primaryGreen, width: 1.5),
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(strings.clearLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 12.0 * s),
                  Expanded(
                    child: FilledButton(
                      key: const Key('filters_apply'),
                      onPressed: () => Navigator.of(context).pop((_sort, _currentFilters())),
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.primaryGreen,
                        foregroundColor: tokens.onPrimaryGreen,
                        minimumSize: Size(0, 48.0 * s),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(strings.applyLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
