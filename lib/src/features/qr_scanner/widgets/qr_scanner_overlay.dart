import 'package:flutter/material.dart';

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        // Center cutout
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // Corner indicators
                Positioned(
                  top: 0,
                  left: 0,
                  child: _buildCornerIndicator(context, true, true),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildCornerIndicator(context, true, false),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _buildCornerIndicator(context, false, true),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildCornerIndicator(context, false, false),
                ),
              ],
            ),
          ),
        ),
        // Instructions text
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Position QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerIndicator(BuildContext context, bool isTop, bool isLeft) {
    final color = Theme.of(context).primaryColor;
    const size = 30.0;
    const thickness = 3.0;

    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CornerIndicatorPainter(
          color: color,
          thickness: thickness,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }
}

class CornerIndicatorPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isTop;
  final bool isLeft;

  CornerIndicatorPainter({
    required this.color,
    required this.thickness,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const lineLength = 20.0;

    if (isTop) {
      // Top horizontal line
      canvas.drawLine(
        Offset(isLeft ? 0 : size.width, 0),
        Offset(isLeft ? lineLength : size.width - lineLength, 0),
        paint,
      );
      // Top vertical line
      canvas.drawLine(
        Offset(isLeft ? 0 : size.width, 0),
        Offset(isLeft ? 0 : size.width, lineLength),
        paint,
      );
    } else {
      // Bottom horizontal line
      canvas.drawLine(
        Offset(isLeft ? 0 : size.width, size.height),
        Offset(isLeft ? lineLength : size.width - lineLength, size.height),
        paint,
      );
      // Bottom vertical line
      canvas.drawLine(
        Offset(isLeft ? 0 : size.width, size.height - lineLength),
        Offset(isLeft ? 0 : size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
