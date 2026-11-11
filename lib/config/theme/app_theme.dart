import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color deepGreen = Color(0xFF101F20);
  static const Color surfaceGreen = Color(0xFF1B3838);
  static const Color tealGreen = Color(0xFF347C75);
  static const Color mint = Color(0xFF8BC9B3);
  static const Color paleWhite = Color(0xFFF0F7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFE5F0EA);
  static const Color lightText = Color(0xFF172B29);
  static const Color mutedLightText = Color(0xFF526B66);
  static const Color mutedDarkText = Color(0xFFB7CCC5);
  static const Color error = Color(0xFFB84F52);

  static ThemeData get lightTheme => _theme(
        brightness: Brightness.light,
        background: paleWhite,
        surface: lightSurface,
        elevatedSurface: lightElevated,
        text: lightText,
        secondaryText: mutedLightText,
      );

  static ThemeData get darkTheme => _theme(
        brightness: Brightness.dark,
        background: deepGreen,
        surface: surfaceGreen,
        elevatedSurface: const Color(0xFF254443),
        text: paleWhite,
        secondaryText: mutedDarkText,
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color elevatedSurface,
    required Color text,
    required Color secondaryText,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: tealGreen,
      onPrimary: Colors.white,
      secondary: mint,
      onSecondary: deepGreen,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: text.withValues(alpha: 0.12),
      textTheme: Typography.material2021().black.apply(
            bodyColor: text,
            displayColor: text,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            brightness == Brightness.dark ? elevatedSurface : deepGreen,
        contentTextStyle: const TextStyle(color: paleWhite),
      ),
    );
  }

  static const backgroundMagenta = deepGreen;
  static const backgroundLightGrey = surfaceGreen;
  static const backgroundWhite = paleWhite;
  static const cardWhite = lightSurface;
  static const cardPurple = tealGreen;
  static const cardCrimson = tealGreen;
  static const cardBlueViolet = surfaceGreen;
  static const cardGoldenYellow = mint;
  static const cardLightBlue = mint;
  static const cardLightBlue2 = mint;
  static const cardPink = mint;
  static const cardPurple2 = tealGreen;
  static const cardColorGoldenYellow2 = mint;
  static const textColorDarkBrown = lightText;
  static const textColorPink = tealGreen;
  static const textColorPurple = tealGreen;
  static const textColorLightBlue = tealGreen;
  static const textColorWhite = paleWhite;
  static const textColorGray = mutedLightText;

  static const buttonTextStyle = TextStyle(
    color: paleWhite,
    fontWeight: FontWeight.bold,
  );
  static const locationTextStyleLarge = TextStyle(
    color: lightText,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const locationTextStyleMedium = TextStyle(
    color: lightText,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const dateTextStyleMedium = TextStyle(
    color: mutedLightText,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const dateTextStyleLarge = TextStyle(
    color: lightText,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
