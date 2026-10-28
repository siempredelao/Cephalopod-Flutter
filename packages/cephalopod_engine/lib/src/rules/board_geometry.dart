import 'package:cephalopod_engine/src/models/position.dart';

/// The shape of the board: which squares exist and which touch (rule R3).
final class BoardGeometry {
  /// Every square of a [boardSize] × [boardSize] board, in row-major order.
  List<Position> squares(int boardSize) => [
    for (var row = 0; row < boardSize; row++)
      for (var col = 0; col < boardSize; col++) Position(row, col),
  ];

  /// Whether [position] lies on a [boardSize] × [boardSize] board.
  bool contains(Position position, int boardSize) =>
      position.row >= 0 &&
      position.row < boardSize &&
      position.col >= 0 &&
      position.col < boardSize;

  /// The squares orthogonally adjacent to [position] on a [boardSize] ×
  /// [boardSize] board: 2 in a corner, 3 on an edge, 4 inside.
  List<Position> neighbours(Position position, int boardSize) {
    final Position(:row, :col) = position;
    final candidates = [
      Position(row - 1, col),
      Position(row, col - 1),
      Position(row, col + 1),
      Position(row + 1, col),
    ];
    return [
      for (final candidate in candidates)
        if (contains(candidate, boardSize)) candidate,
    ];
  }
}
