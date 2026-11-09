import 'dart:async';

import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';

/// The player's settings for the whole app, in one place: the app's theme
/// follows them, the game reads them, and the settings page changes them.
///
/// It starts with [defaultSettings], and [load] swaps in the saved ones.
/// [update] applies a change at once and then saves it, and [changes]
/// announces every new value, the loaded one included.
final class SettingsStore {
  SettingsStore({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  // Synchronous, so a change reaches the screens in the same frame as the
  // tap that made it.
  final StreamController<AppSettings> _changes =
      StreamController<AppSettings>.broadcast(sync: true);

  AppSettings _current = defaultSettings;

  /// How many changes [update] has made, so [load] can tell whether the
  /// player changed something while the saved settings were loading.
  int _updateCount = 0;

  /// The settings now.
  AppSettings get current => _current;

  /// Each new value of [current], as it happens.
  Stream<AppSettings> get changes => _changes.stream;

  /// Swaps in the saved settings, unless the player changed a setting while
  /// they loaded: that change is newer, so it stays.
  Future<void> load() async {
    final updatesBefore = _updateCount;
    final saved = await _settingsRepository.load();
    if (_updateCount == updatesBefore) _set(saved);
  }

  /// Applies [settings] at once, then saves them.
  Future<void> update(AppSettings settings) async {
    _updateCount++;
    _set(settings);
    await _settingsRepository.save(settings);
  }

  void _set(AppSettings settings) {
    _current = settings;
    _changes.add(settings);
  }
}
