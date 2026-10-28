import 'package:cephalopod_engine/src/models/position.dart';

/// Why a move was refused. Each case points to the rule it breaks.
sealed class IllegalMove {}

/// The board is full, so no more dice can be placed (rule R8).
final class GameOver extends IllegalMove {}

/// The target square is not on the board.
final class OutsideBoard extends IllegalMove {
  /// The move targeted [position], which is off the board.
  OutsideBoard(this.position);

  /// The square the move targeted.
  final Position position;
}

/// The target square already holds a die (rule R2).
final class SquareOccupied extends IllegalMove {
  /// The move targeted [position], which already holds a die.
  SquareOccupied(this.position);

  /// The square the move targeted.
  final Position position;
}

/// A capture is possible from the target square, so the move must make one
/// of the [options] (rule R5).
final class CaptureRequired extends IllegalMove {
  /// The move captured nothing although [options] were available.
  CaptureRequired(this.options);

  /// Every set of dice the move could have captured.
  final List<Set<Position>> options;
}

/// The chosen [captures] are not a legal capture from the target square: not
/// 2 or more adjacent dice whose pips sum to 6 or less (rule R4).
final class InvalidCapture extends IllegalMove {
  /// The move tried to capture [captures].
  InvalidCapture(this.captures);

  /// The squares the move tried to capture.
  final Set<Position> captures;
}
