import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The player's settings: the app's theme, and whether the board marks the
/// last move. Changes apply, and are saved, at once.
///
/// It gets a `SettingsCubit` from [createCubit] for as long as it is on
/// screen, and draws its [SettingsViewState].
class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.createCubit, super.key});

  /// Builds the page's cubit. The settings module wires it to the app's
  /// settings store.
  final SettingsCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(),
      child: const _SettingsView(),
    );
  }
}

/// The settings, drawn from the cubit above it.
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  static const double _spacing = 16;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsViewState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.symmetric(vertical: _spacing),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: Text('Theme', style: textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(_spacing),
              child: SegmentedButton<ThemeUi>(
                segments: const [
                  ButtonSegment(
                    value: ThemeUi.system,
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeUi.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeUi.dark,
                    label: Text('Dark'),
                  ),
                ],
                selected: {state.theme},
                onSelectionChanged: (choice) =>
                    cubit.chooseTheme(choice.single),
              ),
            ),
            SwitchListTile(
              title: const Text('Highlight the last move'),
              value: state.highlightLastMove,
              onChanged: (_) => cubit.toggleLastMoveHighlight(),
            ),
          ],
        ),
      ),
    );
  }
}
