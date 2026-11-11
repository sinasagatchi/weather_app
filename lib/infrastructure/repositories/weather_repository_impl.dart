import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_template/infrastructure/mappers/weatherapi_mapper.dart';
import 'package:flutter_template/infrastructure/models/weatherapi/forecast_day_response.dart';
import 'package:flutter_template/infrastructure/models/weatherapi/search_response.dart';

import '../../config/env/env.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weatherapi/forecast_current_response.dart';

enum WeatherApiErrorKind {
  configuration,
  authentication,
  invalidLocation,
  network,
  unavailable,
}

class WeatherApiException implements Exception {
  const WeatherApiException(this.kind);

  final WeatherApiErrorKind kind;
}

class WeatherRepositoryImpl extends WeatherRepository {
  WeatherRepositoryImpl({
    required SharedPreferences preferences,
    Dio? dio,
  })  : _preferences = preferences,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.weatherapi.com/v1',
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;
  final SharedPreferences _preferences;

  Future<Response<dynamic>> _get(
    String path, {
    required Map<String, Object> parameters,
    String? languageCode,
  }) async {
    final apiKey = Environment.weatherapiKey;
    if (apiKey.isEmpty) {
      throw const WeatherApiException(WeatherApiErrorKind.configuration);
    }
    try {
      return await _dio.get(
        path,
        queryParameters: {
          ...parameters,
          if (languageCode != null) 'lang': languageCode,
          'key': apiKey,
        },
      );
    } on DioException catch (error) {
      throw _interpretError(error);
    }
  }

  WeatherApiException _interpretError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const WeatherApiException(WeatherApiErrorKind.authentication);
    }
    if (statusCode == 400 || statusCode == 404) {
      return const WeatherApiException(WeatherApiErrorKind.invalidLocation);
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const WeatherApiException(WeatherApiErrorKind.network);
    }
    return const WeatherApiException(WeatherApiErrorKind.unavailable);
  }

  T _parseResponse<T>(Object? data, T Function(Map<String, dynamic>) parse) {
    try {
      return parse(Map<String, dynamic>.from(data as Map));
    } on Object {
      throw const WeatherApiException(WeatherApiErrorKind.unavailable);
    }
  }

  ForecastCurrent _parseCurrent(Object? data) {
    final result = _parseResponse(
      data,
      (json) => WeatherapiMapper.weapiCurrentResponseToEntitie(
        WeatherapiCurrent.fromJson(json),
      ),
    );
    final location = result.location;
    final current = result.current;
    if (location.name.trim().isEmpty ||
        !location.lat.isFinite ||
        !location.lon.isFinite ||
        current.date.trim().isEmpty ||
        current.description.trim().isEmpty ||
        !current.tempC.isFinite ||
        !current.windKph.isFinite ||
        current.humidity < 0 ||
        current.humidity > 100 ||
        current.precipMm < 0) {
      throw const WeatherApiException(WeatherApiErrorKind.unavailable);
    }
    return result;
  }

  ForecastCurrent? _readCachedCurrent(String cacheKey) {
    try {
      final cached = _preferences.getString(cacheKey);
      if (cached == null) return null;
      final entry = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(entry['cachedAt'] as String? ?? '');
      if (cachedAt == null) return null;
      final result = _parseCurrent(entry['data']);
      return ForecastCurrent(
        location: result.location,
        current: result.current,
        isCached: true,
        cachedAt: cachedAt,
      );
    } on Object catch (error) {
      debugPrint('Ignoring unreadable weather cache (${error.runtimeType}).');
      return null;
    }
  }

  Future<void> _writeCurrentCache(
    String cacheKey,
    Object? responseData,
    DateTime cachedAt,
  ) async {
    try {
      final saved = await _preferences.setString(
        cacheKey,
        jsonEncode({
          'data': responseData,
          'cachedAt': cachedAt.toIso8601String(),
        }),
      );
      if (!saved) {
        debugPrint('Could not persist the latest weather cache.');
      }
    } on Object catch (error) {
      debugPrint(
          'Could not persist the latest weather cache (${error.runtimeType}).');
    }
  }

  @override
  Future<ForecastCurrent> getForecastCurrent(
    String query, {
    String? languageCode,
  }) async {
    final cacheKey =
        'weatherCache:${languageCode ?? 'en'}:${query.trim().toLowerCase()}';
    late final Response<dynamic> response;
    try {
      response = await _get(
        '/current.json',
        parameters: {'q': query},
        languageCode: languageCode,
      );
    } on WeatherApiException catch (error) {
      return _readCachedCurrent(cacheKey) ?? (throw error);
    }

    final result = _parseCurrent(response.data);
    await _writeCurrentCache(cacheKey, response.data, DateTime.now());
    return result;
  }

  @override
  Future<ForescastDay> getForecastDay(
    String query, {
    String? languageCode,
  }) async {
    final response = await _get(
      '/forecast.json',
      parameters: {
        'days': 1,
        'aqi': 'no',
        'alerts': 'no',
        'q': query,
      },
      languageCode: languageCode,
    );
    return _parseResponse(
      response.data,
      (json) => WeatherapiMapper.weapiDayToEntitie(
        WeatherapiDay.fromJson(json),
      ),
    );
  }

  @override
  Future<ForescastWeek> getForecastWeek(
    String query, {
    String? languageCode,
  }) async {
    final response = await _get(
      '/forecast.json',
      parameters: {
        'days': 7,
        'aqi': 'no',
        'alerts': 'no',
        'q': query,
      },
      languageCode: languageCode,
    );
    return _parseResponse(
      response.data,
      (json) => WeatherapiMapper.weapiWeekToEntitie(
        WeatherapiDay.fromJson(json),
      ),
    );
  }

  @override
  Future<List<Location>> searchLocation(String query) async {
    final response = await _get(
      '/search.json',
      parameters: {'q': query},
    );
    try {
      final dataList = response.data as List<dynamic>;
      return dataList.map((item) {
        final searchweatherapi = SearchWeatherapi.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        return WeatherapiMapper.weapiSearchToEntitie(searchweatherapi);
      }).toList();
    } on Object {
      throw const WeatherApiException(WeatherApiErrorKind.unavailable);
    }
  }
}
