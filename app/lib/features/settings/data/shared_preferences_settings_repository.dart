import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [SettingsRepository] that keeps each setting under its own key with
/// shared_preferences (docs/adr/0012).
///
/// Storage never stops the app (docs/adr/0016). When shared_preferences
/// fails, the error goes to the [ErrorReporter] and the app goes on: a
/// failed [load] gives the defaults, and a failed [save] leaves the change
/// on screen, unsaved.
///
/// Only `Exception`s are caught, which is how storage reports a failure. An
/// `Error` is a bug, so it goes on to the app-wide error reporting.
final class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({
    required this._sharedPreferencesAsync,
    required this._errorReporter,
  });

  final SharedPreferencesAsync _sharedPreferencesAsync;
  final ErrorReporter _errorReporter;

  static const String _themeKey = 'theme';
  static const String _highlightKey = 'highlightLastMove';

  /// The saved settings. A setting never saved, or saved with a value this
  /// version does not know, keeps its default; so does every setting when
  /// storage fails.
  @override
  Future<AppSettings> load() async {
    final String? theme;
    final bool? highlight;
    try {
      theme = await _sharedPreferencesAsync.getString(_themeKey);
      highlight = await _sharedPreferencesAsync.getBool(_highlightKey);
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'loading the settings');
      return defaultSettings;
    }
    return (
      theme: ThemePreference.values.asNameMap()[theme] ?? defaultSettings.theme,
      highlightLastMove: highlight ?? defaultSettings.highlightLastMove,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      await _sharedPreferencesAsync.setString(_themeKey, settings.theme.name);
      await _sharedPreferencesAsync.setBool(
        _highlightKey,
        settings.highlightLastMove,
      );
    } on Exception catch (error, stackTrace) {
      _errorReporter(error, stackTrace, reason: 'saving the settings');
    }
  }
}
