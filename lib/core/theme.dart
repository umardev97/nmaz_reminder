import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFB98225);
  static const primaryDark = Color(0xFF8B5D16);
  static const secondary = Color(0xFF2F2A24);
  static const accent = Color(0xFFE8C879);
  static const background = Color(0xFFF8F6F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0ECE4);
  static const textPrimary = Color(0xFF1D1A17);
  static const textSecondary = Color(0xFF756E64);
  static const divider = Color(0xFFE8E2D9);
  static const success = Color(0xFF2E7D5B);
  static const error = Color(0xFFB94747);
  static const darkBackground = Color(0xFF12110F);
  static const darkSurface = Color(0xFF1D1B18);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double pill = 999;
}

TextTheme _textTheme(Brightness brightness) {
  final base = brightness == Brightness.light
      ? ThemeData.light().textTheme
      : ThemeData.dark().textTheme;
  return GoogleFonts.interTextTheme(base).copyWith(
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 34,
      height: 1.12,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      height: 1.15,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
    labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? AppColors.accent : AppColors.primary,
    onPrimary: isDark ? AppColors.textPrimary : Colors.white,
    secondary: AppColors.accent,
    onSecondary: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    surface: isDark ? AppColors.darkSurface : AppColors.surface,
    onSurface: isDark ? const Color(0xFFF5F1E8) : AppColors.textPrimary,
  );
  final outline = isDark ? Colors.white12 : AppColors.divider;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.darkBackground : AppColors.background,
    textTheme: _textTheme(brightness),
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: _textTheme(brightness).titleLarge?.copyWith(
            color: scheme.onSurface,
          ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: outline),
      ),
    ),
    dividerTheme: DividerThemeData(color: outline, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: .05) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      labelStyle:
          TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
      hintStyle:
          TextStyle(color: isDark ? Colors.white38 : AppColors.textSecondary),
      prefixIconColor: isDark ? Colors.white54 : AppColors.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 54),
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.primary.withValues(alpha: .45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: _textTheme(brightness).labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 54),
        side: BorderSide(color: outline),
        foregroundColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: _textTheme(brightness).labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: _textTheme(brightness).labelLarge,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: .14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : AppColors.textSecondary,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? scheme.primary : outline,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFFF2EDE3) : AppColors.secondary,
      contentTextStyle: TextStyle(
        color: isDark ? AppColors.textPrimary : Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

final ThemeData lightTheme = _buildTheme(Brightness.light);
final ThemeData darkTheme = _buildTheme(Brightness.dark);
