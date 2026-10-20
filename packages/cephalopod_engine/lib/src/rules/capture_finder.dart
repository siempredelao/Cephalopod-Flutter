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
  /// every subset of the occupied neighbours is checked through a bit mask.
  List<Set<Position>> optionsAt(
    Board board,
    Position target,
    GameConfig config,
  ) {
    final neighbours = [
      for (final square in _geometry.neighbours(target, board.size))
        if (board.dice.containsKey(square)) square,
    ];

    final options = <Set<Position>>[];
    for (var mask = 1; mask < 1 << neighbours.length; mask++) {
      final subset = {
        for (var i = 0; i < neighbours.length; i++)
          if ((mask >> i).isOdd) neighbours[i],
      };
      if (subset.length >= config.minCaptureDice &&
          pipSum(board, subset) <= config.maxCaptureSum) {
        options.add(subset);
      }
    }
    return options;
  }

  /// The total pips of the dice on [squares]; vacant squares count as 0.
  /// A capturing die shows this total (rule R6).
  int pipSum(Board board, Iterable<Position> squares) => squares.fold(
    0,
    (sum, square) => sum + (board.dice[square]?.pips ?? 0),
  );
}
