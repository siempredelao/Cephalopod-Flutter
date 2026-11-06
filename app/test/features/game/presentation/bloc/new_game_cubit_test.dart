import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/new_game_cubit.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewGameCubit', () {
    late NewGameCubit cubit;

    setUp(() {
      cubit = NewGameCubit();
      addTearDown(cubit.close);
    });

    test('starts on a friend', () {
      expect(cubit.opponent, const FriendOpponent());
    });

    test('offers the Medium computer, with the person moving first', () {
      cubit.chooseComputer();

      expect(
        cubit.opponent,
        const ComputerOpponent(
          difficulty: Difficulty.medium,
          player: Player.white,
        ),
      );
    });

    test('plays the computer with the difficulty and colour chosen', () {
      cubit
        ..chooseComputer()
        ..chooseDifficulty(Difficulty.hard)
        ..chooseComputerPlayer(Player.black);

      expect(
        cubit.opponent,
        const ComputerOpponent(
          difficulty: Difficulty.hard,
          player: Player.black,
        ),
      );
    });

    test('keeps the computer chosen while a friend is picked', () {
      cubit
        ..chooseComputer()
        ..chooseDifficulty(Difficulty.easy)
        ..chooseFriend();
      expect(cubit.opponent, const FriendOpponent());

      cubit.chooseComputer();

      expect(cubit.state.computer.difficulty, Difficulty.easy);
    });
  });
}
