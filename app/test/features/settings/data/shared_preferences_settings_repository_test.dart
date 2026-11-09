import 'package:cephalopod/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/failing_shared_preferences.dart';
import 'settings_repository_contract.dart';

void main() {
  late List<(Object, String?)> reports;

  setUp(() => reports = []);

  /// A repository on [storage]: fresh, empty in-memory preferences unless
  /// the test says otherwise.
  SharedPreferencesSettingsRepository create({
    SharedPreferencesAsyncPlatform? storage,
  }) {
    SharedPreferencesAsyncPlatform.instance =
        storage ?? InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesSettingsRepository(
      sharedPreferencesAsync: SharedPreferencesAsync(),
      errorReporter: (error, _, {reason}) => reports.add((error, reason)),
    );
  }

  testSettingsRepositoryContract(() async => create());

  group('SharedPreferencesSettingsRepository', () {
    test('keeps the default theme when the saved one is unknown', () async {
      final repository = create();
      await SharedPreferencesAsync().setString('theme', 'sepia');

      expect((await repository.load()).theme, defaultSettings.theme);
      expect(reports, isEmpty);
    });
  });

  group('SharedPreferencesSettingsRepository when storage fails', () {
    late FailingSharedPreferences storage;
    late SharedPreferencesSettingsRepository repository;

    setUp(() {
      storage = FailingSharedPreferences();
      repository = create(storage: storage);
    });

    test('reports a failed load, and gives the defaults', () async {
      expect(await repository.load(), defaultSettings);
      expect(reports, [(storage.failure, 'loading the settings')]);
    });

    test('reports a failed save, and carries on', () async {
      await repository.save((
        theme: ThemePreference.dark,
        highlightLastMove: false,
      ));

      expect(reports, [(storage.failure, 'saving the settings')]);
    });

    test('lets a bug through, without reporting it', () async {
      final buggy = create(
        storage: FailingSharedPreferences(failure: StateError('A bug')),
      );

      await expectLater(buggy.load(), throwsStateError);
      expect(reports, isEmpty);
    });
  });
}
