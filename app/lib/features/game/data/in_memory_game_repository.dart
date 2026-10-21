import 'package:cephalopod/features/game/domain/game_repository.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A [GameRepository] that keeps the game in memory only, so it is lost
/// when the app closes. For tests, and as the reference the contract tests
/// hold other implementations to.
final class InMemoryGameRepository implements GameRepository {
  GameRecord? _record;

  @override
  Future<GameRecord?> load() async => _record;

  @override
  Future<void> save(GameRecord record) async {
    _record = record;
  }

  @override
  Future<void> clear() async {
    _record = null;
  }
}
