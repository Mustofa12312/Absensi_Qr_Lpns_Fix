// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData _base(ThemeData base, {required bool isDark}) {
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF3F4F6),
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );
    return _base(base, isDark: false);
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorSchemeSeed: const Color(0xFF38BDF8),
      brightness: Brightness.dark,
    );
    return _base(base, isDark: true);
  }
}
