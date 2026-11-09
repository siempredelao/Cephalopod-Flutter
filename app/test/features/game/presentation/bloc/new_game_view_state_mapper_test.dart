import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_view_state_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = NewGameViewStateMapper();

  /// The computer shown for [difficulty] and the [computer]'s colour.
  ComputerOpponentUi computerShownFor(Difficulty difficulty, Player computer) {
    final opponent = ComputerOpponent(difficulty: difficulty, player: computer);
    return mapper.map(opponent).opponent as ComputerOpponentUi;
  }

  group('NewGameViewStateMapper', () {
    test('shows nothing more to choose against a friend', () {
      expect(
        mapper.map(const FriendOpponent()),
        const NewGameViewState(opponent: OpponentUi.friend()),
      );
    });

    test('shows the computer chosen, with its choices', () {
      const computer = ComputerOpponent(
        difficulty: Difficulty.medium,
        player: Player.white,
      );

      expect(
        mapper.map(computer),
        const NewGameViewState(
          opponent: OpponentUi.computer(
            difficulty: DifficultyUi.medium,
            personMoves: PersonMovesUi.first,
          ),
        ),
      );
    });

    test('shows every difficulty as itself', () {
      for (final difficulty in Difficulty.values) {
        final computer = computerShownFor(difficulty, Player.white);

        expect(computer.difficulty.name, difficulty.name);
      }
    });

    test('reads every difficulty back as itself', () {
      for (final difficulty in Difficulty.values) {
        final shown = computerShownFor(difficulty, Player.white).difficulty;

        expect(mapper.difficultyOf(shown), difficulty);
      }
    });

    test('reads back the colour the computer plays', () {
      for (final computer in Player.values) {
        final shown = computerShownFor(Difficulty.easy, computer).personMoves;

        expect(mapper.computerPlayerOf(shown), computer);
      }
    });

    test('lets the person move first against White', () {
      final computer = computerShownFor(Difficulty.easy, Player.white);

      expect(computer.personMoves, PersonMovesUi.first);
    });

    test('lets the person move second against Black', () {
      final computer = computerShownFor(Difficulty.easy, Player.black);

      expect(computer.personMoves, PersonMovesUi.second);
    });
  });
}
