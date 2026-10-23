import 'package:cephalopod/features/game/domain/use_cases/resume_game.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Whether there is a saved game worth continuing: one that replays, has at
/// least one move, and is not over.
final class HasGameToContinue {
  HasGameToContinue({required this._resumeGame});

  final ResumeGame _resumeGame;

  Future<bool> call() async {
    final game = await _resumeGame();
    return game != null &&
        game.record.moves.isNotEmpty &&
        game.state.status is InProgress;
  }
}
