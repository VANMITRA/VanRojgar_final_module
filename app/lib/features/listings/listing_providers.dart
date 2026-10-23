import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/listing.dart';
import '../../shared/models/category.dart';
import '../auth/auth_providers.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/categories');
  return (res as List).map((e) => CategoryModel.fromJson(e)).toList();
});

final myListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/listings/mine');
  return (res as List).map((e) => ListingModel.fromJson(e)).toList();
});

final listingDetailProvider = FutureProvider.family<ListingModel, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/listings/$id');
  return ListingModel.fromJson(res);
});
