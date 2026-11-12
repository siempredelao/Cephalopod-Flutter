import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = TutorialStepUiMapper();
  const centre = Position(1, 1);

  /// A step whose example has Player 2 just placed on the centre.
  final step = TutorialStep(
    topic: TutorialTopic.takeTurns,
    example: (
      game: stateFromAscii('''
        .  .  .
        .  w1 .
        .  .  .
      ''', toMove: Player.black),
      marks: {centre: SquareMark.lastMove},
    ),
  );

  group('TutorialStepUiMapper', () {
    test("keeps the step's topic", () {
      expect(mapper.map(step).topic, TutorialTopic.takeTurns);
    });

    test('draws the example between two people, last move marked', () {
      final square = mapper.map(step).board.rows[1][1];

      expect(square.mark, SquareMark.lastMove);
      expect(
        square.die,
        const DieUi(
          pips: 1,
          owner: SideUi(player: PlayerUi.two, role: RoleUi.player),
        ),
      );
    });
  });
}
