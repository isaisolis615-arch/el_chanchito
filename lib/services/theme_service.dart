import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';

class ThemeService extends StateNotifier<ThemeMode> {
  final LocalRepository _repository;

  ThemeService(this._repository) : super(ThemeMode.light);

  Future<void> initialize() async {
    try {
      final isDark = await _repository.getModoOscuro();
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    await _repository.setModoOscuro(newMode == ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repository.setModoOscuro(mode == ThemeMode.dark);
  }
}