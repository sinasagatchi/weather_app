// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Atmos';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get theme => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionHint => 'Use fewer animations';

  @override
  String get favorites => 'Your cities';

  @override
  String get addCity => 'Add a city';

  @override
  String get addFirstCity => 'Add a city to see its forecast';

  @override
  String get searchHint => 'Search city, region or country';

  @override
  String get searchPrompt => 'Find a city';

  @override
  String get searching => 'Searching cities…';

  @override
  String get noSearchResults => 'No cities found. Try another search.';

  @override
  String get searchError =>
      'Couldn\'t search right now. Check your connection and retry.';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String removeFavorite(String city) {
    return 'Remove $city from favorites';
  }

  @override
  String get cityAdded => 'City added to your favorites';

  @override
  String get cityRemoved => 'City removed from your favorites';

  @override
  String get alreadyFavorite => 'This city is already in your favorites';

  @override
  String get currentWeather => 'Current weather';

  @override
  String get hourlyForecast => 'Next hours';

  @override
  String get weekForecast => '7-day forecast';

  @override
  String get today => 'Today';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get precipitation => 'Precipitation';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get cachedWeather => 'Saved weather · may be out of date';

  @override
  String get retry => 'Retry';

  @override
  String get weatherUnavailable => 'Weather is temporarily unavailable.';

  @override
  String get weatherSetupError =>
      'Weather service isn\'t configured. Copy .env.example to .env and add your WeatherAPI key.';

  @override
  String get weatherAuthenticationError =>
      'WeatherAPI rejected the key. Check your .env configuration.';

  @override
  String get invalidCityError =>
      'That city could not be found. Try another location.';

  @override
  String get weatherNetworkError =>
      'Couldn\'t reach the weather service. Check your connection and retry.';

  @override
  String get weatherServiceError =>
      'The weather service is temporarily unavailable. Please try again.';

  @override
  String get viewForecast => 'Full forecast';

  @override
  String get noForecast => 'Forecast details are unavailable.';

  @override
  String updated(String time) {
    return 'Updated $time';
  }

  @override
  String get close => 'Close';

  @override
  String get systemMotion => 'System motion settings are also respected.';

  @override
  String get settingsSaveError =>
      'Your setting could not be saved. Please try again.';
}
