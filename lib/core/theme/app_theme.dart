import 'package:flutter/material.dart';

class AppTheme {
  // Modern aesthetic color palette
  static const Color primaryColor = Color(0xFF667EEA); // Vibrant blue-purple
  static const Color secondaryColor = Color(0xFF764BA2); // Deep purple
  static const Color tertiaryColor = Color(0xFFF093FB); // Soft pink
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4ECDC4);
  static const Color warningColor = Color(0xFFFFE66D);
  static const Color surfaceColor = Color(0xFFFAFBFF);
  static const Color onSurfaceColor = Color(0xFF1A1C20);
  
  // Map specific colors
  static const Color pinDefault = Color(0xFF667EEA);
  static const Color pinSponsored = Color(0xFFFF8A65);
  static const Color pinNature = Color(0xFF66BB6A);
  static const Color pinFood = Color(0xFFFF7043);
  static const Color pinLandmark = Color(0xFF42A5F5);
  static const Color pinAdventure = Color(0xFFAB47BC);
  static const Color pinUser = Color(0xFF26C6DA);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD0BCFF),
        secondary: Color(0xFFCCC2DC),
        tertiary: Color(0xFFEFB8C8),
        error: Color(0xFFFFB4AB),
        surface: Color(0xFF141218),
        onSurface: Color(0xFFE6E0E9),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Color(0xFF141218),
        foregroundColor: Color(0xFFE6E0E9),
      ),
    );
  }
}
