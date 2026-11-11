import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A `move` just played, and whether the computer played it (`byComputer`).
///
/// The bloc keeps one while the move is the last thing that changed the
/// game, and the mapper turns it into a `PlayedMoveUi`. A Dart record, so it
/// is plain data with value equality.
typedef PlayedMove = ({Move move, bool byComputer});
