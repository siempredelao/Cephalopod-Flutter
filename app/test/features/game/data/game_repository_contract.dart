import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// What every [GameRepository] must do. Each implementation's test calls
/// this with a way to create a fresh, empty repository, so they can all be
/// swapped for one another.
void testGameRepositoryContract(Future<GameRepository> Function() create) {
  group('GameRepository contract', () {
    const center = Position(2, 2);
    const top = Position(0, 2);
    final record = GameRecord(moves: [Move(center), Move(top)]);
    final savedGame = (record: record, opponent: const FriendOpponent());
    late GameRepository repository;

    setUp(() async => repository = await create());

    test('has no game before one is saved', () async {
      expect(await repository.load(), isNull);
    });

    test('gives back the saved game', () async {
      await repository.save(savedGame);

      expect(await repository.load(), savedGame);
    });

    test('gives back the opponent it was saved with', () async {
      const computer = ComputerOpponent(
        difficulty: Difficulty.medium,
        player: Player.black,
      );
      final againstComputer = (record: record, opponent: computer);
      await repository.save(againstComputer);

      expect(await repository.load(), againstComputer);
    });

    test('keeps only the latest save', () async {
      const config = GameConfig(boardSize: 3);
      final other = (
        record: GameRecord(config: config),
        opponent: const FriendOpponent(),
      );
      await repository.save(savedGame);

      await repository.save(other);

      expect(await repository.load(), other);
    });

    test('forgets the game when cleared', () async {
      await repository.save(savedGame);

      await repository.clear();

      expect(await repository.load(), isNull);
    });

    test('can be cleared when it has no game', () async {
      await repository.clear();

      expect(await repository.load(), isNull);
    });
  });
}
