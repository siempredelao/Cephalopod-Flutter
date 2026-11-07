import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = TutorialStepUiMapper();
  const centre = Position(1, 1);

  /// A step whose example has Player 2 just placed on the centre.
  final step = TutorialStep(
    title: 'Take turns',
    body: 'On your turn, place one die on any empty square.',
    example: (
      game: stateFromAscii('''
        .  .  .
        .  w1 .
        .  .  .
      ''', toMove: Player.black),
      phase: const TurnPhase.awaitingPlacement(),
      lastMove: Move(centre),
    ),
  );

  group('TutorialStepUiMapper', () {
    test("keeps the step's title and body", () {
      final stepUi = mapper.map(step);

      expect(stepUi.title, step.title);
      expect(stepUi.body, step.body);
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
