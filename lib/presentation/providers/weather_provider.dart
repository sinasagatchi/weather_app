import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/weather.dart';
import 'app_preferences_provider.dart';
import 'weather_repository_provider.dart';

final forecastCurrentProvider =
    FutureProvider.family<ForecastCurrent, String>((ref, location) {
  final language = ref.watch(appPreferencesProvider).languageCode;
  return ref
      .watch(weatherRepositoryProvider)
      .getForecastCurrent(location, languageCode: language);
});

final forecastDayProvider = FutureProvider.family<ForescastDay, String>(
  (ref, location) {
    final language = ref.watch(appPreferencesProvider).languageCode;
    return ref
        .watch(weatherRepositoryProvider)
        .getForecastDay(location, languageCode: language);
  },
);

final forecastWeekProvider = FutureProvider.family<ForescastWeek, String>(
  (ref, location) {
    final language = ref.watch(appPreferencesProvider).languageCode;
    return ref
        .watch(weatherRepositoryProvider)
        .getForecastWeek(location, languageCode: language);
  },
);
