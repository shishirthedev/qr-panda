import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ──────────────────────────────────────────────────────────────────
const kBg = Color(0xFF0F0F14);
const kSurface = Color(0xFF1A1A24);
const kSurface2 = Color(0xFF22222F);
const kBorder = Color(0xFF2E2E40);

const kPrimary = Color(0xFF7C6EF0);
const kPrimaryLight = Color(0xFF9D93F5);
const kPrimaryDark = Color(0xFF5A4ED9);
const kPrimaryGlow = Color(0x337C6EF0);

const kAmber = Color(0xFFF5A623);
const kGreen = Color(0xFF34D399);
const kRose = Color(0xFFF472B6);

const kText = Color(0xFFF0EFFE);
const kText2 = Color(0xFF8E8BA8);
const kTextMuted = Color(0xFF4F4D66);

// QR type badge colors
const kTypeUrl = Color(0xFF6366F1);
const kTypePhone = Color(0xFFF59E0B);
const kTypeWifi = Color(0xFF06B6D4);
const kTypeContact = Color(0xFF10B981);
const kTypeText = Color(0xFF8B5CF6);

class AppTheme {
  // Color constants
  static const Color bg = kBg;
  static const Color surface = kSurface;
  static const Color surface2 = kSurface2;
  static const Color border = kBorder;

  static const Color primary = kPrimary;
  static const Color primaryLight = kPrimaryLight;
  static const Color primaryDark = kPrimaryDark;
  static const Color primaryGlow = kPrimaryGlow;

  static const Color amber = kAmber;
  static const Color green = kGreen;
  static const Color rose = kRose;

  static const Color text = kText;
  static const Color text2 = kText2;
  static const Color textMuted = kTextMuted;

  static const Color typeUrl = kTypeUrl;
  static const Color typePhone = kTypePhone;
  static const Color typeWifi = kTypeWifi;
  static const Color typeContact = kTypeContact;
  static const Color typeText = kTypeText;

  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return kTypeUrl;
      case 'phone':
        return kTypePhone;
      case 'wifi':
        return kTypeWifi;
      case 'contact':
        return kTypeContact;
      default:
        return kTypeText;
    }
  }

  static ThemeData get darkTheme {
    final base = ThemeData(brightness: Brightness.dark);
    return base.copyWith(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(
        surface: kSurface,
        primary: kPrimary,
        secondary: kPrimaryLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: kText,
        error: kRose,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: kText,
        displayColor: kText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: kText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: kText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kSurface2,
        contentTextStyle: GoogleFonts.inter(color: kText, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: kBorder,
      iconTheme: const IconThemeData(color: kText2),
    );
  }
}
