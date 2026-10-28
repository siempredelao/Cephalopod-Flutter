import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The player's settings: the app's theme, and whether the board marks the
/// last move. Changes apply, and are saved, at once.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: _spacing),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: Text('Theme', style: textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(_spacing),
              child: SegmentedButton<ThemePreference>(
                segments: const [
                  ButtonSegment(
                    value: ThemePreference.system,
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    label: Text('Dark'),
                  ),
                ],
                selected: {settings.theme},
                onSelectionChanged: (choice) =>
                    cubit.chooseTheme(choice.single),
              ),
            ),
            SwitchListTile(
              title: const Text('Highlight the last move'),
              value: settings.highlightLastMove,
              onChanged: (_) => cubit.toggleLastMoveHighlight(),
            ),
          ],
        ),
      ),
    );
  }
}
