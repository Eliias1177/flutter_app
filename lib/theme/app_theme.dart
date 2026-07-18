import 'package:flutter/material.dart';

class AppTheme {
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentYellow = Color(0xFFFFC107);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        primaryColor: accentBlue,
        colorScheme: const ColorScheme.dark(
          primary: accentBlue,
          secondary: accentYellow,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey.shade500),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2A2F37)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: accentBlue, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        primaryColor: accentBlue,
        colorScheme: const ColorScheme.light(
          primary: accentBlue,
          secondary: accentYellow,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}