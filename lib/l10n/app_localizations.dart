import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Atmos'**
  String get appTitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Use fewer animations'**
  String get reduceMotionHint;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Your cities'**
  String get favorites;

  /// No description provided for @addCity.
  ///
  /// In en, this message translates to:
  /// **'Add a city'**
  String get addCity;

  /// No description provided for @addFirstCity.
  ///
  /// In en, this message translates to:
  /// **'Add a city to see its forecast'**
  String get addFirstCity;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city, region or country'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Find a city'**
  String get searchPrompt;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching cities…'**
  String get searching;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No cities found. Try another search.'**
  String get noSearchResults;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search right now. Check your connection and retry.'**
  String get searchError;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove {city} from favorites'**
  String removeFavorite(String city);

  /// No description provided for @cityAdded.
  ///
  /// In en, this message translates to:
  /// **'City added to your favorites'**
  String get cityAdded;

  /// No description provided for @cityRemoved.
  ///
  /// In en, this message translates to:
  /// **'City removed from your favorites'**
  String get cityRemoved;

  /// No description provided for @alreadyFavorite.
  ///
  /// In en, this message translates to:
  /// **'This city is already in your favorites'**
  String get alreadyFavorite;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current weather'**
  String get currentWeather;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Next hours'**
  String get hourlyForecast;

  /// No description provided for @weekForecast.
  ///
  /// In en, this message translates to:
  /// **'7-day forecast'**
  String get weekForecast;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @cachedWeather.
  ///
  /// In en, this message translates to:
  /// **'Saved weather · may be out of date'**
  String get cachedWeather;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather is temporarily unavailable.'**
  String get weatherUnavailable;

  /// No description provided for @weatherSetupError.
  ///
  /// In en, this message translates to:
  /// **'Weather service isn\'t configured. Copy .env.example to .env and add your WeatherAPI key.'**
  String get weatherSetupError;

  /// No description provided for @weatherAuthenticationError.
  ///
  /// In en, this message translates to:
  /// **'WeatherAPI rejected the key. Check your .env configuration.'**
  String get weatherAuthenticationError;

  /// No description provided for @invalidCityError.
  ///
  /// In en, this message translates to:
  /// **'That city could not be found. Try another location.'**
  String get invalidCityError;

  /// No description provided for @weatherNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the weather service. Check your connection and retry.'**
  String get weatherNetworkError;

  /// No description provided for @weatherServiceError.
  ///
  /// In en, this message translates to:
  /// **'The weather service is temporarily unavailable. Please try again.'**
  String get weatherServiceError;

  /// No description provided for @viewForecast.
  ///
  /// In en, this message translates to:
  /// **'Full forecast'**
  String get viewForecast;

  /// No description provided for @noForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast details are unavailable.'**
  String get noForecast;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updated(String time);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @systemMotion.
  ///
  /// In en, this message translates to:
  /// **'System motion settings are also respected.'**
  String get systemMotion;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your setting could not be saved. Please try again.'**
  String get settingsSaveError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
