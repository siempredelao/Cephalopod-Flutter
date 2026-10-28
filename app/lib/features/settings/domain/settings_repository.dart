import 'package:cephalopod/features/settings/domain/models/app_settings.dart';

/// Keeps the player's settings, so they survive the app closing. Every
/// implementation passes the same contract tests.
abstract interface class SettingsRepository {
  /// The saved settings, with [defaultSettings] for anything never saved.
  Future<AppSettings> load();

  /// Saves [settings], replacing what was saved.
  Future<void> save(AppSettings settings);
}
