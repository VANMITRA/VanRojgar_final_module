import 'dart:convert';
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

final Map<String, Map<String, dynamic>> _stableParams = {};

/// Riverpod compares family arguments with `==`, and two Dart maps with the same content are not `==`.
/// Passing a fresh map literal to [searchProvider] therefore starts a new request on every rebuild, forever.
/// This returns the same instance for the same content, so an unchanged query is fetched once.
Map<String, dynamic> stableSearchParams(Map<String, dynamic> params) {
  final key = jsonEncode(Map.fromEntries(params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))));
  if (_stableParams.length > 100) _stableParams.clear();
  return _stableParams.putIfAbsent(key, () => Map<String, dynamic>.unmodifiable(params));
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
