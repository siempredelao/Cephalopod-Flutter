import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/result.dart';
import 'package:cephalopod_engine/src/rules/illegal_move.dart';

/// What an agent needs from the rules: the legal moves in a position and the
/// position a move leads to.
///
/// `CephalopodRules` implements it. Agents depend on this narrow interface
/// rather than on the whole rules, so they cannot start or replay games, and
/// what they rely on is visible in one place (docs/adr/0014).
abstract interface class MoveGenerator {
  /// Every legal move in [state]; empty once the game is over.
  List<Move> legalMoves(GameState state);

  /// Plays [move] in [state]: the next state, or the reason the move is
  /// illegal.
  Result<GameState, IllegalMove> apply(GameState state, Move move);
}
