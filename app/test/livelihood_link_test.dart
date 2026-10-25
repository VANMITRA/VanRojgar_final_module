import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/utils/livelihood_link.dart';

void main() {
  test('Gram Sabha and villager accounts get a link to their own livelihood tab', () {
    expect(
      livelihoodRouteFor('gramsabha', village: 'मातोरी', taluka: 'Nashik', product: 'honey'),
      startsWith('/gs/livelihood?'),
    );
    expect(
      livelihoodRouteFor('villager', village: 'Matori', taluka: 'Nashik'),
      '/v/livelihood?village=Matori&taluka=Nashik',
    );
  });

  test('buyers and signed-out users get no link, because they have no livelihood tab', () {
    expect(livelihoodRouteFor('buyer', village: 'Matori', taluka: 'Nashik'), isNull);
    expect(livelihoodRouteFor(null, village: 'Matori', taluka: 'Nashik'), isNull);
  });

  test('the village and product survive a round trip through the route', () {
    final route = livelihoodRouteFor('villager', village: 'मातोरी', taluka: 'Nashik', product: 'leaf-plate')!;
    final q = Uri.parse(route).queryParameters;
    expect(q['village'], 'मातोरी');
    expect(q['product'], 'leaf-plate');
  });
}
