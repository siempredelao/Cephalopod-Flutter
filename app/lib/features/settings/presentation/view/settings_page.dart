import 'package:cephalopod/core/l10n/l10n.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsViewState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.symmetric(vertical: _spacing),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: Text(l10n.settingsTheme, style: textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(_spacing),
              child: SegmentedButton<ThemeUi>(
                segments: [
                  ButtonSegment(
                    value: ThemeUi.system,
                    label: Text(l10n.settingsThemeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeUi.light,
                    label: Text(l10n.settingsThemeLight),
                  ),
                  ButtonSegment(
                    value: ThemeUi.dark,
                    label: Text(l10n.settingsThemeDark),
                  ),
                ],
                selected: {state.theme},
                onSelectionChanged: (choice) =>
                    cubit.chooseTheme(choice.single),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.settingsHighlightLastMove),
              value: state.highlightLastMove,
              onChanged: (_) => cubit.toggleLastMoveHighlight(),
            ),
          ],
        ),
      ),
    );
  }
}
