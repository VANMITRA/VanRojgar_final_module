import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/shared/utils/livelihood_link.dart';
import 'package:vanrozgar/shared/utils/roles.dart';

void main() {
  test('only a CFR holder gets a link to the livelihood tab', () {
    expect(
      livelihoodRouteFor('cfrholder', village: 'Matori', taluka: 'Nashik'),
      '/c/livelihood?village=Matori&taluka=Nashik',
    );
    expect(
      livelihoodRouteFor('cfrholder', village: 'मातोरी', taluka: 'Nashik', product: 'honey'),
      startsWith('/c/livelihood?'),
    );
  });

  test('farmers, the Gram Sabha, buyers and signed-out users get no link, because they have no livelihood tab', () {
    for (final role in ['villager', 'gramsabha', 'buyer', 'team', null]) {
      expect(livelihoodRouteFor(role, village: 'Matori', taluka: 'Nashik'), isNull, reason: '$role');
    }
  });

  test('the village and product survive a round trip through the route', () {
    final route = livelihoodRouteFor('cfrholder', village: 'मातोरी', taluka: 'Nashik', product: 'leaf-plate')!;
    final q = Uri.parse(route).queryParameters;
    expect(q['village'], 'मातोरी');
    expect(q['product'], 'leaf-plate');
  });

  test('each role lands in its own portal; only the CFR holder can use the livelihood report', () {
    expect(homeRouteFor('gramsabha'), '/gs');
    expect(homeRouteFor('buyer'), '/b');
    expect(homeRouteFor('cfrholder'), '/c');
    expect(homeRouteFor('villager'), '/v');
    expect(homeRouteFor(null), '/v');
    expect(canUseLivelihood('cfrholder'), isTrue);
    for (final role in ['villager', 'gramsabha', 'buyer', null]) {
      expect(canUseLivelihood(role), isFalse, reason: '$role');
    }
  });

  test('a person picks a village when they sign up as a Gram Sabha, a farmer or a CFR holder, not as a buyer', () {
    expect(isVillageRole('gramsabha') && isVillageRole('villager') && isVillageRole('cfrholder'), isTrue);
    expect(isVillageRole('buyer'), isFalse);
  });

  test('every role has its own label', () {
    final labels = ['gramsabha', 'buyer', 'cfrholder', 'villager'].map(roleLabelFor).toSet();
    expect(labels.length, 4);
    expect(roleLabelFor('cfrholder'), contains('CFR'));
  });
}
