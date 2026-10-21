import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/die.dart';
import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/game_state.dart';
import 'package:cephalopod_engine/src/model/player.dart';
import 'package:cephalopod_engine/src/model/position.dart';
import 'package:cephalopod_engine/src/rules/referee.dart';

/// Builds a [Board] from a text grid, the format [boardToAscii] prints.
///
/// One row per line, squares separated by spaces: `.` is a vacant square,
/// `b3` a black die showing 3 and `w1` a white die showing 1. Blank lines and
/// indentation are ignored.
///
/// Throws a [FormatException] when the grid is empty, not square, or has a
/// square it does not understand.
Board boardFromAscii(String grid) {
  final rows = [
    for (final line in grid.split('\n'))
      if (line.trim().isNotEmpty) line.trim().split(RegExp(r'\s+')),
  ];
  if (rows.isEmpty) throw FormatException('The grid is empty', grid);

  final dice = <Position, Die>{};
  for (final (row, squares) in rows.indexed) {
    if (squares.length != rows.length) {
      throw FormatException(
        'Row $row has ${squares.length} squares; expected ${rows.length}',
        grid,
      );
    }
    for (final (col, square) in squares.indexed) {
      final die = _parseSquare(square);
      if (die != null) dice[Position(row, col)] = die;
    }
  }
  return Board(size: rows.length, dice: dice);
}

/// Prints [board] as a text grid, one row per line, that [boardFromAscii]
/// reads back.
String boardToAscii(Board board) => [
  for (var row = 0; row < board.size; row++)
    [
      for (var col = 0; col < board.size; col++)
        '${board.dice[Position(row, col)] ?? '.'}'.padRight(2),
    ].join(' ').trimRight(),
].join('\n');

/// Builds a [GameState] from a text grid (see [boardFromAscii]) with [toMove]
/// to play. The status comes from [referee], as in a real game.
///
/// Uses [config] when given, otherwise the standard rules on a board the size
/// of the grid.
GameState stateFromAscii(
  String grid, {
  required Player toMove,
  GameConfig? config,
  Referee? referee,
}) {
  final board = boardFromAscii(grid);
  return GameState(
    board: board,
    status: (referee ?? Referee()).statusOf(board, toMove),
    config: config ?? GameConfig(boardSize: board.size),
  );
}

final RegExp _diePattern = RegExp(r'^([bw])([1-6])$');

Die? _parseSquare(String square) {
  if (square == '.') return null;
  final match = _diePattern.firstMatch(square);
  if (match == null) {
    throw FormatException('Unknown square "$square"; use ".", b1–b6 or w1–w6');
  }
  return Die(
    owner: match.group(1) == 'b' ? Player.black : Player.white,
    pips: int.parse(match.group(2)!),
  );
}
