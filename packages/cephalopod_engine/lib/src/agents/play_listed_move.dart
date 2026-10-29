import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/result.dart';

/// How agents play a move they took from [MoveGenerator.legalMoves].
extension PlayListedMove on MoveGenerator {
  /// The position after [move], one of the legal moves in [state].
  ///
  /// Throws a [StateError] when the rules refuse it: they listed it as
  /// legal, so a refusal is a bug in the rules, not a case to handle
  /// (docs/adr/0004).
  GameState playListed(GameState state, Move move) {
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
