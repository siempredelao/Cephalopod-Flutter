import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod/features/game/domain/models/saved_game.dart';

/// A [GameRepository] that keeps the game in memory only, so it is lost
/// when the app closes. For tests, and as the reference the contract tests
/// hold other implementations to.
final class InMemoryGameRepository implements GameRepository {
  SavedGame? _savedGame;

  @override
  Future<SavedGame?> load() async => _savedGame;

  @override
  Future<void> save(SavedGame savedGame) async {
    _savedGame = savedGame;
  }

  @override
  Future<void> clear() async {
    _savedGame = null;
  }
}
