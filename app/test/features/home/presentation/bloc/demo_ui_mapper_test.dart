import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_ui_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = DemoUiMapper();
  const player1 = SideUi(player: PlayerUi.one, role: RoleUi.player);
  const player2 = SideUi(player: PlayerUi.two, role: RoleUi.player);

  group('DemoUiMapper', () {
    final demo = mapper.map(homeDemoScript);

    test('keeps every frame, in order, with how long it holds', () {
      expect(demo.frames.map((frame) => frame.hold), [
        for (final frame in homeDemoScript.frames) frame.hold,
      ]);
    });

    test('draws the dice as two people playing, black as Player 1', () {
      final board = demo.frames[2].board;

      expect(board.rows[1][1].die, const DieUi(pips: 6, owner: player1));
      expect(board.rows[0][1].die, const DieUi(pips: 2, owner: player2));
    });

    test("draws each frame's marks", () {
      final board = demo.frames[2].board;

      expect(board.rows[1][1].mark, SquareMark.captureTarget);
      expect(board.rows[0][1].mark, SquareMark.captureSelected);
      expect(board.rows[2][2].mark, SquareMark.none);
    });

    test('keeps the frame to stand still on', () {
      expect(demo.still, demo.frames[2]);
    });

    test('draws a 3 × 3 board in every frame', () {
      for (final frame in demo.frames) {
        expect(frame.board.rows, hasLength(3));
        expect(frame.board.rows, everyElement(hasLength(3)));
      }
    });
  });
}
