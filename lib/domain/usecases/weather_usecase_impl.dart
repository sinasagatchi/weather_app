import 'package:flutter_template/domain/entities/weather.dart';
import 'package:flutter_template/domain/repositories/weather_repository.dart';
import 'package:flutter_template/domain/usecases/weather_usecase.dart';

class WeatherUsecaseImpl extends WeatherUsecase {
  final WeatherRepository weatherRepository;

  WeatherUsecaseImpl(this.weatherRepository);
  @override
  Future<ForecastCurrent> getForecastCurrent(String query,
      {String? languageCode}) {
    return weatherRepository.getForecastCurrent(query,
        languageCode: languageCode);
  }

  @override
  Future<ForescastDay> getForecastDay(String query, {String? languageCode}) {
    return weatherRepository.getForecastDay(query, languageCode: languageCode);
  }

  @override
  Future<ForescastWeek> getForecastWeek(String query, {String? languageCode}) {
    return weatherRepository.getForecastWeek(query, languageCode: languageCode);
  }

  @override
  Future<List<Location>> searchLocation(String query) {
    return weatherRepository.searchLocation(query);
  }
}
