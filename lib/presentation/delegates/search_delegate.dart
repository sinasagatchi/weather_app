import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/weather.dart';
import '../../l10n/app_localizations.dart';

typedef SearchLocationCallback = Future<List<Location>> Function(String query);
typedef AddFavoriteCallback = Future<void> Function(Location location);

class SearchLocationDelegate extends SearchDelegate<Location?> {
  SearchLocationDelegate({
    required this.searchLocation,
    required this.addFavorite,
    required this.searchLabel,
  });

  final SearchLocationCallback searchLocation;
  final AddFavoriteCallback addFavorite;
  final String searchLabel;
  String _requestedQuery = '';
  Future<List<Location>>? _searchFuture;
  Timer? _debounce;
  Completer<List<Location>>? _pendingSearch;

  @override
  String get searchFieldLabel => searchLabel;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: AppLocalizations.of(context)!.close,
            onPressed: () => query = '',
            icon: const Icon(Icons.close),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: AppLocalizations.of(context)!.close,
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Center(child: Text(l10n.searchPrompt));
    }

    return FutureBuilder<List<Location>>(
      future: _futureFor(normalizedQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(l10n.searching),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.searchError, textAlign: TextAlign.center),
            ),
          );
        }

        final locations = snapshot.data ?? const <Location>[];
        if (locations.isEmpty) return Center(child: Text(l10n.noSearchResults));
        return ListView.separated(
          itemCount: locations.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final location = locations[index];
            return ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.location_on_outlined)),
              title: Text(location.name),
              subtitle: Text(
                [location.region, location.country]
                    .where((part) => part.isNotEmpty)
                    .join(', '),
              ),
              trailing: IconButton(
                tooltip: l10n.addFavorite,
                icon: const Icon(Icons.favorite_border),
                onPressed: () async {
                  try {
                    await addFavorite(location);
                    if (context.mounted) close(context, null);
                  } on Exception {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.weatherUnavailable)),
                      );
                    }
                  }
                },
              ),
              onTap: () => close(context, location),
            );
          },
        );
      },
    );
  }

  Future<List<Location>> _futureFor(String value) {
    if (value == _requestedQuery && _searchFuture != null) {
      return _searchFuture!;
    }
    _requestedQuery = value;
    _debounce?.cancel();
    if (_pendingSearch != null && !_pendingSearch!.isCompleted) {
      _pendingSearch!.complete(const []);
    }
    final completer = Completer<List<Location>>();
    _pendingSearch = completer;
    _searchFuture = completer.future;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        completer.complete(await searchLocation(value));
      } on Exception catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return _searchFuture!;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_pendingSearch != null && !_pendingSearch!.isCompleted) {
      _pendingSearch!.complete(const []);
    }
    super.dispose();
  }
}
