import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Keeps the game in progress, so it survives the app closing.
///
/// Holds one game at a time, as a [GameRecord]: the config and the moves
/// played (docs/adr/0003). Every implementation passes the same contract
/// tests.
abstract interface class GameRepository {
  /// The saved game, or `null` when there is none.
  Future<GameRecord?> load();

  /// Saves [record], replacing any saved game.
  Future<void> save(GameRecord record);

  /// Forgets the saved game, if there is one.
  Future<void> clear();
}
