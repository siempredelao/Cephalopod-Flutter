import 'package:cephalopod/features/game/domain/models/saved_game.dart';

/// Keeps the game in progress, so it survives the app closing.
///
/// Holds one game at a time, as a [SavedGame]: the config and the moves
/// played (docs/adr/0003), and the opponent. Every implementation passes the
/// same contract tests.
abstract interface class GameRepository {
  /// The saved game, or `null` when there is none.
  Future<SavedGame?> load();

  /// Saves [savedGame], replacing any saved game.
  Future<void> save(SavedGame savedGame);

  /// Forgets the saved game, if there is one.
  Future<void> clear();
}
