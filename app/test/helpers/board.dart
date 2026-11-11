import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dice drawn on the board, and only there: the dice count above the
/// board draws a small die for each side too.
Finder get diceOnBoard => find.descendant(
  of: find.byType(GameBoard),
  matching: find.byType(DieFace),
);
