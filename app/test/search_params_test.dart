import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/features/search/search_providers.dart';

void main() {
  test('equal queries give the same map instance, so Riverpod fetches once', () {
    final a = stableSearchParams({'minQty': 50});
    final b = stableSearchParams({'minQty': 50});
    expect(identical(a, b), isTrue);
  });

  test('key order does not matter, different content does', () {
    final a = stableSearchParams({'q': 'honey', 'sort': 'newest'});
    final b = stableSearchParams({'sort': 'newest', 'q': 'honey'});
    final c = stableSearchParams({'q': 'bamboo', 'sort': 'newest'});
    expect(identical(a, b), isTrue);
    expect(identical(a, c), isFalse);
    expect(c['q'], 'bamboo');
  });
}
