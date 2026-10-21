import 'package:cephalopod/core/settings/app_settings.dart';
import 'package:cephalopod/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'settings_repository_contract.dart';

void main() {
  /// A repository on fresh, empty in-memory preferences.
  SharedPreferencesSettingsRepository create() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesSettingsRepository(
      preferences: SharedPreferencesAsync(),
    );
  }

  testSettingsRepositoryContract(() async => create());

  group('SharedPreferencesSettingsRepository', () {
    test('keeps the default theme when the saved one is unknown', () async {
      final repository = create();
      await SharedPreferencesAsync().setString('theme', 'sepia');

      expect((await repository.load()).theme, defaultSettings.theme);
    });
  });
}
