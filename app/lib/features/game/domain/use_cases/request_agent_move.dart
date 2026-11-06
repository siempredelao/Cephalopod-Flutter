import 'package:cephalopod/features/game/domain/agent_factory.dart';
import 'package:cephalopod/features/game/domain/models/current_game.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/domain/use_cases/play_move.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Plays the computer's turn: the agent for the computer's difficulty
/// chooses a move, which is then played and saved like the person's.
final class RequestAgentMove {
  RequestAgentMove({required this._agentFactory, required this._playMove});

  final AgentFactory _agentFactory;
  final PlayMove _playMove;

  /// [game] after the computer's move, already saved.
  ///
  /// Throws an [ArgumentError] when it is not the computer's turn in [game],
  /// and a [StateError] when the agent chooses an illegal move. Both are
  /// bugs, not outcomes to handle (docs/adr/0004).
  Future<CurrentGame> call(CurrentGame game) async {
    final opponent = game.opponent;
    final status = game.state.status;
    if (opponent is! ComputerOpponent ||
        status is! InProgress ||
        status.toMove != opponent.player) {
      throw ArgumentError.value(game, 'game', "It is not the computer's turn");
    }

    final agent = _agentFactory(opponent.difficulty);
    final move = agent.chooseMove(game.state);
    return switch (await _playMove(game, move)) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError('The agent chose $move: $error'),
    };
  }
}
