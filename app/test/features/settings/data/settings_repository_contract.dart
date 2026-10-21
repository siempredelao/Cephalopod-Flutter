import 'package:cephalopod/core/settings/app_settings.dart';
import 'package:cephalopod/core/settings/settings_repository.dart';
import 'package:cephalopod/core/settings/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';

/// What every [SettingsRepository] must do. Each implementation's test calls
/// this with a way to create a fresh, empty repository.
void testSettingsRepositoryContract(
  Future<SettingsRepository> Function() create,
) {
  group('SettingsRepository contract', () {
    late SettingsRepository repository;

    setUp(() async => repository = await create());

    test('gives the defaults before anything is saved', () async {
      expect(await repository.load(), defaultSettings);
    });

    test('gives back the saved settings', () async {
      const changed = (theme: ThemePreference.light, highlightLastMove: false);

      await repository.save(changed);

      expect(await repository.load(), changed);
    });

    test('keeps only the latest save', () async {
      const dark = (theme: ThemePreference.dark, highlightLastMove: true);
      await repository.save(defaultSettings);

      await repository.save(dark);

      expect(await repository.load(), dark);
    });
  });
}
