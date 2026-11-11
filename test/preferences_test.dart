import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_template/presentation/providers/app_preferences_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('theme, language, and motion preferences persist', () async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(appPreferencesProvider.notifier);
    await notifier.setThemeMode(ThemeMode.dark);
    await notifier.setLanguage('tr');
    await notifier.setReduceMotion(true);

    expect(container.read(appPreferencesProvider).themeMode, ThemeMode.dark);
    expect(container.read(appPreferencesProvider).languageCode, 'tr');
    expect(container.read(appPreferencesProvider).reduceMotion, isTrue);

    final restored = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(restored.dispose);
    expect(restored.read(appPreferencesProvider).themeMode, ThemeMode.dark);
    expect(restored.read(appPreferencesProvider).languageCode, 'tr');
    expect(restored.read(appPreferencesProvider).reduceMotion, isTrue);
  });
}
