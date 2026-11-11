import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/theme/app_theme.dart';
import '../../config/helpers/weather_icon.dart';
import '../../domain/entities/weather.dart';
import '../../infrastructure/repositories/weather_repository_impl.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/favorite_locations_provider.dart';
import '../providers/weather_repository_provider.dart';
import '../providers/weather_provider.dart';
import '../delegates/search_delegate.dart';
import '../widgets/appbar.dart';
import 'detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String name = 'home_screen';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedLocationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locations = ref.watch(favoriteLocationsProvider);
    final preferences = ref.watch(appPreferencesProvider);
    final systemReducesMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final selectedLocation = locations.cast<Location?>().firstWhere(
          (location) => location?.stableId == _selectedLocationId,
          orElse: () => locations.isEmpty ? null : locations.first,
        );
    final weatherQuery = selectedLocation == null
        ? null
        : '${selectedLocation.lat},${selectedLocation.lon}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                  sliver: SliverToBoxAdapter(child: const AppBarWidget()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: selectedLocation == null
                        ? _EmptyWeather(
                            title: l10n.addFirstCity,
                            actionLabel: l10n.addCity,
                            onAdd: () => _startSearch(context),
                          )
                        : _currentWeather(
                            selectedLocation,
                            weatherQuery!,
                            l10n,
                            preferences,
                            systemReducesMotion,
                          ),
                  ),
                ),
                if (selectedLocation != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: _ForecastSections(
                        query: weatherQuery!,
                        l10n: l10n,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                  sliver: locations.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : SliverToBoxAdapter(
                          child: _FavoritesHeader(
                            l10n: l10n,
                            onAdd: () => _startSearch(context),
                          ),
                        ),
                ),
                if (locations.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 164,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: locations.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          return _FavoriteCityCard(
                            key: ValueKey(location.stableId),
                            location: location,
                            selected:
                                selectedLocation?.stableId == location.stableId,
                            onSelect: () => setState(
                              () => _selectedLocationId = location.stableId,
                            ),
                            onRemove: () => _removeFavorite(location, l10n),
                          );
                        },
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentWeather(
    Location location,
    String query,
    AppLocalizations l10n,
    AppPreferences preferences,
    bool systemReducesMotion,
  ) {
    final weather = ref.watch(forecastCurrentProvider(query));
    return weather.when(
      loading: () => const _WeatherLoading(),
      error: (error, stackTrace) => _WeatherError(
        message: _errorMessage(error, l10n),
        retryLabel: l10n.retry,
        onRetry: () => ref.invalidate(forecastCurrentProvider(query)),
      ),
      data: (forecast) => AnimatedSwitcher(
        duration: preferences.reduceMotion || systemReducesMotion
            ? Duration.zero
            : const Duration(milliseconds: 300),
        child: _WeatherHero(
          key: ValueKey(location.stableId),
          forecast: forecast,
          l10n: l10n,
          locale: preferences.languageCode,
          onDetails: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailScreen(location: location),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final location = await showSearch<Location?>(
      context: context,
      delegate: SearchLocationDelegate(
        searchLocation: ref.read(weatherRepositoryProvider).searchLocation,
        searchLabel: l10n.searchHint,
        addFavorite: (location) async {
          final added =
              await ref.read(favoriteLocationsProvider.notifier).add(location);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(added ? l10n.cityAdded : l10n.alreadyFavorite),
              ),
            );
          }
        },
      ),
    );
    if (location != null && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(location: location),
        ),
      );
    }
  }

  Future<void> _removeFavorite(
    Location location,
    AppLocalizations l10n,
  ) async {
    try {
      await ref.read(favoriteLocationsProvider.notifier).remove(location);
      if (!mounted) return;
      if (_selectedLocationId == location.stableId) {
        setState(() => _selectedLocationId = null);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cityRemoved)),
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weatherUnavailable)),
      );
    }
  }

  String _errorMessage(Object error, AppLocalizations l10n) {
    if (error is! WeatherApiException) return l10n.weatherUnavailable;
    return switch (error.kind) {
      WeatherApiErrorKind.configuration => l10n.weatherSetupError,
      WeatherApiErrorKind.authentication => l10n.weatherAuthenticationError,
      WeatherApiErrorKind.invalidLocation => l10n.invalidCityError,
      WeatherApiErrorKind.network => l10n.weatherNetworkError,
      WeatherApiErrorKind.unavailable => l10n.weatherServiceError,
    };
  }
}

class _WeatherHero extends StatelessWidget {
  const _WeatherHero({
    super.key,
    required this.forecast,
    required this.l10n,
    required this.locale,
    required this.onDetails,
  });

  final ForecastCurrent forecast;
  final AppLocalizations l10n;
  final String locale;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weather = forecast.current;
    final now = DateFormat.yMMMMEEEEd(locale).format(DateTime.now());
    final location = forecast.location;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? const [AppTheme.surfaceGreen, AppTheme.deepGreen]
              : const [Color(0xFFDCEFE5), AppTheme.paleWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${location.name}, ${location.country}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.viewForecast,
                onPressed: onDetails,
                icon: const Icon(Icons.arrow_outward),
              ),
            ],
          ),
          Text(
            now,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (forecast.isCached) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.cloud_off_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(l10n.cachedWeather)),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.tempC.round()}°',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 84,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.description,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (weather.feelsLikeC != null)
                      Text(
                        '${l10n.feelsLike} ${weather.feelsLikeC!.round()}°C',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              _WeatherIllustration(
                icon: weatherIconForCode(weather.code),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _Metric(
                icon: Icons.water_drop_outlined,
                label: l10n.humidity,
                value: '${weather.humidity}%',
              ),
              const SizedBox(width: 18),
              _Metric(
                icon: Icons.air,
                label: l10n.wind,
                value: '${weather.windKph.round()} km/h',
              ),
              const SizedBox(width: 18),
              _Metric(
                icon: Icons.grain,
                label: l10n.precipitation,
                value: '${weather.precipMm} mm',
              ),
            ],
          ),
          if (forecast.cachedAt != null) ...[
            const SizedBox(height: 14),
            Text(
              l10n.updated(DateFormat.jm(locale).format(forecast.cachedAt!)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherIllustration extends StatelessWidget {
  const _WeatherIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.02)],
        ),
      ),
      child: Icon(icon, size: 76, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ForecastSections extends ConsumerWidget {
  const _ForecastSections({
    required this.query,
    required this.l10n,
  });

  final String query;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourly = ref.watch(forecastDayProvider(query));
    final weekly = ref.watch(forecastWeekProvider(query));
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hourlyForecast, style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        hourly.when(
          loading: () => const _InlineLoading(),
          error: (error, stackTrace) => Text(l10n.noForecast),
          data: (forecast) {
            final values = forecast.day;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 92,
                  child: LayoutBuilder(
                    builder: (context, constraints) => CustomPaint(
                      size: Size(constraints.maxWidth, 92),
                      painter: _TemperatureChartPainter(
                        values.map((value) => value.tempC).toList(),
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: values.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final weather = values[index];
                      return SizedBox(
                        width: 52,
                        child: Column(
                          children: [
                            Text(
                              DateFormat(
                                      'jm',
                                      Localizations.localeOf(context)
                                          .languageCode)
                                  .format(DateTime.parse(weather.date)),
                              style: theme.textTheme.labelSmall,
                            ),
                            const SizedBox(height: 8),
                            Icon(weatherIconForCode(weather.code), size: 20),
                            const SizedBox(height: 8),
                            Text('${weather.tempC.round()}°'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.weekForecast, style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        weekly.when(
          loading: () => const _InlineLoading(),
          error: (error, stackTrace) => Text(l10n.noForecast),
          data: (forecast) => Column(
            children: forecast.week.map((weather) {
              final date = DateTime.parse(weather.date);
              final day = DateTime.now().day == date.day
                  ? l10n.today
                  : DateFormat(
                          'EEE', Localizations.localeOf(context).languageCode)
                      .format(date);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    SizedBox(width: 62, child: Text(day)),
                    Icon(weatherIconForCode(weather.code), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        weather.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                        '${weather.mintempC?.round() ?? weather.tempC.round()}°'),
                    const SizedBox(width: 14),
                    Text(
                      '${weather.tempC.round()}°',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TemperatureChartPainter extends CustomPainter {
  const _TemperatureChartPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minimum = values.reduce((a, b) => a < b ? a : b);
    final range = (values.reduce((a, b) => a > b ? a : b) - minimum)
        .clamp(1.0, double.infinity);
    final points = <Offset>[
      for (var index = 0; index < values.length; index++)
        Offset(
          size.width * index / (values.length - 1),
          size.height -
              ((values[index] - minimum) / range * (size.height - 18)) -
              9,
        ),
    ];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final middleX = (previous.dx + current.dx) / 2;
      line.cubicTo(
          middleX, previous.dy, middleX, current.dy, current.dx, current.dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.01)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    for (final point in points.where(
        (point) => point.dx == points.first.dx || point.dx == points.last.dx)) {
      canvas.drawCircle(point, 3.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureChartPainter oldDelegate) =>
      values != oldDelegate.values || color != oldDelegate.color;
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.l10n, required this.onAdd});

  final AppLocalizations l10n;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              l10n.favorites,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addCity),
          ),
        ],
      );
}

class _FavoriteCityCard extends ConsumerWidget {
  const _FavoriteCityCard({
    super.key,
    required this.location,
    required this.selected,
    required this.onSelect,
    required this.onRemove,
  });

  final Location location;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final result = ref.watch(favoriteWeatherProvider(location));
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 190,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.removeFavorite(location.name),
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                Expanded(
                  child: result.when(
                    loading: () => const Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (error, stackTrace) => Text(
                      l10n.weatherUnavailable,
                      maxLines: 2,
                      style: theme.textTheme.bodySmall,
                    ),
                    data: (value) {
                      final forecast = value.forecast;
                      if (forecast == null) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.weatherUnavailable,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.retry,
                              onPressed: () => ref.invalidate(
                                  favoriteWeatherProvider(location)),
                              icon: const Icon(Icons.refresh, size: 20),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Icon(weatherIconForCode(forecast.current.code),
                              size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '${forecast.current.tempC.round()}°',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              forecast.current.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherLoading extends StatelessWidget {
  const _WeatherLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 340,
        child: Center(child: CircularProgressIndicator()),
      );
}

class _WeatherError extends StatelessWidget {
  const _WeatherError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      );
}

class _EmptyWeather extends StatelessWidget {
  const _EmptyWeather({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_outlined,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      );
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}
