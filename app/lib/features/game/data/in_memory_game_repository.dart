import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A [GameRepository] that keeps the game in memory only, so it is lost
/// when the app closes. For tests, and as the reference the contract tests
/// hold other implementations to.
final class InMemoryGameRepository implements GameRepository {
  GameRecord? _gameRecord;

  @override
  Future<GameRecord?> load() async => _gameRecord;

  @override
  Future<void> save(GameRecord record) async {
    _gameRecord = record;
  }

  @override
  Future<void> clear() async {
    _gameRecord = null;
  }
}
