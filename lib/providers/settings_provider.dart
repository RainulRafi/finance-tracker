import 'package:flutter/material.dart';

import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  String? _userName;
  bool _budgetAlertsEnabled = true;

  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = false;

  String? get userName => _userName;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _userName = await _repository.getValue('userName');

    final alerts = await _repository.getValue('budgetAlerts');
    _budgetAlertsEnabled = alerts != 'false';

    _themeMode = _parseThemeMode(await _repository.getValue('themeMode'));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _repository.setValue('userName', name);
    _userName = name;
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    _budgetAlertsEnabled = enabled;
    notifyListeners();
    await _repository.setValue('budgetAlerts', enabled.toString());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _repository.setValue('themeMode', mode.name);
  }
}
