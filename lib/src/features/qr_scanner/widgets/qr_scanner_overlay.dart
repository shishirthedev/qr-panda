import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_theme.dart';

class QRScannerOverlay extends StatefulWidget {
  const QRScannerOverlay({super.key});

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scanLineController;
  late final AnimationController _bracketController;
  late final Animation<double> _scanLineAnim;
  late final Animation<double> _bracketOpacity;

  static const double _zoneSize = 260;
  static const double _cornerRadius = 24;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _bracketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _bracketOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _bracketController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _bracketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final zoneLeft = (size.width - _zoneSize) / 2;
    final zoneTop = (size.height - _zoneSize) / 2;

    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: Size(size.width, size.height),
          painter: _OverlayPainter(
            zoneRect: Rect.fromLTWH(zoneLeft, zoneTop, _zoneSize, _zoneSize),
            cornerRadius: _cornerRadius,
          ),
        ),

        // Brackets at corners
        AnimatedBuilder(
          animation: _bracketOpacity,
          builder: (context, _) => Opacity(
            opacity: _bracketOpacity.value,
            child: Stack(
              children: [
                Positioned(
                  top: zoneTop,
                  left: zoneLeft,
                  child: const _Bracket(position: _BracketPosition.topLeft),
                ),
                Positioned(
                  top: zoneTop,
                  left: zoneLeft + _zoneSize - 28,
                  child: const _Bracket(position: _BracketPosition.topRight),
                ),
                Positioned(
                  top: zoneTop + _zoneSize - 28,
                  left: zoneLeft,
                  child: const _Bracket(position: _BracketPosition.bottomLeft),
                ),
                Positioned(
                  top: zoneTop + _zoneSize - 28,
                  left: zoneLeft + _zoneSize - 28,
                  child: const _Bracket(position: _BracketPosition.bottomRight),
                ),
              ],
            ),
          ),
        ),

        // Animated scan line
        AnimatedBuilder(
          animation: _scanLineAnim,
          builder: (context, _) {
            final lineY = zoneTop + _scanLineAnim.value * _zoneSize;
            return Positioned(
              top: lineY.clamp(zoneTop, zoneTop + _zoneSize - 2),
              left: zoneLeft + 8,
              right: size.width - zoneLeft - _zoneSize + 8,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, kPrimary, Colors.transparent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Hint text below the scan zone
        Positioned(
          top: zoneTop + _zoneSize + 20,
          left: 0,
          right: 0,
          child: Text(
            'Align QR code within the frame',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect zoneRect;
  final double cornerRadius;

  _OverlayPainter({required this.zoneRect, required this.cornerRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        zoneRect,
        Radius.circular(cornerRadius),
      ));

    final combined = Path.combine(PathOperation.difference, outerPath, cutoutPath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.zoneRect != zoneRect;
}

enum _BracketPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Bracket extends StatelessWidget {
  final _BracketPosition position;
  static const double _size = 28;
  static const double _borderWidth = 3;
  static const double _innerRadius = 24;

  const _Bracket({required this.position});

  @override
  Widget build(BuildContext context) {
    BorderRadius radius;
    switch (position) {
      case _BracketPosition.topLeft:
        radius = const BorderRadius.only(topLeft: Radius.circular(_innerRadius));
        break;
      case _BracketPosition.topRight:
        radius = const BorderRadius.only(topRight: Radius.circular(_innerRadius));
        break;
      case _BracketPosition.bottomLeft:
        radius = const BorderRadius.only(bottomLeft: Radius.circular(_innerRadius));
        break;
      case _BracketPosition.bottomRight:
        radius = const BorderRadius.only(bottomRight: Radius.circular(_innerRadius));
        break;
    }

    final showTop =
        position == _BracketPosition.topLeft || position == _BracketPosition.topRight;
    final showLeft =
        position == _BracketPosition.topLeft || position == _BracketPosition.bottomLeft;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border(
          top: showTop
              ? const BorderSide(color: kPrimary, width: _borderWidth)
              : BorderSide.none,
          bottom: !showTop
              ? const BorderSide(color: kPrimary, width: _borderWidth)
              : BorderSide.none,
          left: showLeft
              ? const BorderSide(color: kPrimary, width: _borderWidth)
              : BorderSide.none,
          right: !showLeft
              ? const BorderSide(color: kPrimary, width: _borderWidth)
              : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.7),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
