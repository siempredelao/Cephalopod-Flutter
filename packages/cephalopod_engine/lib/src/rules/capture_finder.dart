import 'package:cephalopod_engine/src/model/board.dart';
import 'package:cephalopod_engine/src/model/game_config.dart';
import 'package:cephalopod_engine/src/model/position.dart';
import 'package:cephalopod_engine/src/rules/board_geometry.dart';

/// Finds the captures available to a die placed on a square (rule R4).
final class CaptureFinder {
  final BoardGeometry _geometry = BoardGeometry();

  /// Every set of dice that a die placed on [target] could capture: 2 or more
  /// orthogonal neighbours whose pips add up to at most
  /// [GameConfig.maxCaptureSum]. The colour of the dice does not matter.
  ///
  /// A square has at most 4 neighbours, so there are at most 11 such sets:
  /// 6 pairs, 4 triples and 1 set of all four.
  List<Set<Position>> optionsAt(
    Board board,
    Position target,
    GameConfig config,
  ) {
    final neighbours = [
      for (final square in _geometry.neighbours(target, board.size))
        if (board.dice.containsKey(square)) square,
    ];

    return [
      for (final subset in _subsetsOf(neighbours))
        if (_canCapture(board, subset, config)) subset,
    ];
  }

  bool _canCapture(Board board, Set<Position> dice, GameConfig config) =>
      dice.length >= config.minCaptureDice &&
      pipSum(board, dice) <= config.maxCaptureSum;

  /// The total pips of the dice on [squares]; vacant squares count as 0.
  /// A capturing die shows this total (rule R6).
  int pipSum(Board board, Iterable<Position> squares) => squares.fold(
    0,
    (sum, square) => sum + (board.dice[square]?.pips ?? 0),
  );
}

/// Every subset of [items], from the empty set to all of them: 2ⁿ sets for
/// n items. Each item doubles the list, because every subset found so far
/// appears once without the item and once with it.
List<Set<T>> _subsetsOf<T>(List<T> items) {
  var subsets = [<T>{}];
  for (final item in items) {
    subsets = [
      for (final subset in subsets) ...[
        subset,
        {...subset, item},
      ],
    ];
  }
  return subsets;
}
