import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/search_pill.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/async_value_view.dart';
import '../search/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _sort = 'newest';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;

  Map<String, dynamic> get _queryParams => {
    if (_searchController.text.trim().isNotEmpty) 'q': _searchController.text.trim(),
    if (_selectedCategory != null) 'category': _selectedCategory,
    if (_minPrice != null) 'minPrice': _minPrice,
    if (_maxPrice != null) 'maxPrice': _maxPrice,
    'sort': _sort,
    'lat': 19.9975,
    'lng': 73.7898,
  };

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VrText('फिल्टर्स • Search Filters', style: TextStyle(color: context.vr.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const VrText('क्रमवारी (Sort by):', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const VrText('Newest'),
                  selected: _sort == 'newest',
                  onSelected: (val) {
                    if (val) setState(() => _sort = 'newest');
                    Navigator.pop(ctx);
                  },
                ),
                ChoiceChip(
                  label: const VrText('Lowest Price'),
                  selected: _sort == 'price_asc',
                  onSelected: (val) {
                    if (val) setState(() => _sort = 'price_asc');
                    Navigator.pop(ctx);
                  },
                ),
                ChoiceChip(
                  label: const VrText('Nearest (जवळचे)'),
                  selected: _sort == 'nearest',
                  onSelected: (val) {
                    if (val) setState(() => _sort = 'nearest');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider(_queryParams));

    return Scaffold(
      appBar: AppBar(title: const VrText('वनउत्पादने शोधा • Search')),
      body: SafeArea(
        child: Column(
          children: [
            SearchPill(
              controller: _searchController,
              hintText: AppInputHints.searchForest(context),
              onChanged: (_) => setState(() {}),
              onFilterTap: _showFilterModal,
            ),
            Expanded(
              child: AsyncValueView(
                value: searchAsync,
                emptyMessage: 'कोणतीही उत्पादने सापडली नाहीत (No listings found)',
                onRetry: () => ref.invalidate(searchProvider),
                data: (results) {
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (results.gramsabhas.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: VrText(
                            'ग्रामसभा (Gram Sabhas)',
                            style: TextStyle(color: context.vr.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          height: 75,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: results.gramsabhas.length,
                            itemBuilder: (ctx, i) {
                              final gs = results.gramsabhas[i];
                              return GestureDetector(
                                onTap: () => context.push('/gramsabhas/${gs.id}'),
                                child: Container(
                                  width: 170,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: context.vr.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: context.vr.outline),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      VrText(
                                        'ग्रामसभा ${gs.villageMr}',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      VrText(
                                        '${gs.taluka} • नाशिक',
                                        style: TextStyle(color: context.vr.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: VrText(
                          'उत्पादने (Available Produce)',
                          style: TextStyle(color: context.vr.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      ...results.listings.map((item) => ListingCard(
                        listing: item,
                        onTap: () => context.push('/listings/${item.id}'),
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
