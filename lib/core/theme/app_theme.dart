import 'package:flutter/material.dart';

class AppTheme {
  // ── Core Palette ──────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Light surfaces
  static const Color surface0 = Color(0xFFFFFFFF);
  static const Color surface1 = Color(0xFFF2F2F7);
  static const Color surface2 = Color(0xFFE5E5EA);
  static const Color surface3 = Color(0xFFD1D1D6);

  // Dark surfaces
  static const Color dark0 = Color(0xFF000000);
  static const Color dark1 = Color(0xFF1C1C1E);
  static const Color dark2 = Color(0xFF2C2C2E);
  static const Color dark3 = Color(0xFF3A3A3C);
  static const Color dark4 = Color(0xFF48484A);

  // Text light
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFFAEAEB2);

  // Text dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF636366);

  // Accent
  static const Color accent = Color(0xFF1C1C1E);
  static const Color accentDark = Color(0xFFFFFFFF);

  // Status
  static const Color statusOpen = Color(0xFF3478F6);
  static const Color statusOpenBg = Color(0xFFEBF2FF);
  static const Color statusOpenBgDark = Color(0xFF0A2550);

  static const Color statusInProgress = Color(0xFFFF9500);
  static const Color statusInProgressBg = Color(0xFFFFF4E6);
  static const Color statusInProgressBgDark = Color(0xFF3D2400);

  static const Color statusResolved = Color(0xFF34C759);
  static const Color statusResolvedBg = Color(0xFFE8F9ED);
  static const Color statusResolvedBgDark = Color(0xFF0A3018);

  static const Color statusClosed = Color(0xFF8E8E93);
  static const Color statusClosedBg = Color(0xFFF2F2F7);
  static const Color statusClosedBgDark = Color(0xFF2C2C2E);

  // Priority
  static const Color priorityLow = Color(0xFF34C759);
  static const Color priorityMedium = Color(0xFFFF9500);
  static const Color priorityHigh = Color(0xFFFF3B30);
  static const Color priorityCritical = Color(0xFFFF2D55);

  // Semantic colors
  static const Color error = priorityHigh;
  static const Color warning = priorityMedium;
  static const Color success = priorityLow;
  static const Color textSecondaryLight = textSecondary;

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: surface1,
      colorScheme: const ColorScheme.light(
        primary: black,
        secondary: black,
        surface: surface0,
        error: priorityHigh,
        onPrimary: white,
        onSecondary: white,
        onSurface: textPrimary,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface0,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: black,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: surface3, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surface3, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surface3, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: priorityHigh, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: priorityHigh, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 15),
      ),
      dividerTheme: const DividerThemeData(
        color: surface2,
        thickness: 0.5,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface0,
        selectedItemColor: black,
        unselectedItemColor: textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark1,
        contentTextStyle: const TextStyle(color: white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: dark0,
      colorScheme: const ColorScheme.dark(
        primary: white,
        secondary: white,
        surface: dark1,
        error: priorityHigh,
        onPrimary: black,
        onSecondary: black,
        onSurface: textPrimaryDark,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: dark1,
        foregroundColor: textPrimaryDark,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF3A3A3C), width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: black,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: dark3, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dark3, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dark3, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: priorityHigh, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: priorityHigh, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
        hintStyle: const TextStyle(color: textTertiaryDark, fontSize: 15),
      ),
      dividerTheme: const DividerThemeData(
        color: dark3,
        thickness: 0.5,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: dark1,
        selectedItemColor: white,
        unselectedItemColor: textTertiaryDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark2,
        contentTextStyle: const TextStyle(color: white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: dark1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return statusOpen;
      case 'in_progress': case 'in-progress': return statusInProgress;
      case 'resolved': return statusResolved;
      case 'closed': return statusClosed;
      default: return statusClosed;
    }
  }

  static Color statusBgColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'open': return isDark ? statusOpenBgDark : statusOpenBg;
      case 'in_progress': case 'in-progress': return isDark ? statusInProgressBgDark : statusInProgressBg;
      case 'resolved': return isDark ? statusResolvedBgDark : statusResolvedBg;
      case 'closed': return isDark ? statusClosedBgDark : statusClosedBg;
      default: return isDark ? statusClosedBgDark : statusClosedBg;
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open': return 'Open';
      case 'in_progress': case 'in-progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      case 'closed': return 'Closed';
      default: return status;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return priorityLow;
      case 'medium': return priorityMedium;
      case 'high': return priorityHigh;
      case 'critical': return priorityCritical;
      default: return statusClosed;
    }
  }

  static Color priorityBgColor(String priority, {bool isDark = false}) {
    switch (priority.toLowerCase()) {
      case 'low': return isDark ? const Color(0xFF0A3018) : const Color(0xFFE8F9ED);
      case 'medium': return isDark ? const Color(0xFF3D2400) : const Color(0xFFFFF4E6);
      case 'high': return isDark ? const Color(0xFF3D0A0A) : const Color(0xFFFFEBEB);
      case 'critical': return isDark ? const Color(0xFF3D0A14) : const Color(0xFFFFEBEF);
      default: return isDark ? dark2 : surface2;
    }
  }

  static String priorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return 'Low';
      case 'medium': return 'Medium';
      case 'high': return 'High';
      case 'critical': return 'Critical';
      default: return priority;
    }
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppTheme.dark0 : AppTheme.surface1;
  Color get card => isDark ? AppTheme.dark1 : AppTheme.surface0;
  Color get border => isDark ? AppTheme.dark3 : AppTheme.surface2;
  Color get label => isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
  Color get sublabel => isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
}