import 'package:meta/meta.dart';

/// A square on the board, by zero-based [row] and column [col], counted from
/// the top-left corner.
@immutable
final class Position {
  /// The square at [row] and [col].
  const Position(this.row, this.col);

  /// Zero-based row, counted from the top.
  final int row;

  /// Zero-based column, counted from the left.
  final int col;

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}
