import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where a person came from when they opened the Livelihood tab from the marketplace: the village of the listing
/// they were looking at and its product. Set by the shell from the route's query parameters.
class LivelihoodLaunch {
  const LivelihoodLaunch({this.village, this.taluka, this.product});

  final String? village;
  final String? taluka;
  final String? product;

  bool get isEmpty => (product == null || product!.isEmpty) && (village == null || village!.isEmpty);

  factory LivelihoodLaunch.fromQuery(Map<String, String> query) => LivelihoodLaunch(
        village: query['village'],
        taluka: query['taluka'],
        product: query['product'],
      );

  @override
  bool operator ==(Object other) =>
      other is LivelihoodLaunch && other.village == village && other.taluka == taluka && other.product == product;

  @override
  int get hashCode => Object.hash(village, taluka, product);
}

/// The current launch context, or null when the tab was opened normally (or the banner was dismissed).
final livelihoodLaunchProvider = StateProvider<LivelihoodLaunch?>((ref) => null);
