import 'package:flutter_template/domain/entities/weather.dart';

abstract class WeatherUsecase {
  Future<ForecastCurrent> getForecastCurrent(String query,
      {String? languageCode});
  Future<ForescastDay> getForecastDay(String query, {String? languageCode});
  Future<ForescastWeek> getForecastWeek(String query, {String? languageCode});
  Future<List<Location>> searchLocation(String query);
}
