import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/providers/app_preferences_provider.dart';
import 'package:flutter_template/presentation/screens/home_screen.dart';

void main() {
  testWidgets('home offers city search when no favorites are saved',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );

    expect(find.text('Add a city to see its forecast'), findsOneWidget);
    expect(find.text('Add a city'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
