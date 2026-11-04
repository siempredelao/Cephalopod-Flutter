import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/result.dart';

/// How agents play a move the rules have already told them is legal.
extension ApplyLegalMove on MoveGenerator {
  /// The position after [move], which must be one of
  /// [MoveGenerator.legalMoves] for [state].
  ///
  /// [MoveGenerator.apply] returns a `Result` because a move can be illegal.
  /// An agent only plays moves from that list, so here a refusal means the
  /// rules contradict themselves. That is a bug, not a case to handle, so this
  /// throws a [StateError] instead (docs/adr/0004).
  GameState applyLegal(GameState state, Move move) {
    switch (apply(state, move)) {
      case Ok(:final value):
        return value;
      case Err(:final error):
        throw StateError(
          'The rules listed $move as legal but refused it: $error',
        );
    }
  }
}
