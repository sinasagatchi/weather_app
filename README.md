# Atmos Weather

Atmos is an Android-focused weather app built on the existing Flutter Weather App foundation. It combines WeatherAPI forecasts with a calm Emerald Atmosphere interface, persistent favorite cities, English and Turkish localization, and light, dark, and system themes.

> Live weather and city search require a WeatherAPI key. This repository does not include credentials or fabricated forecast data.

## Features

- Current conditions with temperature, humidity, wind, and precipitation.
- Hourly forecast and a temperature curve drawn from the API response.
- Seven-day high/low forecast.
- Debounced city search with favorite and detail actions.
- Persistent favorite cities, language, theme, and reduced-motion preference.
- Per-city weather failures and retry controls; one unavailable favorite does not block the rest.
- Last successful current conditions are cached locally and identified as saved data when shown offline.
- English and Turkish interface and date formatting.
- System, light, and dark appearance modes; Android's reduced-animation preference is respected.
- HTTPS requests to WeatherAPI with request timeouts and user-facing error states.

## Screenshots

Screenshots from a running Android device or emulator are not included yet. No Android emulator or device was connected when this version was prepared; screenshots should be added here after a live run with a configured API key.

## Technology

- Flutter and Dart
- Riverpod 3
- Dio
- GoRouter
- WeatherAPI
- SharedPreferences
- Flutter ARB localization and `intl`

## Architecture

```text
lib/
  config/          Theme, routing, environment and shared helpers
  domain/          Weather entities, repository contract and use case
  infrastructure/  WeatherAPI models, mapper and Dio repository
  l10n/            English and Turkish ARB translations
  presentation/    Screens, search delegate and Riverpod providers
```

WeatherAPI response models and JSON parsing stay in `infrastructure`; screens consume domain weather entities through repository-backed Riverpod providers.

## Design palette

| Token | HEX | Use |
|---|---|---|
| Deep Green | `#101F20` | Dark background |
| Surface Green | `#1B3838` | Dark surfaces |
| Teal Green | `#347C75` | Primary accent |
| Mint | `#8BC9B3` | Highlights |
| Pale White | `#F0F7F2` | Light background and dark-mode text |

## Configure WeatherAPI

1. Create a key at [WeatherAPI](https://www.weatherapi.com/).
2. Copy `.env.example` to `.env` (PowerShell: `Copy-Item .env.example .env`).
3. Set `weatherapiKey` in `.env`.
4. Run `flutter pub get` and launch the app.

The `.env` file is ignored by Git. A Flutter app is distributed to end-user devices, so a bundled API key is extractable; dotenv is configuration loading, not secret storage. For production distribution, use a backend proxy to protect the provider key and apply request limits.

If `.env` or its key is missing, the app still launches and explains that live weather needs configuration. Previously cached weather may still be available.

## Install and run

```powershell
flutter pub get
flutter run -d <android-device-id>
```

## Build Android APK

```powershell
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.
The current release build uses the Android debug signing config for local verification. Configure a private release keystore before distributing an APK; never commit signing keys or passwords.

## Tests and analysis

```powershell
dart format .
flutter analyze
flutter test
```

## Preferences and units

The app uses Celsius and kilometers per hour. Preferences and favorite locations are stored with SharedPreferences. The current-conditions cache is separate from the favorite-city list.

## License and attribution

This project continues the `ivansaul/flutter_weather_app` source project and retains its existing source assets and attribution notices. The upstream project README identifies the project as MIT-licensed; consult the upstream repository's license text before redistribution. This working tree does not currently contain a root `LICENSE` file.
