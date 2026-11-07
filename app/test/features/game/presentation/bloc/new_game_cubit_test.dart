import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_cubit.dart';
import 'package:cephalopod/features/game/presentation/bloc/opponent_query_codec.dart';
import 'package:cephalopod/features/game/presentation/models/computer_choices_ui.dart';
import 'package:cephalopod/features/game/presentation/models/difficulty_ui.dart';
import 'package:cephalopod/features/game/presentation/models/new_game_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/opponent_ui.dart';
import 'package:cephalopod/features/game/presentation/models/person_moves_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewGameCubit', () {
    late NewGameCubit cubit;

    setUp(() {
      cubit = NewGameCubit();
      addTearDown(cubit.close);
    });

    /// The opponent of the game the dialog would open.
    Opponent chosenOpponent() {
      return const OpponentQueryCodec().decode(cubit.gameQueryParameters);
    }

    test('starts on a friend, with nothing more to choose', () {
      expect(cubit.state, const NewGameViewState(opponent: OpponentUi.friend));
      expect(chosenOpponent(), const FriendOpponent());
    });

    test('offers the Medium computer, with the person moving first', () {
      cubit.chooseOpponent(OpponentUi.computer);

      expect(
        cubit.state,
        const NewGameViewState(
          opponent: OpponentUi.computer,
          computerChoices: ComputerChoicesUi(
            difficulty: DifficultyUi.medium,
            personMoves: PersonMovesUi.first,
          ),
        ),
      );
      expect(
        chosenOpponent(),
        const ComputerOpponent(
          difficulty: Difficulty.medium,
          player: Player.white,
        ),
      );
    });

    test('plays the computer with the difficulty and turn chosen', () {
      cubit
        ..chooseOpponent(OpponentUi.computer)
        ..chooseDifficulty(DifficultyUi.hard)
        ..choosePersonMoves(PersonMovesUi.second);

      expect(
        cubit.state.computerChoices,
        const ComputerChoicesUi(
          difficulty: DifficultyUi.hard,
          personMoves: PersonMovesUi.second,
        ),
      );
      expect(
        chosenOpponent(),
        const ComputerOpponent(
          difficulty: Difficulty.hard,
          player: Player.black,
        ),
      );
    });

    test('offers every difficulty', () {
      for (final difficulty in DifficultyUi.values) {
        cubit
          ..chooseOpponent(OpponentUi.computer)
          ..chooseDifficulty(difficulty);

        final opponent = chosenOpponent() as ComputerOpponent;
        expect(cubit.state.computerChoices?.difficulty, difficulty);
        expect(opponent.difficulty.name, difficulty.name);
      }
    });

    test('keeps the computer chosen while a friend is picked', () {
      cubit
        ..chooseOpponent(OpponentUi.computer)
        ..chooseDifficulty(DifficultyUi.easy)
        ..chooseOpponent(OpponentUi.friend);
      expect(cubit.state.computerChoices, isNull);
      expect(chosenOpponent(), const FriendOpponent());

      cubit.chooseOpponent(OpponentUi.computer);

      expect(cubit.state.computerChoices?.difficulty, DifficultyUi.easy);
    });
  });
}
