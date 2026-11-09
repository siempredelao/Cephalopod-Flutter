import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';

/// Turns the player's [AppSettings] into the [SettingsViewState] the
/// settings page draws, and the page's choices back into settings.
///
/// Both ways live here, so a theme added to one side is added to the other
/// in the same file.
final class SettingsViewStateMapper {
  const SettingsViewStateMapper();

  SettingsViewState map(AppSettings settings) {
    final themeUi = _themeUiOf(settings.theme);
    return SettingsViewState(
      theme: themeUi,
      highlightLastMove: settings.highlightLastMove,
    );
  }

  /// The theme preference chosen as [theme] on the settings page: the way
  /// back from [map].
  ThemePreference themePreferenceOf(ThemeUi theme) => switch (theme) {
    ThemeUi.system => ThemePreference.system,
    ThemeUi.light => ThemePreference.light,
    ThemeUi.dark => ThemePreference.dark,
  };

  ThemeUi _themeUiOf(ThemePreference theme) => switch (theme) {
    ThemePreference.system => ThemeUi.system,
    ThemePreference.light => ThemeUi.light,
    ThemePreference.dark => ThemeUi.dark,
  };
}
