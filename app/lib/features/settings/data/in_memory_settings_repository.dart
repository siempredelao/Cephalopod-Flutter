import 'package:cephalopod/core/settings/app_settings.dart';
import 'package:cephalopod/core/settings/settings_repository.dart';

/// A [SettingsRepository] that keeps the settings in memory only, so they
/// are lost when the app closes. For tests, and as the reference the
/// contract tests hold other implementations to.
final class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = defaultSettings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
