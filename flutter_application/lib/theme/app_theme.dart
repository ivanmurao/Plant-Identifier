import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color forestGreen   = Color(0xFF1E4D2B);  // primary deep green
  static const Color mossGreen     = Color(0xFF3A7D44);  // secondary / accents
  static const Color fernGreen     = Color(0xFF6BAF72);  // lighter interactive
  static const Color morningMist   = Color(0xFFF2F7F2);  // scaffold background
  static const Color parchment     = Color(0xFFFFFFFF);  // card / surface
  static const Color soilBrown     = Color(0xFF6B4C35);  // destructive / warn
  static const Color textDark      = Color(0xFF1A2415);  // primary text
  static const Color textMuted     = Color(0xFF6B7B69);  // secondary text
  static const Color divider       = Color(0xFFDDE8DD);  // subtle dividers

  // Confidence-score chip colours
  static const Color highConf      = Color(0xFF2D7A3A);
  static const Color midConf       = Color(0xFFF0A500);
  static const Color lowConf       = Color(0xFFD9534F);

  // ── Text Styles ──────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textDark,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textDark,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textDark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textMuted,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textMuted,
    letterSpacing: 0.8,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: morningMist,
      colorScheme: const ColorScheme.light(
        primary: forestGreen,
        secondary: mossGreen,
        tertiary: fernGreen,
        surface: parchment,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        outline: divider,
      ),
      cardTheme: CardThemeData(
        color: parchment,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: mossGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: parchment,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: forestGreen),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: morningMist,
        selectedColor: fernGreen.withOpacity(0.2),
        labelStyle: labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
