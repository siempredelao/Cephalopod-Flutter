import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/computer_choices_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = NewGameViewStateMapper();

  /// The computer's choices shown for [difficulty] and the [computer]'s
  /// colour.
  ComputerChoicesUi? choicesFor(Difficulty difficulty, Player computer) {
    final opponent = ComputerOpponent(difficulty: difficulty, player: computer);
    return mapper.map(opponent).computerChoices;
  }

  group('NewGameViewStateMapper', () {
    test('shows nothing more to choose against a friend', () {
      expect(
        mapper.map(const FriendOpponent()),
        const NewGameViewState(opponent: OpponentUi.friend),
      );
    });

    test('shows the computer chosen', () {
      const computer = ComputerOpponent(
        difficulty: Difficulty.medium,
        player: Player.white,
      );

      expect(mapper.map(computer).opponent, OpponentUi.computer);
    });

    test('shows every difficulty as itself', () {
      for (final difficulty in Difficulty.values) {
        final choices = choicesFor(difficulty, Player.white);

        expect(choices?.difficulty.name, difficulty.name);
      }
    });

    test('lets the person move first against White', () {
      final choices = choicesFor(Difficulty.easy, Player.white);

      expect(choices?.personMoves, PersonMovesUi.first);
    });

    test('lets the person move second against Black', () {
      final choices = choicesFor(Difficulty.easy, Player.black);

      expect(choices?.personMoves, PersonMovesUi.second);
    });
  });
}
