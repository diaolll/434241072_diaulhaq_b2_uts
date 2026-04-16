import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Premium Theme System for E-Ticketing Helpdesk
/// Aesthetic: Warm Professional - Clean, efficient, approachable
/// Design Philosophy: Linear meets Duolingo - Professional with character
class ModernTheme {
  // ==================== BRAND COLORS ====================
  /// Primary: Warm Coral - Energetic but approachable
  static const Color primary = Color(0xFFFF6B5B);
  static const Color primaryDark = Color(0xFFE55545);
  static const Color primaryLight = Color(0xFFFFB8B2);
  static const Color primaryPale = Color(0xFFFFE8E6);

  /// Secondary: Deep Ocean Blue - Trust and stability
  static const Color secondary = Color(0xFF2E5CFF);
  static const Color secondaryDark = Color(0xFF1A44DB);
  static const Color secondaryLight = Color(0xFF8BA8FF);

  /// Accent: Teal Fresh - Success and completion
  static const Color accent = Color(0xFF00C8B4);
  static const Color accentDark = Color(0xFF00A092);
  static const Color accentLight = Color(0xFF80E4DA);

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successDarkBg = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningDarkBg = Color(0xFF3E2E00);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color errorDarkBg = Color(0xFF450A0A);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoDarkBg = Color(0xFF1E3A5F);

  // ==================== NEUTRAL PALETTE (Stone) ====================
  /// Warmer than gray, more natural feeling
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone800 = Color(0xFF292524);
  static const Color stone900 = Color(0xFF1C1917);

  // ==================== SURFACE COLORS ====================
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAF9F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1917);
  static const Color surfaceDarkElevated = Color(0xFF292524);

  // ==================== GRADIENTS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [Color(0xFFFF6B5B), Color(0xFFFF8A7B)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [Color(0xFF2E5CFF), Color(0xFF4D79FF)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B5B), Color(0xFF2E5CFF), Color(0xFF00C8B4)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE8E6), Color(0xFFFAF9F7)],
  );

  // ==================== SHADOWS ====================
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: const Color(0xFF1C1917).withValues(alpha: 0.12),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ==================== TEXT THEMES ====================
  static TextTheme _buildTextTheme(bool isDark) {
    // Display font: Outfit - Modern, geometric, friendly
    final displayFont = GoogleFonts.outfit();
    // Body font: Plus Jakarta Sans - Clean, professional, highly legible
    final bodyFont = GoogleFonts.plusJakartaSans();

    final textColor = isDark ? stone50 : stone800;
    final textSecondary = isDark ? stone400 : stone500;

    return TextTheme(
      // Display - Outfit, bold and expressive
      displayLarge: displayFont.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: textColor,
        height: 1.1,
      ),
      displayMedium: displayFont.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textColor,
        height: 1.15,
      ),
      displaySmall: displayFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
        height: 1.2,
      ),

      // Headlines - Outfit
      headlineLarge: displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: displayFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
        height: 1.3,
      ),

      // Titles - Outfit
      titleLarge: displayFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textColor,
        height: 1.3,
      ),
      titleMedium: displayFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: textColor,
        height: 1.35,
      ),
      titleSmall: displayFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.4,
      ),

      // Body - Plus Jakarta Sans
      bodyLarge: bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: textSecondary,
        height: 1.6,
      ),
      bodyMedium: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textSecondary,
        height: 1.5,
      ),

      // Labels - Plus Jakarta Sans
      labelLarge: bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.3,
      ),
      labelMedium: bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.35,
      ),
      labelSmall: bodyFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textSecondary,
        height: 1.35,
      ),
    );
  }

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(false);

    return base.copyWith(
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: stone800,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: surfaceVariant,

      // Typography
      textTheme: textTheme,

      // AppBar - Clean with elevation
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: stone800,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: stone700, size: 24),
        actionsIconTheme: const IconThemeData(color: stone700, size: 24),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: stone400,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: stone400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // Card - Soft elevated
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: stone200.withValues(alpha: 0.6), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - Pill shape with gradient
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: stone700,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: stone300, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),

      // Input Decoration - Modern floating label
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: stone100.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: stone300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: stone600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: stone400,
          fontSize: 15,
        ),
        prefixIconColor: stone500,
        suffixIconColor: stone500,
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: stone100,
        selectedColor: primaryPale,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: stone700,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: stone200, width: 1),
      ),

      // Dialog - Modern rounded
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 24,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: stone800,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: stone600,
          height: 1.5,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: stone200,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: stone800,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 12,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: stone500,
        size: 24,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: stone200,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return stone300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.5);
          }
          return stone200;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: stone200,
        circularTrackColor: stone200,
      ),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(true);

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: secondaryLight,
        tertiary: accentLight,
        surface: surfaceDark,
        error: const Color(0xFFFECDD3),
        onPrimary: stone900,
        onSecondary: stone900,
        onSurface: stone50,
        onError: stone900,
      ),

      scaffoldBackgroundColor: surfaceDarkElevated,

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceDark.withValues(alpha: 0.9),
        foregroundColor: stone50,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: stone400, size: 24),
        actionsIconTheme: const IconThemeData(color: stone400, size: 24),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: stone500,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: stone500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDarkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: stone700.withValues(alpha: 0.5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: stone900,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: stone300,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: stone600, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF292524),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: stone700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFECDD3), width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: stone400,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: stone500,
          fontSize: 15,
        ),
        prefixIconColor: stone400,
        suffixIconColor: stone400,
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          color: primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: stone900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF292524),
        selectedColor: primary.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: stone300,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: stone700, width: 1),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDarkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 24,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: stone50,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: stone300,
          height: 1.5,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: stone700,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDarkElevated,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: stone50,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 12,
      ),

      iconTheme: const IconThemeData(
        color: stone400,
        size: 24,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: stone700,
        thumbColor: primaryLight,
        overlayColor: primaryLight.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight;
          return stone600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.3);
          }
          return stone700;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryLight,
        linearTrackColor: stone700,
        circularTrackColor: stone700,
      ),
    );
  }

  // ==================== HELPER FUNCTIONS ====================

  static Color getStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'open':
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case 'in_progress':
      case 'in-progress':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
      case 'resolved':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
      case 'closed':
        return stone400;
      default:
        return stone500;
    }
  }

  static Color getStatusBgColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'open':
        return isDark ? infoDarkBg : infoBg;
      case 'in_progress':
      case 'in-progress':
        return isDark ? warningDarkBg : warningBg;
      case 'resolved':
        return isDark ? successDarkBg : successBg;
      case 'closed':
        return isDark ? const Color(0xFF292524) : stone100;
      default:
        return stone200;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  static Color getPriorityColor(String priority, {bool isDark = false}) {
    switch (priority.toLowerCase()) {
      case 'low':
        return success;
      case 'medium':
        return warning;
      case 'high':
        return error;
      case 'critical':
        return const Color(0xFF991B1B);
      default:
        return stone500;
    }
  }

  static Color getPriorityBgColor(String priority, {bool isDark = false}) {
    switch (priority.toLowerCase()) {
      case 'low':
        return isDark ? successDarkBg : successBg;
      case 'medium':
        return isDark ? warningDarkBg : warningBg;
      case 'high':
        return isDark ? errorDarkBg : errorBg;
      case 'critical':
        return isDark ? const Color(0xFF450A0A) : const Color(0xFFFECDD3);
      default:
        return stone200;
    }
  }

  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return priority;
    }
  }
}

/// Extension for easy theme access
extension ModernThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
