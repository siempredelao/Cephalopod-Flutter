import 'dart:async';

import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/domain/settings_repository.dart';
import 'package:cephalopod/features/settings/domain/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/failing_shared_preferences.dart';

void main() {
  const dark = (
    theme: ThemePreference.dark,
    highlightLastMove: true,
    sound: true,
  );
  const light = (
    theme: ThemePreference.light,
    highlightLastMove: false,
    sound: false,
  );
  late InMemorySettingsRepository repository;
  late SettingsStore store;
  late List<AppSettings> announced;

  setUp(() {
    repository = InMemorySettingsRepository();
    store = SettingsStore(settingsRepository: repository);
    announced = [];
    store.changes.listen(announced.add);
  });

  group('SettingsStore', () {
    test('starts with the default settings', () {
      expect(store.current, defaultSettings);
    });

    test('loads the saved settings, and announces them', () async {
      await repository.save(dark);

      await store.load();

      expect(store.current, dark);
      expect(announced, [dark]);
    });

    test('applies a change at once, announces it, then saves it', () async {
      final saving = store.update(dark);

      expect(store.current, dark);
      expect(announced, [dark]);
      await saving;
      expect(await repository.load(), dark);
    });

    test('keeps a change made while the saved settings load', () async {
      await repository.save(light);
      final slow = _SlowSettingsRepository(repository);
      final slowStore = SettingsStore(settingsRepository: slow);

      final loading = slowStore.load();
      await slowStore.update(dark);
      slow.finishLoading();
      await loading;

      expect(slowStore.current, dark);
    });

    test('applies a change even when storage fails to save it', () async {
      final reasons = <String?>[];
      SharedPreferencesAsyncPlatform.instance = FailingSharedPreferences();
      final failingStore = SettingsStore(
        settingsRepository: SharedPreferencesSettingsRepository(
          sharedPreferencesAsync: SharedPreferencesAsync(),
          errorReporter: (_, _, {reason}) => reasons.add(reason),
        ),
      );

      await failingStore.update(dark);

      expect(failingStore.current, dark);
      expect(reasons, ['saving the settings']);
    });
  });
}

/// A [SettingsRepository] whose `load` reads at once but answers only on
/// [finishLoading], like slow storage at startup.
final class _SlowSettingsRepository implements SettingsRepository {
  _SlowSettingsRepository(this._repository);

  final SettingsRepository _repository;
  final Completer<void> _loaded = Completer<void>();

  void finishLoading() => _loaded.complete();

  @override
  Future<AppSettings> load() async {
    final saved = await _repository.load();
    await _loaded.future;
    return saved;
  }

  @override
  Future<void> save(AppSettings settings) => _repository.save(settings);
}
