import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_input_hints.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../../shared/widgets/search_pill.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/vr_fab.dart';
import '../../shared/widgets/async_value_view.dart';
import '../listings/listing_providers.dart';

class GsListingsScreen extends ConsumerStatefulWidget {
  const GsListingsScreen({super.key});

  @override
  ConsumerState<GsListingsScreen> createState() => _GsListingsScreenState();
}

class _GsListingsScreenState extends ConsumerState<GsListingsScreen> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;
    final listingsAsync = ref.watch(myListingsProvider);

    return Scaffold(
      floatingActionButton: VrFab(
        label: 'Add Listing • जोडा',
        icon: Icons.add,
        onPressed: () => context.push('/gs/listings/new'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myListingsProvider),
          child: Column(
            children: [
              const Breadcrumb(segments: ['मुख्यपृष्ठ (Home)', 'माझी उत्पादने (My Listings)']),
              SearchPill(
                hintText: AppInputHints.searchMyListings(context),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
              ),

              Expanded(
                child: AsyncValueView(
                  value: listingsAsync,
                  emptyMessage: 'अद्याप एकही उत्पादन नोंदवलेले नाही (No listings yet)',
                  onRetry: () => ref.invalidate(myListingsProvider),
                  data: (listings) {
                    var filtered = listings;
                    if (_searchQuery.isNotEmpty) {
                      filtered = filtered.where((l) =>
                        l.titleMr.toLowerCase().contains(_searchQuery) ||
                        l.titleEn.toLowerCase().contains(_searchQuery)
                      ).toList();
                    }
                    if (_statusFilter != null) {
                      filtered = filtered.where((l) => l.status == _statusFilter).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: VrText(
                          'उत्पादन सापडले नाही (No listings matched).',
                          style: TextStyle(color: tokens.textMuted),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 120, top: 6),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        return ListingCard(
                          listing: item,
                          onTap: () => context.push('/listings/${item.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
