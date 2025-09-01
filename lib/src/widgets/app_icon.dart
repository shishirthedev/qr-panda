import 'package:flutter/material.dart';

/// A custom app icon widget based on the QR code container design from the home page.
/// This creates a consistent visual identity for the QuickQR app.
class AppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  const AppIcon({
    super.key,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.33), // Proportional padding
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.qr_code,
        size: size * 0.67, // Proportional icon size
        color: iconColor ?? Colors.white,
      ),
    );
  }
}

/// A gradient version of the app icon with the same blue gradient as the home page
class GradientAppIcon extends StatelessWidget {
  final double size;
  final Color? iconColor;
  final double borderRadius;

  const GradientAppIcon({
    super.key,
    this.size = 48,
    this.iconColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.33),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: size * 0.42, // Proportional shadow
            offset: Offset(0, size * 0.17), // Proportional offset
          ),
        ],
      ),
      child: Icon(
        Icons.qr_code,
        size: size * 0.67,
        color: iconColor ?? Colors.white,
      ),
    );
  }
}

/// A solid color version of the app icon for use in different contexts
class SolidAppIcon extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  const SolidAppIcon({
    super.key,
    this.size = 48,
    this.backgroundColor = const Color(0xFF3B82F6),
    this.iconColor = Colors.white,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.33),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.qr_code,
        size: size * 0.67,
        color: iconColor,
      ),
    );
  }
}
