import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weather.dart';
import '../../config/helpers/weather_icon.dart';
import '../../infrastructure/repositories/weather_repository_impl.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/weather_provider.dart';

class DetailScreen extends ConsumerWidget {
  static const String name = 'detail_screen';

  const DetailScreen({super.key, required this.location});

  final Location location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(appPreferencesProvider).languageCode;
    final query = '${location.lat},${location.lon}';
    final current = ref.watch(forecastCurrentProvider(query));
    final hourly = ref.watch(forecastDayProvider(query));
    final weekly = ref.watch(forecastWeekProvider(query));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            onPressed: () {
              ref.invalidate(forecastCurrentProvider(query));
              ref.invalidate(forecastDayProvider(query));
              ref.invalidate(forecastWeekProvider(query));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          current.when(
            loading: () => const _Loading(),
            error: (error, stackTrace) => _ErrorCard(
              message: _localizedError(error, l10n),
              retry: () => ref.invalidate(forecastCurrentProvider(query)),
            ),
            data: (forecast) {
              final date = DateFormat.yMMMMEEEEd(locale).format(DateTime.now());
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.dark
                        ? const [Color(0xFF1B3838), Color(0xFF101F20)]
                        : const [Color(0xFFDCEFE5), Color(0xFFF0F7F2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${location.name}, ${location.country}',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(date, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          '${forecast.current.tempC.round()}°',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Icon(
                          weatherIconForCode(forecast.current.code),
                          size: 54,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    Text(
                      forecast.current.description,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 22,
                      runSpacing: 12,
                      children: [
                        _WeatherFact(
                          label: l10n.humidity,
                          value: '${forecast.current.humidity}%',
                        ),
                        _WeatherFact(
                          label: l10n.wind,
                          value: '${forecast.current.windKph.round()} km/h',
                        ),
                        _WeatherFact(
                          label: l10n.precipitation,
                          value: '${forecast.current.precipMm} mm',
                        ),
                        if (forecast.current.feelsLikeC != null)
                          _WeatherFact(
                            label: l10n.feelsLike,
                            value: '${forecast.current.feelsLikeC!.round()}°C',
                          ),
                      ],
                    ),
                    if (forecast.isCached) ...[
                      const SizedBox(height: 16),
                      Text(l10n.cachedWeather),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(l10n.hourlyForecast, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          hourly.when(
            loading: () => const _Loading(),
            error: (error, stackTrace) => Text(l10n.noForecast),
            data: (forecast) => SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.day.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final weather = forecast.day[index];
                  return SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Text(
                          DateFormat('jm', locale)
                              .format(DateTime.parse(weather.date)),
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        Icon(weatherIconForCode(weather.code)),
                        const SizedBox(height: 10),
                        Text('${weather.tempC.round()}°'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(l10n.weekForecast, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          weekly.when(
            loading: () => const _Loading(),
            error: (error, stackTrace) => Text(l10n.noForecast),
            data: (forecast) => Column(
              children: forecast.week.map((weather) {
                final date = DateTime.parse(weather.date);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    DateFormat('EEEE', locale).format(date),
                  ),
                  subtitle: Text(weather.description),
                  leading: Icon(weatherIconForCode(weather.code)),
                  trailing: Text(
                    '${weather.mintempC?.round() ?? weather.tempC.round()}°   ${weather.tempC.round()}°',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedError(Object error, AppLocalizations l10n) {
  if (error is! WeatherApiException) return l10n.weatherUnavailable;
  return switch (error.kind) {
    WeatherApiErrorKind.configuration => l10n.weatherSetupError,
    WeatherApiErrorKind.authentication => l10n.weatherAuthenticationError,
    WeatherApiErrorKind.invalidLocation => l10n.invalidCityError,
    WeatherApiErrorKind.network => l10n.weatherNetworkError,
    WeatherApiErrorKind.unavailable => l10n.weatherServiceError,
  };
}

class _WeatherFact extends StatelessWidget {
  const _WeatherFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 118,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(22),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.retry});

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(message),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: retry,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
}
