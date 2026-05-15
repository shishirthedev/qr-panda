import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// The QR Panda brand icon — a stylized QR mark with a panda face
/// embedded in the top-left finder pattern. Matches the design spec.
class PandaQRIcon extends StatelessWidget {
  final double size;

  const PandaQRIcon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PandaQRPainter(),
      ),
    );
  }
}

class _PandaQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final unit = s / 7; // 7-module grid
    const moduleColor = Color(0xFFF0EFFE); // kText

    final squirclePaint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.fill;

    // Helper: draw a squircle module (rounded square, ~20% radius)
    void drawModule(double col, double row, [double span = 1.0]) {
      final r = unit * span * 0.2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(col * unit, row * unit, unit * span, unit * span),
        Radius.circular(r),
      );
      canvas.drawRRect(rect, squirclePaint);
    }

    // ── Finder pattern: top-right (cols 4-6, rows 0-2) ──────────
    _drawFinderPattern(canvas, squirclePaint, 4 * unit, 0, unit);

    // ── Finder pattern: bottom-left (cols 0-2, rows 4-6) ────────
    _drawFinderPattern(canvas, squirclePaint, 0, 4 * unit, unit);

    // ── Top-left finder: panda face ──────────────────────────────
    // Outer ring (ring only, not filled)
    final outerRingPaint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.28;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          unit * 0.14, unit * 0.14, unit * 2.72, unit * 2.72),
      Radius.circular(unit * 0.42),
    );
    canvas.drawRRect(outerRect, outerRingPaint);

    // Inner filled square (panda face area)
    final innerFacePaint = Paint()
      ..color = moduleColor
      ..style = PaintingStyle.fill;
    final innerFace = RRect.fromRectAndRadius(
      Rect.fromLTWH(unit * 0.72, unit * 0.72, unit * 1.56, unit * 1.56),
      Radius.circular(unit * 0.22),
    );
    canvas.drawRRect(innerFace, innerFacePaint);

    // Panda eyes (two dark dots inside the face)
    final eyePaint = Paint()
      ..color = kBg
      ..style = PaintingStyle.fill;
    final eyeR = unit * 0.22;
    canvas.drawCircle(Offset(unit * 1.15, unit * 1.22), eyeR, eyePaint);
    canvas.drawCircle(Offset(unit * 1.85, unit * 1.22), eyeR, eyePaint);

    // ── Data modules (bottom-right quadrant, decorative) ────────
    final dataPositions = [
      [3.5, 3.5], [4.5, 3.5], [5.5, 3.5],
      [3.5, 4.5], [5.5, 4.5],
      [3.5, 5.5], [4.5, 5.5], [5.5, 5.5],
      [4.0, 4.0],
      [6.0, 3.5], [6.0, 4.5],
      [3.5, 6.5], [5.0, 6.5],
    ];
    for (final pos in dataPositions) {
      drawModule(pos[0], pos[1], 0.75);
    }

    // A few data modules in mid area to fill it out
    final midData = [
      [3.5, 0.0], [4.5, 0.0], [6.0, 0.0],
      [3.5, 1.0], [6.0, 1.5],
      [3.5, 2.0], [5.0, 2.0],
      [0.0, 3.5], [1.5, 3.5],
      [0.0, 3.5], [2.5, 3.5],
    ];
    for (final pos in midData) {
      drawModule(pos[0], pos[1], 0.75);
    }
  }

  static void _drawFinderPattern(
      Canvas canvas, Paint paint, double x, double y, double unit) {
    // Outer border ring
    final outerPaint = Paint()
      ..color = const Color(0xFFF0EFFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + unit * 0.14, y + unit * 0.14,
            unit * 2.72, unit * 2.72),
        Radius.circular(unit * 0.42),
      ),
      outerPaint,
    );
    // Inner dot
    final innerPaint = Paint()
      ..color = const Color(0xFFF0EFFE)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x + unit * 0.72, y + unit * 0.72, unit * 1.56, unit * 1.56),
        Radius.circular(unit * 0.22),
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full app icon with the dark radial gradient background — as specified.
/// Use this as the brand mark in the home screen top bar.
class AppBrandIcon extends StatelessWidget {
  final double size;

  const AppBrandIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [Color(0xFF5A4ED9), Color(0xFF1B1A2E), kBg],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: size * 0.5,
            offset: Offset(0, size * 0.15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.12),
        child: PandaQRIcon(size: size * 0.76),
      ),
    );
  }
}
