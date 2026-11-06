import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/background_runner.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Plays the computer's turn: the agent for the computer's difficulty
/// chooses a move in the background, which is then played and saved like
/// the person's.
final class RequestAgentMove {
  RequestAgentMove({
    required this._agentFactory,
    required this._backgroundRunner,
    required this._playMove,
  });

  final AgentFactory _agentFactory;
  final BackgroundRunner _backgroundRunner;
  final PlayMove _playMove;

  /// Whether [game] is against the computer, goes on, and waits for the
  /// computer's move.
  bool isComputerTurn(CurrentGame game) {
    return switch ((game.opponent, game.state.status)) {
      (ComputerOpponent(:final player), InProgress(:final toMove)) =>
        toMove == player,
      _ => false,
    };
  }

  /// [game] after the computer's move, already saved.
  ///
  /// Throws an [ArgumentError] when it is not the computer's turn in [game],
  /// and a [StateError] when the agent chooses an illegal move. Both are
  /// bugs, not outcomes to handle (docs/adr/0004).
  Future<CurrentGame> call(CurrentGame game) async {
    final opponent = game.opponent;
    if (opponent is! ComputerOpponent || !isComputerTurn(game)) {
      throw ArgumentError.value(game, 'game', "It is not the computer's turn");
    }

    final agent = _agentFactory(opponent.difficulty);
    // A tear-off rather than a closure, so only the agent is copied to the
    // other isolate, never this use case and the repository behind it.
    final move = await _backgroundRunner(agent.chooseMove, game.state);
    return switch (await _playMove(game, move)) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError('The agent chose $move: $error'),
    };
  }
}
