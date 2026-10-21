import 'package:cephalopod/features/game/presentation/view/previews/board_preview_wrapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/board_square.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

const double _squareSide = 88;
const double _spacing = 4;

@Preview(
  group: 'BoardSquare',
  name: 'Empty, every mark',
  size: Size(480, 100),
  wrapper: boardPreviewWrapper,
)
Widget emptySquaresPreview() => _everyMarkOf(null);

@Preview(
  group: 'BoardSquare',
  name: 'With a die, every mark',
  size: Size(480, 100),
  wrapper: boardPreviewWrapper,
)
Widget occupiedSquaresPreview() =>
    _everyMarkOf(const Die(owner: Player.white, pips: 3));

/// One square per [SquareMark], from none to picked for a capture.
Widget _everyMarkOf(Die? die) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: _spacing,
    children: [
      for (final mark in SquareMark.values)
        SizedBox.square(
          dimension: _squareSide,
          child: BoardSquare(
            die: die,
            mark: mark,
            label: mark.name,
            onTap: () {},
          ),
        ),
    ],
  );
}
