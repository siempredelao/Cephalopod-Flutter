import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Chooses the computer's move: the agent for the computer's difficulty
/// thinks in the background.
///
/// It only chooses. The caller plays the move with `PlayMove`, which saves
/// it, after checking that it still wants the move: the screen may have
/// closed while the computer thought, and a newer game may be saved by then.
final class ChooseAgentMove {
  ChooseAgentMove({
    required this._agentFactory,
    required this._backgroundRunner,
  });

  final AgentFactory _agentFactory;
  final BackgroundRunner _backgroundRunner;

  /// Whether [game] is against the computer, goes on, and waits for the
  /// computer's move.
  bool isComputerTurn(CurrentGame game) {
    return switch ((game.opponent, game.state.status)) {
      (ComputerOpponent(:final player), InProgress(:final toMove)) =>
        toMove == player,
      _ => false,
    };
  }

  /// The move the computer chooses in [game].
  ///
  /// Throws an [ArgumentError] when it is not the computer's turn in [game]:
  /// asking then is a bug, not an outcome to handle (docs/adr/0004).
  Future<Move> call(CurrentGame game) async {
    final opponent = game.opponent;
    if (opponent is! ComputerOpponent || !isComputerTurn(game)) {
      throw ArgumentError.value(game, 'game', "It is not the computer's turn");
    }

    final agent = _agentFactory(opponent.difficulty);
    // A tear-off rather than a closure, so only the agent is copied to the
    // other isolate, never this use case.
    return _backgroundRunner(agent.chooseMove, game.state);
  }
}
