import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_preferences_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(appPreferencesProvider);
    final notifier = ref.read(appPreferencesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.system, label: Text(l10n.system)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.light)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.dark)),
              ],
              selected: {preferences.themeMode},
              onSelectionChanged: (selection) =>
                  _save(context, notifier.setThemeMode(selection.first)),
            ),
            const SizedBox(height: 24),
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.english)),
                ButtonSegment(value: 'tr', label: Text(l10n.turkish)),
              ],
              selected: {preferences.languageCode},
              onSelectionChanged: (selection) =>
                  _save(context, notifier.setLanguage(selection.first)),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.reduceMotion),
              subtitle: Text(l10n.reduceMotionHint),
              value: preferences.reduceMotion,
              onChanged: (value) =>
                  _save(context, notifier.setReduceMotion(value)),
            ),
            Text(
              l10n.systemMotion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, Future<void> operation) async {
    try {
      await operation;
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsSaveError)),
      );
    }
  }
}
