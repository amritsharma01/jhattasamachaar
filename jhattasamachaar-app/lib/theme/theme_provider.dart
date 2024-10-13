import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jhattasamachaar/theme/theme.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    String? storedTheme = await secureStorage.read(key: "theme");
    if (storedTheme == "dark") {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeData == lightMode) {
      themeData = darkMode;
      await secureStorage.write(key: "theme", value: "dark");
    } else {
      themeData = lightMode;
      await secureStorage.write(key: "theme", value: "light");
    }
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

}
