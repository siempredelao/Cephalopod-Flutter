import 'package:cephalopod/features/game/data/saved_game_json_codec.dart';
import 'package:cephalopod/features/game/data/shared_preferences_game_repository.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/failing_shared_preferences.dart';
import 'game_repository_contract.dart';

void main() {
  late List<(Object, String?)> reports;

  setUp(() => reports = []);

  /// A repository on [storage]: fresh, empty in-memory preferences unless
  /// the test says otherwise.
  SharedPreferencesGameRepository create({
    SharedPreferencesAsyncPlatform? storage,
  }) {
    SharedPreferencesAsyncPlatform.instance =
        storage ?? InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesGameRepository(
      sharedPreferencesAsync: SharedPreferencesAsync(),
      savedGameJsonCodec: SavedGameJsonCodec(),
      errorReporter: (error, _, {reason}) => reports.add((error, reason)),
    );
  }

  testGameRepositoryContract(() async => create());

  group('SharedPreferencesGameRepository', () {
    test('has no game when the save cannot be read', () async {
      final repository = create();
      await SharedPreferencesAsync().setString('game', 'not json');

      expect(await repository.load(), isNull);
      expect(reports, isEmpty);
    });
  });

  group('SharedPreferencesGameRepository when storage fails', () {
    final savedGame = (
      record: GameRecord(moves: [Move(const Position(2, 2))]),
      opponent: const FriendOpponent(),
    );
    late FailingSharedPreferences storage;
    late SharedPreferencesGameRepository repository;

    setUp(() {
      storage = FailingSharedPreferences();
      repository = create(storage: storage);
    });

    test('reports a failed load, and gives no game', () async {
      expect(await repository.load(), isNull);
      expect(reports, [(storage.failure, 'loading the saved game')]);
    });

    test('reports a failed save, and carries on', () async {
      await repository.save(savedGame);

      expect(reports, [(storage.failure, 'saving the game')]);
    });

    test('reports a failed clear, and carries on', () async {
      await repository.clear();

      expect(reports, [(storage.failure, 'clearing the saved game')]);
    });

    test('lets a bug through, without reporting it', () async {
      final buggy = create(
        storage: FailingSharedPreferences(failure: StateError('A bug')),
      );

      await expectLater(buggy.save(savedGame), throwsStateError);
      expect(reports, isEmpty);
    });
  });
}
