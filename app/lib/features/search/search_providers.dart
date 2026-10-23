import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/listing.dart';
import '../../shared/models/gram_sabha.dart';
import '../auth/auth_providers.dart';

class SearchResults {
  final List<ListingModel> listings;
  final List<GramSabhaModel> gramsabhas;
  final String? nextCursor;

  SearchResults({required this.listings, required this.gramsabhas, this.nextCursor});
}

final searchProvider = FutureProvider.family<SearchResults, Map<String, dynamic>>((ref, params) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/search', queryParameters: params);

  final listingsRaw = res['listings'] as List? ?? [];
  final gsRaw = res['gramsabhas'] as List? ?? [];
  final nextCursor = res['nextCursor'] as String?;

  return SearchResults(
    listings: listingsRaw.map((e) => ListingModel.fromJson(e)).toList(),
    gramsabhas: gsRaw.map((e) => GramSabhaModel.fromJson(e)).toList(),
    nextCursor: nextCursor,
  );
});
