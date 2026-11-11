import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences must be initialized in main.'),
);

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.reduceMotion = false,
  });

  final ThemeMode themeMode;
  final String languageCode;
  final bool reduceMotion;

  Locale get locale => Locale(languageCode);

  AppPreferences copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? reduceMotion,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferences>(
  AppPreferencesNotifier.new,
);

class AppPreferencesNotifier extends Notifier<AppPreferences> {
  late SharedPreferences _preferences;

  @override
  AppPreferences build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    final themeName = _preferences.getString('themeMode');
    final languageCode = _preferences.getString('languageCode') ?? 'en';
    return AppPreferences(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      languageCode: languageCode == 'tr' ? 'tr' : 'en',
      reduceMotion: _preferences.getBool('reduceMotion') ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode), 'themeMode', mode.name);

  Future<void> setLanguage(String languageCode) => _update(
        state.copyWith(languageCode: languageCode),
        'languageCode',
        languageCode,
      );

  Future<void> setReduceMotion(bool value) =>
      _update(state.copyWith(reduceMotion: value), 'reduceMotion', value);

  Future<void> _update(
    AppPreferences next,
    String key,
    Object value,
  ) async {
    final previous = state;
    state = next;
    final saved = switch (value) {
      String stringValue => await _preferences.setString(key, stringValue),
      bool boolValue => await _preferences.setBool(key, boolValue),
      _ => false,
    };
    if (!saved) {
      state = previous;
      throw StateError('Could not save the "$key" preference.');
    }
  }
}
