import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_cubit.dart';
import 'package:cephalopod/features/game/presentation/bloc/opponent_query_codec.dart';
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
      expect(
        cubit.state,
        const NewGameViewState(opponent: OpponentUi.friend()),
      );
      expect(chosenOpponent(), const FriendOpponent());
    });

    test('offers the Medium computer, with the person moving first', () {
      cubit.chooseComputer();

      expect(
        cubit.state,
        const NewGameViewState(
          opponent: OpponentUi.computer(
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
        ..chooseComputer()
        ..chooseDifficulty(DifficultyUi.hard)
        ..choosePersonMoves(PersonMovesUi.second);

      expect(
        cubit.state.opponent,
        const OpponentUi.computer(
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
          ..chooseComputer()
          ..chooseDifficulty(difficulty);

        final opponentUi = cubit.state.opponent as ComputerOpponentUi;
        final opponent = chosenOpponent() as ComputerOpponent;
        expect(opponentUi.difficulty, difficulty);
        expect(opponent.difficulty.name, difficulty.name);
      }
    });

    test('keeps the computer chosen while a friend is picked', () {
      cubit
        ..chooseComputer()
        ..chooseDifficulty(DifficultyUi.easy)
        ..chooseFriend();
      expect(cubit.state.opponent, const OpponentUi.friend());
      expect(chosenOpponent(), const FriendOpponent());

      cubit.chooseComputer();

      final opponentUi = cubit.state.opponent as ComputerOpponentUi;
      expect(opponentUi.difficulty, DifficultyUi.easy);
    });
  });
}
