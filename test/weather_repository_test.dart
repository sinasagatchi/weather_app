import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:flutter_template/infrastructure/repositories/weather_repository_impl.dart';

class _ResponseAdapter implements HttpClientAdapter {
  _ResponseAdapter(this.statusCode, this.data);

  final int statusCode;
  final Object? data;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      data is String ? data! as String : jsonEncode(data),
      statusCode,
      headers: const {
        'content-type': ['application/json']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FailedWriteStore extends InMemorySharedPreferencesStore {
  _FailedWriteStore.empty() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

Map<String, Object> _currentResponse() => {
      'location': {
        'name': 'London',
        'region': 'City of London',
        'country': 'United Kingdom',
        'lat': 51.5072,
        'lon': -0.1276,
        'tz_id': 'Europe/London',
        'localtime_epoch': 1794400000,
        'localtime': '2026-11-11 13:00',
      },
      'current': {
        'last_updated_epoch': 1794400000,
        'last_updated': '2026-11-11 13:00',
        'temp_c': 21.5,
        'temp_f': 70.7,
        'is_day': 1,
        'condition': {
          'text': 'Sunny',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
          'code': 1000,
        },
        'wind_mph': 5.0,
        'wind_kph': 8.0,
        'wind_degree': 0,
        'wind_dir': 'N',
        'pressure_mb': 1013.0,
        'pressure_in': 29.9,
        'precip_mm': 0.0,
        'precip_in': 0.0,
        'humidity': 50,
        'cloud': 10,
        'feelslike_c': 21.0,
        'feelslike_f': 69.8,
        'vis_km': 10.0,
        'vis_miles': 6.2,
        'uv': 3.0,
        'gust_mph': 7.0,
        'gust_kph': 11.0,
      },
    };

Future<WeatherRepositoryImpl> _repository({
  required int statusCode,
  Object? data,
  Map<String, Object> initialValues = const {},
  bool failWrites = false,
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  if (failWrites) {
    SharedPreferencesStorePlatform.instance = _FailedWriteStore.empty();
  }
  dotenv.loadFromString(envString: 'weatherapiKey=test-key');
  final dio = Dio(BaseOptions(baseUrl: 'https://api.weatherapi.com/v1'))
    ..httpClientAdapter = _ResponseAdapter(statusCode, data);
  return WeatherRepositoryImpl(preferences: preferences, dio: dio);
}

void main() {
  tearDown(dotenv.clean);

  test('returns fresh current weather when cache persistence fails', () async {
    final staleData = _currentResponse();
    final staleCurrent = Map<String, Object>.from(staleData['current'] as Map);
    staleCurrent['temp_c'] = 2.0;
    staleData['current'] = staleCurrent;
    final repository = await _repository(
      statusCode: 200,
      data: _currentResponse(),
      failWrites: true,
      initialValues: {
        'weatherCache:en:london': jsonEncode({
          'data': staleData,
          'cachedAt': DateTime.utc(2026, 11, 10).toIso8601String(),
        }),
      },
    );

    final result = await repository.getForecastCurrent('London');

    expect(result.current.tempC, 21.5);
    expect(result.isCached, isFalse);
    expect(result.cachedAt, isNull);
  });

  test('uses valid cached current weather after a server error', () async {
    final cachedAt = DateTime.utc(2026, 11, 11, 12);
    final repository = await _repository(
      statusCode: 503,
      data: {'error': 'unavailable'},
      initialValues: {
        'weatherCache:en:london': jsonEncode({
          'data': _currentResponse(),
          'cachedAt': cachedAt.toIso8601String(),
        }),
      },
    );

    final result = await repository.getForecastCurrent('London');

    expect(result.current.tempC, 21.5);
    expect(result.isCached, isTrue);
    expect(result.cachedAt, cachedAt);
  });

  test('ignores malformed cache and preserves the API error', () async {
    final repository = await _repository(
      statusCode: 503,
      data: {'error': 'unavailable'},
      initialValues: {'weatherCache:en:london': '{malformed'},
    );

    await expectLater(
      repository.getForecastCurrent('London'),
      throwsA(
        isA<WeatherApiException>().having(
          (error) => error.kind,
          'kind',
          WeatherApiErrorKind.unavailable,
        ),
      ),
    );
  });

  test('maps authentication errors consistently for every API endpoint',
      () async {
    final repository = await _repository(
      statusCode: 401,
      data: {
        'error': {'message': 'Invalid key'}
      },
    );

    final requests = [
      repository.getForecastCurrent('London'),
      repository.getForecastDay('London'),
      repository.getForecastWeek('London'),
      repository.searchLocation('London'),
    ];
    for (final request in requests) {
      await expectLater(
        request,
        throwsA(
          isA<WeatherApiException>().having(
            (error) => error.kind,
            'kind',
            WeatherApiErrorKind.authentication,
          ),
        ),
      );
    }
  });

  test('maps invalid locations and malformed server responses', () async {
    final invalidCityRepository = await _repository(
      statusCode: 400,
      data: {
        'error': {'message': 'No matching location found.'}
      },
    );
    await expectLater(
      invalidCityRepository.getForecastCurrent('Unknown'),
      throwsA(
        isA<WeatherApiException>().having(
          (error) => error.kind,
          'kind',
          WeatherApiErrorKind.invalidLocation,
        ),
      ),
    );

    final malformedRepository =
        await _repository(statusCode: 200, data: {'unexpected': true});
    await expectLater(
      malformedRepository.searchLocation('London'),
      throwsA(
        isA<WeatherApiException>().having(
          (error) => error.kind,
          'kind',
          WeatherApiErrorKind.unavailable,
        ),
      ),
    );
  });
}
