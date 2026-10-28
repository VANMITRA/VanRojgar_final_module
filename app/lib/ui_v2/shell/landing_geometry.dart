import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Represents a quadrilateral polygon in normalized (u, v) coordinates.
class LandingPolygon {
  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  const LandingPolygon({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  List<Offset> get points => [topLeft, topRight, bottomRight, bottomLeft];

  /// Horizontally mirrors the polygon: u becomes 1.0 - u.
  LandingPolygon mirrored() {
    return LandingPolygon(
      topLeft: Offset(1.0 - topRight.dx, topRight.dy),
      topRight: Offset(1.0 - topLeft.dx, topLeft.dy),
      bottomRight: Offset(1.0 - bottomLeft.dx, bottomLeft.dy),
      bottomLeft: Offset(1.0 - bottomRight.dx, bottomRight.dy),
    );
  }

  /// Translates polygon by (du, dv) in normalized units.
  LandingPolygon translate(double du, double dv) {
    return LandingPolygon(
      topLeft: topLeft + Offset(du, dv),
      topRight: topRight + Offset(du, dv),
      bottomRight: bottomRight + Offset(du, dv),
      bottomLeft: bottomLeft + Offset(du, dv),
    );
  }

  /// Scales normalized points to absolute pixel coordinates for given screen size.
  List<Offset> toAbsolute(double width, double height) {
    return [
      Offset(topLeft.dx * width, topLeft.dy * height),
      Offset(topRight.dx * width, topRight.dy * height),
      Offset(bottomRight.dx * width, bottomRight.dy * height),
      Offset(bottomLeft.dx * width, bottomLeft.dy * height),
    ];
  }

  /// Gets normalized bounding Rect.
  Rect get bounds {
    final xs = [topLeft.dx, topRight.dx, bottomRight.dx, bottomLeft.dx];
    final ys = [topLeft.dy, topRight.dy, bottomRight.dy, bottomLeft.dy];
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Gets absolute bounding Rect on a screen of (width, height).
  Rect absoluteBounds(double width, double height) {
    final b = bounds;
    return Rect.fromLTRB(
      b.left * width,
      b.top * height,
      b.right * width,
      b.bottom * height,
    );
  }
}

/// Normalized reference geometry constants for slide 2 (pictures on the RIGHT).
class LandingGeometry {
  LandingGeometry._();

  // Card 1 (top picture) reference points
  static const LandingPolygon card1Reference = LandingPolygon(
    topLeft: Offset(0.436, 0.159),
    topRight: Offset(0.969, 0.193),
    bottomRight: Offset(0.998, 0.486),
    bottomLeft: Offset(0.512, 0.526),
  );

  // Card 2 (bottom picture) reference points
  static const LandingPolygon card2Reference = LandingPolygon(
    topLeft: Offset(0.488, 0.568),
    topRight: Offset(0.990, 0.493),
    bottomRight: Offset(0.988, 0.828),
    bottomLeft: Offset(0.565, 0.855),
  );

  // Blob A reference: Card 1 moved by (+0.015 W, -0.045 H)
  static final LandingPolygon blobAReference = card1Reference.translate(0.015, -0.045);

  // Blob B reference: Card 2 moved by (-0.06 W, +0.035 H)
  static final LandingPolygon blobBReference = card2Reference.translate(-0.06, 0.035);

  /// Returns Card 1 polygon, taking into account mirroring.
  static LandingPolygon getCard1({required bool mirrored}) {
    return mirrored ? card1Reference.mirrored() : card1Reference;
  }

  /// Returns Card 2 polygon, taking into account mirroring.
  static LandingPolygon getCard2({required bool mirrored}) {
    return mirrored ? card2Reference.mirrored() : card2Reference;
  }

  /// Returns Blob A polygon, taking into account mirroring.
  static LandingPolygon getBlobA({required bool mirrored}) {
    return mirrored ? blobAReference.mirrored() : blobAReference;
  }

  /// Returns Blob B polygon, taking into account mirroring.
  static LandingPolygon getBlobB({required bool mirrored}) {
    return mirrored ? blobBReference.mirrored() : blobBReference;
  }

  /// Converts a quadrilateral list of 4 absolute points into a smooth rounded Path.
  ///
  /// For each corner, moves along both edges by radius [r], then uses [quadraticBezierTo]
  /// with the corner point as the control point.
  static Path roundPolygon(List<Offset> points, double r) {
    if (points.length != 4) return Path();

    final Path path = Path();
    final int n = points.length;

    // Compute entry and exit points for each corner
    final List<Offset> entryPoints = List.filled(n, Offset.zero);
    final List<Offset> exitPoints = List.filled(n, Offset.zero);

    for (int i = 0; i < n; i++) {
      final pPrev = points[(i - 1 + n) % n];
      final pCurr = points[i];
      final pNext = points[(i + 1) % n];

      final vPrev = pPrev - pCurr;
      final vNext = pNext - pCurr;

      final lenPrev = vPrev.distance;
      final lenNext = vNext.distance;

      if (lenPrev < 1e-4 || lenNext < 1e-4) {
        entryPoints[i] = pCurr;
        exitPoints[i] = pCurr;
        continue;
      }

      // Clamp radius so it doesn't exceed half the shortest adjacent edge
      final maxR = math.min(lenPrev, lenNext) * 0.45;
      final actualR = math.min(r, maxR);

      final uPrev = vPrev / lenPrev;
      final uNext = vNext / lenNext;

      entryPoints[i] = pCurr + uPrev * actualR;
      exitPoints[i] = pCurr + uNext * actualR;
    }

    // Draw the rounded polygon path
    path.moveTo(exitPoints[0].dx, exitPoints[0].dy);

    for (int i = 0; i < n; i++) {
      final nextIdx = (i + 1) % n;
      // Line to next corner's entry point
      path.lineTo(entryPoints[nextIdx].dx, entryPoints[nextIdx].dy);
      // Curve around next corner to its exit point
      path.quadraticBezierTo(
        points[nextIdx].dx,
        points[nextIdx].dy,
        exitPoints[nextIdx].dx,
        exitPoints[nextIdx].dy,
      );
    }

    path.close();
    return path;
  }
}
