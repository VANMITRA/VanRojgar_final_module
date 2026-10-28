import 'package:flutter_test/flutter_test.dart';
import 'package:vanrozgar/ui_v2/shell/landing_geometry.dart';

void main() {
  group('LandingGeometry Unit Tests', () {
    test('Reference Card 1 points match specifications', () {
      const card1 = LandingGeometry.card1Reference;
      expect(card1.topLeft, const Offset(0.436, 0.159));
      expect(card1.topRight, const Offset(0.969, 0.193));
      expect(card1.bottomRight, const Offset(0.998, 0.486));
      expect(card1.bottomLeft, const Offset(0.512, 0.526));
    });

    test('Reference Card 2 points match specifications', () {
      const card2 = LandingGeometry.card2Reference;
      expect(card2.topLeft, const Offset(0.488, 0.568));
      expect(card2.topRight, const Offset(0.990, 0.493));
      expect(card2.bottomRight, const Offset(0.988, 0.828));
      expect(card2.bottomLeft, const Offset(0.565, 0.855));
    });

    test('Thin gap between Card 1 bottom and Card 2 top at right edge is ~0.007 H', () {
      final gap = LandingGeometry.card2Reference.topRight.dy - LandingGeometry.card1Reference.bottomRight.dy;
      expect(gap, closeTo(0.007, 0.001));
    });

    test('Mirror function maps u to 1 - u', () {
      const card1 = LandingGeometry.card1Reference;
      final mirrored = card1.mirrored();

      // Card 1 right edge was at ~0.998, mirrored left edge should be at ~0.002
      expect(mirrored.bottomLeft.dx, closeTo(1.0 - card1.bottomRight.dx, 0.0001));
      expect(mirrored.topLeft.dx, closeTo(1.0 - card1.topRight.dx, 0.0001));
      expect(mirrored.topRight.dx, closeTo(1.0 - card1.topLeft.dx, 0.0001));
      expect(mirrored.bottomRight.dx, closeTo(1.0 - card1.bottomLeft.dx, 0.0001));

      // Y coordinates remain unchanged
      expect(mirrored.topLeft.dy, card1.topRight.dy);
      expect(mirrored.topRight.dy, card1.topLeft.dy);
      expect(mirrored.bottomRight.dy, card1.bottomLeft.dy);
      expect(mirrored.bottomLeft.dy, card1.bottomRight.dy);
    });

    test('Card 1 right edge touches right screen edge on reference and left edge on mirror', () {
      const ref = LandingGeometry.card1Reference;
      expect(ref.bounds.right, closeTo(0.998, 0.001));

      final mirrored = LandingGeometry.getCard1(mirrored: true);
      expect(mirrored.bounds.left, closeTo(0.002, 0.001));
    });

    test('Rounded polygon path bounds lie strictly inside polygon bounds', () {
      const double width = 360.0;
      const double height = 800.0;
      const double d = 360.0; // min(360, 800/2.2)
      const double r = 0.058 * d;

      for (final mirrored in [false, true]) {
        for (final isCard1 in [true, false]) {
          final poly = isCard1
              ? LandingGeometry.getCard1(mirrored: mirrored)
              : LandingGeometry.getCard2(mirrored: mirrored);

          final absPoints = poly.toAbsolute(width, height);
          final path = LandingGeometry.roundPolygon(absPoints, r);
          final pathBounds = path.getBounds();
          final polyBounds = poly.absoluteBounds(width, height);

          // Path bounds must lie within polygon bounds (with floating point tolerance)
          expect(pathBounds.left, greaterThanOrEqualTo(polyBounds.left - 0.5));
          expect(pathBounds.top, greaterThanOrEqualTo(polyBounds.top - 0.5));
          expect(pathBounds.right, lessThanOrEqualTo(polyBounds.right + 0.5));
          expect(pathBounds.bottom, lessThanOrEqualTo(polyBounds.bottom + 0.5));
        }
      }
    });

    test('Blob A and Blob B translations match specifications', () {
      final blobA = LandingGeometry.blobAReference;
      const card1 = LandingGeometry.card1Reference;
      expect(blobA.topLeft.dx - card1.topLeft.dx, closeTo(0.015, 0.0001));
      expect(blobA.topLeft.dy - card1.topLeft.dy, closeTo(-0.045, 0.0001));

      final blobB = LandingGeometry.blobBReference;
      const card2 = LandingGeometry.card2Reference;
      expect(blobB.topLeft.dx - card2.topLeft.dx, closeTo(-0.06, 0.0001));
      expect(blobB.topLeft.dy - card2.topLeft.dy, closeTo(0.035, 0.0001));
    });
  });
}
