import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';

/// Turns the player's [AppSettings] into the [SettingsViewState] the
/// settings page draws.
final class SettingsViewStateMapper {
  const SettingsViewStateMapper();

  SettingsViewState map(AppSettings settings) {
    final themeUi = _themeUiOf(settings.theme);
    return SettingsViewState(
      theme: themeUi,
      highlightLastMove: settings.highlightLastMove,
    );
  }

  ThemeUi _themeUiOf(ThemePreference theme) => switch (theme) {
    ThemePreference.system => ThemeUi.system,
    ThemePreference.light => ThemeUi.light,
    ThemePreference.dark => ThemeUi.dark,
  };
}
