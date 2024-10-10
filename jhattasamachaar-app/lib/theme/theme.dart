import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.blue.shade700,
      backgroundColor: const Color(0xFF2c69d1)),
  appBarTheme: const AppBarTheme(
      foregroundColor: Colors.blue,
      backgroundColor: Colors.deepPurple,
      titleTextStyle: TextStyle(color: Colors.white)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade100,
    selectedIconTheme: const IconThemeData(color: Colors.white, size: 33),
    selectedItemColor: Colors.blue.shade700,
    unselectedIconTheme: IconThemeData(color: Colors.grey.shade700, size: 27),
  ),
  scaffoldBackgroundColor: Colors.grey.shade100,
  brightness: Brightness.light,
  cardColor: Colors.white,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.blue.shade700, // More visible primary color
    onPrimary: Colors.white, // Text color on primary elements
    secondary: Colors.grey.shade300, // Slightly darker for better visibility
    onSecondary: Colors.white, // Text color on secondary elements
    tertiary: Colors.black87, // General background color
  ),
);

ThemeData darkMode = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey.shade500,
    foregroundColor: Colors.grey.shade600,
  ),
  appBarTheme: const AppBarTheme(
      foregroundColor: Colors.black87,
      backgroundColor: Colors.black54,
      titleTextStyle: TextStyle(color: Colors.white)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade800,
    selectedIconTheme: const IconThemeData(color: Colors.white, size: 33),
    selectedItemColor: Colors.black,
    unselectedIconTheme: const IconThemeData(color: Colors.white54, size: 27),
  ),
  scaffoldBackgroundColor: Colors.grey.shade800,
  cardColor: Colors.black54,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800,
    primary: Colors.white,
    onPrimary: Colors.white, // Text color on primary elements
    secondary: Colors.black54, // Lighter for better contrast
    onSecondary: Colors.white, // Text color on secondary elements
    tertiary: Colors.white70,
  ),
);
