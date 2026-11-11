import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/weather.dart';
import 'app_preferences_provider.dart';
import 'weather_repository_provider.dart';

final favoriteLocationsProvider =
    NotifierProvider<FavoriteLocationsNotifier, List<Location>>(
  FavoriteLocationsNotifier.new,
);

class FavoriteLocationsNotifier extends Notifier<List<Location>> {
  late SharedPreferences _preferences;

  @override
  List<Location> build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    final stored = _preferences.getString('favoriteLocations');
    if (stored == null) return const [];
    final decoded = jsonDecode(stored) as List<dynamic>;
    return decoded
        .map((item) => Location.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<bool> add(Location location) async {
    if (state.any((saved) => saved.stableId == location.stableId)) {
      return false;
    }
    await _save([...state, location]);
    return true;
  }

  Future<void> remove(Location location) async {
    await _save(
      state.where((saved) => saved.stableId != location.stableId).toList(),
    );
  }

  Future<void> _save(List<Location> next) async {
    final previous = state;
    state = List.unmodifiable(next);
    try {
      final saved = await _preferences.setString(
        'favoriteLocations',
        jsonEncode(next.map((location) => location.toJson()).toList()),
      );
      if (!saved) throw StateError('Could not save favorite cities.');
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

class FavoriteWeatherResult {
  const FavoriteWeatherResult.success(this.forecast) : error = null;
  const FavoriteWeatherResult.failure(this.error) : forecast = null;

  final ForecastCurrent? forecast;
  final Object? error;
}

final favoriteWeatherProvider =
    FutureProvider.family<FavoriteWeatherResult, Location>(
        (ref, location) async {
  final language = ref.watch(appPreferencesProvider).languageCode;
  try {
    final forecast =
        await ref.watch(weatherRepositoryProvider).getForecastCurrent(
              '${location.lat},${location.lon}',
              languageCode: language,
            );
    return FavoriteWeatherResult.success(forecast);
  } on Exception catch (error) {
    return FavoriteWeatherResult.failure(error);
  }
});
