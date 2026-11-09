import 'package:cephalopod/features/game/data/in_memory_game_repository.dart';
import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';

/// A [GameRepository] in memory that counts how many times it [saves], so a
/// test can check that a step saves once.
final class CountingGameRepository implements GameRepository {
  final InMemoryGameRepository _games = InMemoryGameRepository();

  /// How many times [save] has been called.
  int saves = 0;

  @override
  Future<SavedGame?> load() => _games.load();

  @override
  Future<void> save(SavedGame savedGame) {
    saves++;
    return _games.save(savedGame);
  }

  @override
  Future<void> clear() => _games.clear();
}
