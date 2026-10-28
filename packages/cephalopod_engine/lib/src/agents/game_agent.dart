import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/move.dart';

/// A player that chooses its own moves: a computer opponent.
///
/// Each difficulty level is one implementation. Every agent passes the same
/// contract tests: it plays only legal moves, chooses the same moves again
/// when given the same seed, and refuses a finished game (docs/adr/0014).
// A named interface, not the function type the lint suggests: an
// agent is an agent because it says so with `implements`, not because its
// signature happens to match, and the contract above lives on its type.
// ignore: one_member_abstracts
abstract interface class GameAgent {
  /// The move to play in [state], one of its legal moves, for the player
  /// whose turn it is.
  ///
  /// Throws an [ArgumentError] when [state] is a finished game: asking for a
  /// move then is a bug in the caller, not a case to handle
  /// (docs/adr/0004).
  Move chooseMove(GameState state);
}
