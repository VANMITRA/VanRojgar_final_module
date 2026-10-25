import 'roles.dart';

/// The link from a marketplace listing to the livelihood report (docs/plan.md section 3).
///
/// Only a CFR holder has the livelihood tab; farmers, the Gram Sabha and buyers get no link.
/// The livelihood screen reads `village`, `taluka` and `product` from the route's query parameters.
String? livelihoodRouteFor(
  String? role, {
  required String village,
  required String taluka,
  String? product,
}) {
  if (!canUseLivelihood(role)) return null;
  const base = '/c/livelihood';
  return Uri(path: base, queryParameters: {
    'village': village,
    'taluka': taluka,
    if (product != null && product.isNotEmpty) 'product': product,
  }).toString();
}
