import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A `move` just played, whether the computer played it (`byComputer`), and
/// the dice it `captured`, where they were. Those are gone from the board
/// once the move is played, so the bloc takes them from the board before
/// it.
///
/// The bloc keeps one while the move is the last thing that changed the
/// game, and the mapper turns it into a `PlayedMoveUi`. A Dart record:
/// plain data, which compares field by field (the map by identity).
typedef PlayedMove = ({
  Move move,
  bool byComputer,
  Map<Position, Die> captured,
});
