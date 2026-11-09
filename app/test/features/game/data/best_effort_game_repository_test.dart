import 'package:cephalopod/features/game/data/best_effort_game_repository.dart';
import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/failing_game_repository.dart';
import 'game_repository_contract.dart';

void main() {
  // While storage works, it behaves like any other repository.
  testGameRepositoryContract(
    () async => BestEffortGameRepository(
      gameRepository: InMemoryGameRepository(),
      errorReporter: (_, _, {reason}) => fail('Reported an error: $reason'),
    ),
  );

  group('BestEffortGameRepository when storage fails', () {
    final savedGame = (
      record: GameRecord(moves: [Move(const Position(2, 2))]),
      opponent: const FriendOpponent(),
    );
    late List<(Object, String?)> reports;

    setUp(() => reports = []);

    GameRepository wrap(GameRepository gameRepository) {
      return BestEffortGameRepository(
        gameRepository: gameRepository,
        errorReporter: (error, _, {reason}) => reports.add((error, reason)),
      );
    }

    test('reports a failed load, and gives no game', () async {
      final failure = Exception('Storage is unreadable');
      final repository = wrap(FailingGameRepository(failure));

      expect(await repository.load(), isNull);
      expect(reports, [(failure, 'loading the saved game')]);
    });

    test('reports a failed save, and carries on', () async {
      final failure = Exception('Storage is full');
      final repository = wrap(FailingGameRepository(failure));

      await repository.save(savedGame);

      expect(reports, [(failure, 'saving the game')]);
    });

    test('reports a failed clear, and carries on', () async {
      final failure = Exception('Storage is read-only');
      final repository = wrap(FailingGameRepository(failure));

      await repository.clear();

      expect(reports, [(failure, 'clearing the saved game')]);
    });

    test('lets a bug through, without reporting it', () async {
      final repository = wrap(FailingGameRepository(StateError('A bug')));

      await expectLater(repository.save(savedGame), throwsStateError);
      expect(reports, isEmpty);
    });
  });
}
