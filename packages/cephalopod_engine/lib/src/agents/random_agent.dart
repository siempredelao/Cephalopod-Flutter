import 'dart:math';

import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';

/// The Easy opponent: plays any legal move, each as likely as the next.
///
/// It never looks at the board, so it misses captures and leaves easy ones
/// for its opponent. That makes it a fair first opponent and a baseline the
/// stronger agents must beat.
final class RandomAgent implements GameAgent {
  /// An agent that asks `moves` for the legal moves and picks one with
  /// `random`. Seed `random` for repeatable games.
  RandomAgent({required this._moves, required this._random});

  final MoveGenerator _moves;
  final Random _random;

  @override
  Move chooseMove(GameState state) {
    if (state.status is! InProgress) {
      throw ArgumentError.value(state, 'state', 'The game is over');
    }
    final legal = _moves.legalMoves(state);
    return legal[_random.nextInt(legal.length)];
  }
}
