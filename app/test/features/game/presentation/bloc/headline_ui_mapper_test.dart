import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/headline_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = HeadlineUiMapper();
  const friend = FriendOpponent();
  // The computer plays White, so the person plays Black.
  const computer = ComputerOpponent(
    difficulty: Difficulty.easy,
    player: Player.white,
  );
  const blackWins = Finished(
    winner: Player.black,
    blackDice: 13,
    whiteDice: 12,
  );
  const whiteWins = Finished(
    winner: Player.white,
    blackDice: 11,
    whiteDice: 14,
  );

  group('HeadlineUiMapper', () {
    test('names the player to move between two people', () {
      expect(
        mapper.map(const InProgress(Player.black), friend),
        const HeadlineUi.playerToMove(PlayerUi.one),
      );
      expect(
        mapper.map(const InProgress(Player.white), friend),
        const HeadlineUi.playerToMove(PlayerUi.two),
      );
    });

    test('the person is to move against the computer', () {
      expect(
        mapper.map(const InProgress(Player.black), computer),
        const HeadlineUi.personToMove(),
      );
    });

    test('the computer is to move on its turn', () {
      expect(
        mapper.map(const InProgress(Player.white), computer),
        const HeadlineUi.computerToMove(),
      );
    });

    test('R8: names the winner, with their dice first', () {
      expect(
        mapper.map(blackWins, friend),
        const HeadlineUi.playerWon(
          player: PlayerUi.one,
          winnerDice: 13,
          loserDice: 12,
        ),
      );
      expect(
        mapper.map(whiteWins, friend),
        const HeadlineUi.playerWon(
          player: PlayerUi.two,
          winnerDice: 14,
          loserDice: 11,
        ),
      );
    });

    test('R8: tells the person winning from the computer winning', () {
      expect(
        mapper.map(blackWins, computer),
        const HeadlineUi.personWon(winnerDice: 13, loserDice: 12),
      );
      expect(
        mapper.map(whiteWins, computer),
        const HeadlineUi.computerWon(winnerDice: 14, loserDice: 11),
      );
    });
  });
}
