import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

class HeroBanner extends StatelessWidget {
  final double height;
  final Widget? overlayChild;

  const HeroBanner({
    super.key,
    this.height = 140,
    this.overlayChild,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.vr;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _VanMitraHillsPainter(
                brandSecondary: tokens.brandSecondary,
                actionPrimary: tokens.actionPrimary,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          if (overlayChild != null)
            Positioned.fill(
              child: overlayChild!,
            ),

        ],
      ),
    );
  }
}

class _VanMitraHillsPainter extends CustomPainter {
  final Color brandSecondary;
  final Color actionPrimary;

  _VanMitraHillsPainter({
    required this.brandSecondary,
    required this.actionPrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Background (light forest atmosphere)
    final skyPaint = Paint()..color = const Color(0xFF103622);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Rising Sun (actionPrimary @ 0.9)
    final sunPaint = Paint()..color = actionPrimary.withValues(alpha: 0.90);
    final sunCenter = Offset(size.width * 0.72, size.height * 0.32);
    canvas.drawCircle(sunCenter, 20, sunPaint);

    // 3. Layer 1: Far rolling hills (brandSecondary @ 0.35)
    final farPath = Path();
    farPath.moveTo(0, size.height * 0.65);
    farPath.quadraticBezierTo(size.width * 0.25, size.height * 0.42, size.width * 0.50, size.height * 0.58);
    farPath.quadraticBezierTo(size.width * 0.75, size.height * 0.72, size.width, size.height * 0.48);
    farPath.lineTo(size.width, size.height);
    farPath.lineTo(0, size.height);
    farPath.close();
    canvas.drawPath(farPath, Paint()..color = brandSecondary.withValues(alpha: 0.35));

    // 4. Layer 2: Mid rolling hills (brandSecondary @ 0.60)
    final midPath = Path();
    midPath.moveTo(0, size.height * 0.52);
    midPath.quadraticBezierTo(size.width * 0.30, size.height * 0.68, size.width * 0.65, size.height * 0.48);
    midPath.quadraticBezierTo(size.width * 0.85, size.height * 0.38, size.width, size.height * 0.58);
    midPath.lineTo(size.width, size.height);
    midPath.lineTo(0, size.height);
    midPath.close();
    canvas.drawPath(midPath, Paint()..color = brandSecondary.withValues(alpha: 0.60));

    // Small village hut on mid hill
    _drawHouse(canvas, Offset(size.width * 0.68, size.height * 0.44));

    // 5. Layer 3: Near rolling hills (brandSecondary @ 0.90)
    final nearPath = Path();
    nearPath.moveTo(0, size.height * 0.75);
    nearPath.quadraticBezierTo(size.width * 0.35, size.height * 0.58, size.width * 0.70, size.height * 0.78);
    nearPath.quadraticBezierTo(size.width * 0.85, size.height * 0.84, size.width, size.height * 0.68);
    nearPath.lineTo(size.width, size.height);
    nearPath.lineTo(0, size.height);
    nearPath.close();
    canvas.drawPath(nearPath, Paint()..color = brandSecondary.withValues(alpha: 0.90));
  }

  void _drawHouse(Canvas canvas, Offset pos) {
    // House roof
    final roofPath = Path();
    roofPath.moveTo(pos.dx, pos.dy);
    roofPath.lineTo(pos.dx - 9, pos.dy + 8);
    roofPath.lineTo(pos.dx + 9, pos.dy + 8);
    roofPath.close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFFC97B3C));

    // House wall
    final wallPaint = Paint()..color = const Color(0xFFEFE8DB);
    canvas.drawRect(Rect.fromLTWH(pos.dx - 7, pos.dy + 8, 14, 8), wallPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
