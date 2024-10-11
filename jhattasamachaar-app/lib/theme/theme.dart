import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.light(primary: Colors.blue.shade300,secondary: Colors.white),
  ),
  dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black87),
      contentTextStyle: TextStyle(color: Colors.black54)),
  listTileTheme: ListTileThemeData(
      iconColor: Colors.grey.shade700,
      textColor: Colors.grey.shade900,
      tileColor: Colors.white),
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
    primary: Colors.grey.shade300, // More visible primary color
    onPrimary: Colors.black87, // Text color on primary elements
    secondary: Colors.grey.shade300, // Slightly darker for better visibility
    onSecondary: Colors.grey.shade500, // Text color on secondary elements
    tertiary: Colors.black87, // General background color
  ),
);

ThemeData darkMode = ThemeData(
  
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.dark(primary: Colors.black54, secondary: Colors.grey.shade700),
  ),
  dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade700,
      titleTextStyle: const TextStyle(color: Colors.white70),
      contentTextStyle: const TextStyle(color: Colors.white54)),
  listTileTheme: const ListTileThemeData(
      iconColor: Colors.white60,
      tileColor: Colors.black38,
      textColor: Colors.white60),
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
    primary: Colors.black54,
    onPrimary: Colors.white70, // Text color on primary elements
    secondary: Colors.black54, // Lighter for better contrast
    onSecondary: Colors.white54, // Text color on secondary elements
    tertiary: Colors.white60,
  ),
);
