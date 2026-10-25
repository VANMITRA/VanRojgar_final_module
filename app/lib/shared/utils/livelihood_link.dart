/// The link from a marketplace listing to the livelihood report (docs/plan.md section 3).
///
/// Only Gram Sabha and villager accounts have the livelihood tab; buyers get no link.
/// The livelihood screen reads `village`, `taluka` and `product` from the route's query parameters.
String? livelihoodRouteFor(
  String? role, {
  required String village,
  required String taluka,
  String? product,
}) {
  final base = switch (role) {
    'gramsabha' => '/gs/livelihood',
    'villager' => '/v/livelihood',
    _ => null,
  };
  if (base == null) return null;
  return Uri(path: base, queryParameters: {
    'village': village,
    'taluka': taluka,
    if (product != null && product.isNotEmpty) 'product': product,
  }).toString();
}
