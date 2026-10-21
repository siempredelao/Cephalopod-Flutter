import 'package:cephalopod/core/settings/app_settings.dart';
import 'package:cephalopod/core/settings/settings_repository.dart';
import 'package:cephalopod/core/settings/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [SettingsRepository] that keeps each setting under its own key with
/// shared_preferences (docs/adr/0012).
final class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({required this._preferences});

  final SharedPreferencesAsync _preferences;

  static const String _themeKey = 'theme';
  static const String _highlightKey = 'highlightLastMove';

  /// The saved settings. A setting never saved, or saved with a value this
  /// version does not know, keeps its default.
  @override
  Future<AppSettings> load() async {
    final theme = await _preferences.getString(_themeKey);
    final highlight = await _preferences.getBool(_highlightKey);
    return (
      theme: ThemePreference.values.asNameMap()[theme] ?? defaultSettings.theme,
      highlightLastMove: highlight ?? defaultSettings.highlightLastMove,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _preferences.setString(_themeKey, settings.theme.name);
    await _preferences.setBool(_highlightKey, settings.highlightLastMove);
  }
}
