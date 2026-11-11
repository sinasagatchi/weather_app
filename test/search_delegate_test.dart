import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_template/domain/entities/weather.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/delegates/search_delegate.dart';

const _oslo = Location(
  name: 'Oslo',
  region: 'Oslo',
  country: 'Norway',
  lat: 59.9139,
  lon: 10.7522,
);

Future<void> _openSearch(
  WidgetTester tester,
  SearchLocationCallback searchLocation, {
  ValueChanged<Location?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await showSearch<Location?>(
                context: context,
                delegate: SearchLocationDelegate(
                  searchLocation: searchLocation,
                  addFavorite: (_) async {},
                  searchLabel: 'Search city',
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open search'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open search'));
  await tester.pumpAndSettle();
}

Future<void> _searchFor(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump();
}

void main() {
  testWidgets('debounces city search and returns a selected location',
      (tester) async {
    var requests = 0;
    Location? selected;
    await _openSearch(
      tester,
      (query) async {
        requests++;
        return [_oslo];
      },
      onResult: (location) => selected = location,
    );

    await _searchFor(tester, 'Oslo');
    expect(find.text('Searching cities…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();

    expect(requests, 1);
    final resultTitle = find.descendant(
      of: find.byType(ListTile),
      matching: find.text('Oslo'),
    );
    expect(resultTitle, findsOneWidget);
    await tester.tap(resultTitle);
    await tester.pumpAndSettle();
    expect(selected?.stableId, _oslo.stableId);
  });

  testWidgets('shows a localized empty state when the search has no matches',
      (tester) async {
    await _openSearch(tester, (query) async => []);
    await _searchFor(tester, 'Unknown');
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();

    expect(find.text('No cities found. Try another search.'), findsOneWidget);
  });

  testWidgets('shows a localized error when the search request fails',
      (tester) async {
    await _openSearch(
      tester,
      (query) async => throw Exception('request failed'),
    );
    await _searchFor(tester, 'Unknown');
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't search right now. Check your connection and retry."),
      findsOneWidget,
    );
  });
}
