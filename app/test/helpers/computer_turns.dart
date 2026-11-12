import 'dart:async';

import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A `BackgroundRunner` that runs the callback at once, on the test's own
/// isolate.
Future<R> runHere<M, R>(
  FutureOr<R> Function(M message) callback,
  M message,
) async {
  return callback(message);
}

/// An agent that always plays the first legal move, so a test knows the
/// computer's move in advance.
final class FirstMoveAgent implements GameAgent {
  FirstMoveAgent(this._moveGenerator);

  final MoveGenerator _moveGenerator;

  @override
  Move chooseMove(GameState state) => _moveGenerator.legalMoves(state).first;
}

/// An agent that always chooses [move], and keeps each position it is asked
/// about.
final class FixedMoveAgent implements GameAgent {
  FixedMoveAgent(this.move);

  final Move move;

  /// Every position [chooseMove] was asked about, in order.
  final List<GameState> positions = [];

  @override
  Move chooseMove(GameState state) {
    positions.add(state);
    return move;
  }
}
