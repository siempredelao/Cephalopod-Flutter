import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Suggests a move to the player whose turn it is: a hint. The agent that
/// plays the Hard level chooses it, in the background, as if it were
/// playing that side.
///
/// It only suggests. Nothing is played or saved; the player still makes
/// the move.
final class SuggestMove {
  SuggestMove({required this._agentFactory, required this._backgroundRunner});

  final AgentFactory _agentFactory;
  final BackgroundRunner _backgroundRunner;

  /// The level whose agent gives the hints: the strongest there is.
  static const Difficulty hintDifficulty = Difficulty.hard;

  /// The move the Hard agent would play in [game], for the side to move.
  ///
  /// Throws an [ArgumentError] when [game] is over: there is no move to
  /// suggest, so asking is a bug, not an outcome to handle
  /// (docs/adr/0004).
  Future<Move> call(CurrentGame game) async {
    if (game.state.status is! InProgress) {
      throw ArgumentError.value(game, 'game', 'The game is over');
    }

    final agent = _agentFactory(hintDifficulty);
    // A tear-off rather than a closure, so only the agent is copied to the
    // other isolate, never this use case.
    return _backgroundRunner(agent.chooseMove, game.state);
  }
}
