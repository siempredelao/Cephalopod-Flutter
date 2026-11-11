import 'package:cephalopod/features/home/data/shared_preferences_first_launch_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/failing_shared_preferences.dart';
import 'first_launch_repository_contract.dart';

void main() {
  late List<(Object, String?)> reports;

  setUp(() => reports = []);

  /// A repository on [storage]: fresh, empty in-memory preferences unless
  /// the test says otherwise.
  SharedPreferencesFirstLaunchRepository create({
    SharedPreferencesAsyncPlatform? storage,
  }) {
    SharedPreferencesAsyncPlatform.instance =
        storage ?? InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesFirstLaunchRepository(
      sharedPreferencesAsync: SharedPreferencesAsync(),
      errorReporter: (error, _, {reason}) => reports.add((error, reason)),
    );
  }

  testFirstLaunchRepositoryContract(() async => create());

  group('SharedPreferencesFirstLaunchRepository when storage fails', () {
    late FailingSharedPreferences storage;
    late SharedPreferencesFirstLaunchRepository repository;

    setUp(() {
      storage = FailingSharedPreferences();
      repository = create(storage: storage);
    });

    test('reports a failed read, and counts How to play as seen', () async {
      expect(await repository.hasSeenHowToPlay(), isTrue);
      expect(reports, [(storage.failure, 'reading the first launch')]);
    });

    test('reports a failed save, and carries on', () async {
      await repository.markHowToPlaySeen();

      expect(reports, [(storage.failure, 'saving the first launch')]);
    });

    test('lets a bug through, without reporting it', () async {
      final buggy = create(
        storage: FailingSharedPreferences(failure: StateError('A bug')),
      );

      await expectLater(buggy.hasSeenHowToPlay(), throwsStateError);
      expect(reports, isEmpty);
    });
  });
}
