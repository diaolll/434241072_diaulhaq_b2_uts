import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0891B2);

  // Alias untuk backward compatibility
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;
  static const Color infoColor = info;

  // Text colors
  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color textTertiaryColor = Color(0xFF9CA3AF);

  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceDarkColor = Color(0xFF1F2937);

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: textPrimaryColor,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
    scaffoldBackgroundColor: backgroundColor,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: surfaceDarkColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF374151),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
  );

  // Status colors
  static Color statusColor(String status) {
    switch (status) {
      case 'open': return info;
      case 'in_progress': return warning;
      case 'resolved': return success;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low': return success;
      case 'medium': return warning;
      case 'high': return error;
      case 'critical': return const Color(0xFF7F1D1D);
      default: return Colors.grey;
    }
  }
}
