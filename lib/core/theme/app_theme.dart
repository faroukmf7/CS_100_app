// lib/core/theme/app_theme.dart
// ─────────────────────────────────────────
// Material 3 theme with custom color scheme.
// Supports light + dark mode out of the box.
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Palette ─────────────────────────────────────────────────────────
  static const Color kPrimary       = Color(0xFF2563EB); // Vivid blue
  static const Color kPrimaryLight  = Color(0xFF3B82F6);
  static const Color kSecondary     = Color(0xFF10B981); // Emerald green
  static const Color kAccent        = Color(0xFFF59E0B); // Amber
  static const Color kError         = Color(0xFFEF4444); // Red
  static const Color kWarning       = Color(0xFFF97316); // Orange
  static const Color kSuccess       = Color(0xFF10B981);

  // Light
  static const Color kBgLight       = Color(0xFFF8FAFC);
  static const Color kSurfaceLight  = Color(0xFFFFFFFF);
  static const Color kCardLight     = Color(0xFFFFFFFF);
  static const Color kTextPrimary   = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);
  static const Color kDivider       = Color(0xFFE2E8F0);

  // Dark
  static const Color kBgDark        = Color(0xFF0F172A);
  static const Color kSurfaceDark   = Color(0xFF1E293B);
  static const Color kCardDark      = Color(0xFF1E293B);
  static const Color kTextDarkPrimary   = Color(0xFFF1F5F9);
  static const Color kTextDarkSecondary = Color(0xFF94A3B8);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.light,
        primary: kPrimary,
        secondary: kSecondary,
        error: kError,
        surface: kSurfaceLight,
      ),
      scaffoldBackgroundColor: kBgLight,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgLight,
        foregroundColor: kTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: kCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kDivider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kTextSecondary, fontFamily: 'Nunito'),
        hintStyle: const TextStyle(color: kTextSecondary, fontFamily: 'Nunito'),
      ),
      textTheme: _buildTextTheme(kTextPrimary, kTextSecondary),
      dividerTheme: const DividerThemeData(color: kDivider, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: kDivider,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    return base;
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.dark,
        primary: kPrimaryLight,
        secondary: kSecondary,
        error: kError,
        surface: kSurfaceDark,
      ),
      scaffoldBackgroundColor: kBgDark,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDark,
        foregroundColor: kTextDarkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: kCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kTextDarkSecondary, fontFamily: 'Nunito'),
        hintStyle: const TextStyle(color: kTextDarkSecondary, fontFamily: 'Nunito'),
      ),
      textTheme: _buildTextTheme(kTextDarkPrimary, kTextDarkSecondary),
      dividerTheme: const DividerThemeData(color: Color(0xFF334155), thickness: 1),
    );
    return base;
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w800, color: primary, fontFamily: 'Nunito'),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w800, color: primary, fontFamily: 'Nunito'),
      displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Nunito'),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Nunito'),
      headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Nunito'),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Nunito'),
      titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary, fontFamily: 'Nunito'),
      titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Nunito'),
      titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Nunito'),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary, fontFamily: 'Nunito'),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary, fontFamily: 'Nunito'),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, fontFamily: 'Nunito'),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, fontFamily: 'Nunito'),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary, fontFamily: 'Nunito'),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary, fontFamily: 'Nunito'),
    );
  }
}
