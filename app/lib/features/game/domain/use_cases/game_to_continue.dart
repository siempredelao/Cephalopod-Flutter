import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// The saved game worth continuing: one that replays, has at least one
/// move, and is not over.
final class GameToContinue {
  GameToContinue({required this._resumeGame});

  final ResumeGame _resumeGame;

  /// The game to continue; `null` when there is none.
  Future<CurrentGame?> call() async {
    final game = await _resumeGame();
    if (game == null) return null;
    final worthContinuing =
        game.record.moves.isNotEmpty && game.state.status is InProgress;
    return worthContinuing ? game : null;
  }
}
