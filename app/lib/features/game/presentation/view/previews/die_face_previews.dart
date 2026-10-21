import 'package:cephalopod/features/game/presentation/view/previews/board_preview_wrapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

const double _dieSide = 60;
const double _spacing = 8;

@Preview(
  group: 'DieFace',
  name: 'Player 1, 1 to 6',
  size: Size(440, 80),
  wrapper: boardPreviewWrapper,
)
Widget player1DicePreview() => _allValuesOf(Player.black);

@Preview(
  group: 'DieFace',
  name: 'Player 2, 1 to 6',
  size: Size(440, 80),
  wrapper: boardPreviewWrapper,
)
Widget player2DicePreview() => _allValuesOf(Player.white);

Widget _allValuesOf(Player owner) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: _spacing,
    children: [
      for (var pips = 1; pips <= 6; pips++)
        SizedBox.square(
          dimension: _dieSide,
          child: DieFace(
            die: Die(owner: owner, pips: pips),
          ),
        ),
    ],
  );
}
