import 'package:cephalopod/features/game/domain/game_repository.dart';
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
    late GameRepository repository;

    setUp(() async => repository = await create());

    test('has no game before one is saved', () async {
      expect(await repository.load(), isNull);
    });

    test('gives back the saved game', () async {
      await repository.save(record);

      expect(await repository.load(), record);
    });

    test('keeps only the latest save', () async {
      const config = GameConfig(boardSize: 3);
      final other = GameRecord(config: config);
      await repository.save(record);

      await repository.save(other);

      expect(await repository.load(), other);
    });

    test('forgets the game when cleared', () async {
      await repository.save(record);

      await repository.clear();

      expect(await repository.load(), isNull);
    });

    test('can be cleared when it has no game', () async {
      await repository.clear();

      expect(await repository.load(), isNull);
    });
  });
}
