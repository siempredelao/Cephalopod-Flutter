import 'package:cephalopod_engine/src/rules/illegal_move.dart';

/// Why a game record could not be replayed, for example because a saved
/// game was corrupted.
sealed class ReplayFailure {}

/// The record's config breaks the rules, so no game can start from it.
final class InvalidConfig extends ReplayFailure {
  /// The config breaks the rule described by [reason].
  InvalidConfig(this.reason);

  /// Which value is wrong, and why.
  final ArgumentError reason;
}

/// The move at [index] cannot be played in the position the moves before it
/// reach.
final class IllegalMoveAt extends ReplayFailure {
  /// The move at [index] is refused for [reason].
  IllegalMoveAt(this.index, this.reason);

  /// Where the refused move is in the record, counting from 0.
  final int index;

  /// The rule the move breaks.
  final IllegalMove reason;
}
