import 'package:flutter/material.dart';
import '../repositories/repositories.dart';

class ThemeService {
  final LocalRepository _repository;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeService(this._repository);

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final isDark = await _repository.getModoOscuro();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _repository.setModoOscuro(_themeMode == ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.setModoOscuro(mode == ThemeMode.dark);
  }
}