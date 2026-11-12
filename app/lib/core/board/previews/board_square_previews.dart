import 'package:cephalopod/core/board/board_square.dart';
import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/board/previews/board_preview_wrapper.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

const double _squareSide = 88;
const double _spacing = 4;

@Preview(
  group: 'BoardSquare',
  name: 'Empty, every mark',
  size: Size(660, 100),
  wrapper: boardPreviewWrapper,
)
Widget emptySquaresPreview() => _everyMarkOf(null);

@Preview(
  group: 'BoardSquare',
  name: 'With a die, every mark',
  size: Size(660, 100),
  wrapper: boardPreviewWrapper,
)
Widget occupiedSquaresPreview() {
  const die = DieUi(
    pips: 3,
    owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
  );
  return _everyMarkOf(die);
}

/// One square per [SquareMark], from none to a hint's capture.
Widget _everyMarkOf(DieUi? die) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: _spacing,
    children: [
      for (final mark in SquareMark.values)
        SizedBox.square(
          dimension: _squareSide,
          child: BoardSquare(
            square: SquareUi(row: 0, col: 0, die: die, mark: mark),
            onTap: () {},
          ),
        ),
    ],
  );
}
