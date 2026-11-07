import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/view/headline_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = HeadlineTextMapper();

  group('HeadlineTextMapper', () {
    test('names the player to move between two people', () {
      expect(
        mapper.map(const HeadlineUi.playerToMove(PlayerUi.two)),
        'Player 2 to move',
      );
    });

    test('tells the person it is their turn', () {
      expect(mapper.map(const HeadlineUi.personToMove()), 'Your turn');
    });

    test('says the computer is thinking on its turn', () {
      expect(
        mapper.map(const HeadlineUi.computerToMove()),
        'The computer is thinking…',
      );
    });

    test('R8: names the winner between two people, their dice first', () {
      const headline = HeadlineUi.playerWon(
        player: PlayerUi.one,
        winnerDice: 13,
        loserDice: 12,
      );

      expect(mapper.map(headline), 'Player 1 wins 13 to 12');
    });

    test('R8: tells the person they won, their dice first', () {
      const headline = HeadlineUi.personWon(winnerDice: 14, loserDice: 11);

      expect(mapper.map(headline), 'You win 14 to 11');
    });

    test("R8: says the computer won, the computer's dice first", () {
      const headline = HeadlineUi.computerWon(winnerDice: 13, loserDice: 12);

      expect(mapper.map(headline), 'The computer wins 13 to 12');
    });
  });
}
