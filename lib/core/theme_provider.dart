import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider()..loadThemeFromPreferences();
});

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'theme';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get currentTheme => _themeMode;

  void toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeToPreferences(mode);
  }

  Future<void> loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveThemeToPreferences(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}
