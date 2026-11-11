import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_template/domain/entities/weather.dart';
import 'package:flutter_template/presentation/providers/app_preferences_provider.dart';
import 'package:flutter_template/presentation/providers/favorite_locations_provider.dart';

void main() {
  const city = Location(
    name: 'Istanbul',
    region: 'Istanbul',
    country: 'Türkiye',
    lat: 41.0082,
    lon: 28.9784,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('favorites prevent duplicates, remove, and restore from storage',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(favoriteLocationsProvider.notifier);
    expect(await notifier.add(city), isTrue);
    expect(
      await notifier.add(
        const Location(
          name: 'Istanbul duplicate',
          region: 'Istanbul',
          country: 'Türkiye',
          lat: 41.0082,
          lon: 28.9784,
        ),
      ),
      isFalse,
    );
    expect(container.read(favoriteLocationsProvider), hasLength(1));

    final restored = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    expect(restored.read(favoriteLocationsProvider).single.name, 'Istanbul');
    restored.dispose();

    await notifier.remove(city);
    expect(container.read(favoriteLocationsProvider), isEmpty);
    final afterRemoval = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(afterRemoval.dispose);
    expect(afterRemoval.read(favoriteLocationsProvider), isEmpty);
  });
}
