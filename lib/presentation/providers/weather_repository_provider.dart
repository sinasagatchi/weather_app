import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/repositories/weather_repository_impl.dart';
import 'app_preferences_provider.dart';

final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  return WeatherRepositoryImpl(
    preferences: ref.watch(sharedPreferencesProvider),
  );
});
