import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue.shade700,
    scaffoldBackgroundColor: Colors.grey.shade100,
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade700,
      secondary: Colors.green.shade600,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey.shade600),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade300,
      selectedColor: Colors.blue.shade700,
      secondarySelectedColor: Colors.blue.shade500,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      secondaryLabelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade700,
        side: BorderSide(color: Colors.blue.shade700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade200,
      prefixIconColor: Colors.blue.shade700,
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue.shade900,
    scaffoldBackgroundColor: Colors.grey.shade900,
    cardColor: Colors.grey.shade800,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue.shade900,
      secondary: Colors.green.shade700,
      surface: Colors.grey.shade800,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade300),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade300),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey.shade400),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade700,
      selectedColor: Colors.blue.shade900,
      secondarySelectedColor: Colors.blue.shade700,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      secondaryLabelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        animationDuration: Duration(milliseconds: 200),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade300,
        side: BorderSide(color: Colors.blue.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade700,
      prefixIconColor: Colors.blue.shade300,
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
