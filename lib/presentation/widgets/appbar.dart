import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/presentation/providers/providers.dart';
import 'package:flutter_template/presentation/widgets/widgets.dart';

import '../../domain/entities/weather.dart';
import '../../l10n/app_localizations.dart';
import '../delegates/search_delegate.dart';
import '../providers/favorite_locations_provider.dart';
import '../screens/detail_screen.dart';
import '../screens/settings_sheet.dart';

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const AppLogo(),
        const Spacer(),
        IconButton(
          tooltip: l10n.language,
          onPressed: () => _showSettings(context),
          icon: const Icon(Icons.language),
        ),
        IconButton(
          tooltip: l10n.settings,
          onPressed: () => _showSettings(context),
          icon: const Icon(Icons.tune),
        ),
        IconButton(
          tooltip: l10n.search,
          onPressed: () async {
            final location = await showSearch<Location?>(
              context: context,
              delegate: SearchLocationDelegate(
                searchLocation:
                    ref.read(weatherRepositoryProvider).searchLocation,
                searchLabel: l10n.searchHint,
                addFavorite: (location) async {
                  final added = await ref
                      .read(favoriteLocationsProvider.notifier)
                      .add(location);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added ? l10n.cityAdded : l10n.alreadyFavorite,
                        ),
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
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }
}
