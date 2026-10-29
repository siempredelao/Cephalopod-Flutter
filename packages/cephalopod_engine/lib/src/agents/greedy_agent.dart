import 'dart:math';

import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/play_listed_move.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';

/// The Medium opponent: plays the move that leaves the best position, as the
/// [PositionEvaluator] scores it, and picks at random among equally good
/// moves.
///
/// It looks one move ahead and no further, so it never sees the reply: it
/// takes every profitable capture and builds dice that cannot be captured,
/// but it can leave dice for the opponent to capture next turn.
final class GreedyAgent implements GameAgent {
  /// An agent that asks `moves` for the legal moves and what they lead to,
  /// scores each result with `evaluator`, and breaks ties with `random`.
  GreedyAgent({
    required this._moves,
    required this._evaluator,
    required this._random,
  });

  final MoveGenerator _moves;
  final PositionEvaluator _evaluator;
  final Random _random;

  @override
  Move chooseMove(GameState state) {
    final status = state.status;
    if (status is! InProgress) {
      throw ArgumentError.value(state, 'state', 'The game is over');
    }
    int? bestScore;
    var best = <Move>[];
    for (final move in _moves.legalMoves(state)) {
      final next = _moves.playListed(state, move);
      final score = _evaluator.score(next, status.toMove);
      if (bestScore == null || score > bestScore) {
        bestScore = score;
        best = [move];
      } else if (score == bestScore) {
        best.add(move);
      }
    }
    return best[_random.nextInt(best.length)];
  }
}
