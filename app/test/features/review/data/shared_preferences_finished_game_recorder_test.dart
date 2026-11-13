import 'package:cephalopod/features/review/data/shared_preferences_finished_game_recorder.dart';
import 'package:cephalopod/features/review/domain/finished_game_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/failing_shared_preferences.dart';
import 'finished_game_recorder_contract.dart';

void main() {
  late List<(Object, String?)> reports;

  setUp(() => reports = []);

  /// A recorder on [storage]: fresh, empty in-memory preferences unless the
  /// test says otherwise.
  FinishedGameRecorder create({SharedPreferencesAsyncPlatform? storage}) {
    SharedPreferencesAsyncPlatform.instance =
        storage ?? InMemorySharedPreferencesAsync.empty();
    return sharedPreferencesFinishedGameRecorder(
      sharedPreferencesAsync: SharedPreferencesAsync(),
      errorReporter: (error, _, {reason}) => reports.add((error, reason)),
    );
  }

  testFinishedGameRecorderContract(() async => create());

  test('keeps the count for the next time the app opens', () async {
    final storage = InMemorySharedPreferencesAsync.empty();
    await create(storage: storage)();
    await create(storage: storage)();

    expect(await create(storage: storage)(), 3);
  });

  group('sharedPreferencesFinishedGameRecorder when storage fails', () {
    test('reports the failure, and answers 0, never a time to ask', () async {
      final storage = FailingSharedPreferences();

      expect(await create(storage: storage)(), 0);
      expect(reports, [(storage.failure, 'counting a finished game')]);
    });

    test('lets a bug through, without reporting it', () async {
      final buggy = create(
        storage: FailingSharedPreferences(failure: StateError('A bug')),
      );

      await expectLater(buggy(), throwsStateError);
      expect(reports, isEmpty);
    });
  });
}
