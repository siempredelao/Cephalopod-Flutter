import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/view/headline_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = HeadlineTextMapper();

  group('HeadlineTextMapper', () {
    test('names the player to move between two people', () {
      expect(
        mapper.map(const HeadlineUi.playerToMove(PlayerUi.two), english),
        'Player 2 to move',
      );
    });

    test('tells the person it is their turn', () {
      expect(mapper.map(const HeadlineUi.personToMove(), english), 'Your turn');
    });

    test('says the computer is thinking on its turn', () {
      expect(
        mapper.map(const HeadlineUi.computerToMove(), english),
        'The computer is thinking…',
      );
    });

    test('says it is looking for a hint', () {
      expect(
        mapper.map(const HeadlineUi.lookingForHint(), english),
        'Looking for a hint…',
      );
    });

    test('R8: names the winner between two people, their dice first', () {
      const headline = HeadlineUi.playerWon(
        player: PlayerUi.one,
        winnerDice: 13,
        loserDice: 12,
      );

      expect(mapper.map(headline, english), 'Player 1 wins 13 to 12');
    });

    test('R8: tells the person they won, their dice first', () {
      const headline = HeadlineUi.personWon(winnerDice: 14, loserDice: 11);

      expect(mapper.map(headline, english), 'You win 14 to 11');
    });

    test("R8: says the computer won, the computer's dice first", () {
      const headline = HeadlineUi.computerWon(winnerDice: 13, loserDice: 12);

      expect(mapper.map(headline, english), 'The computer wins 13 to 12');
    });

    test('speaks Spanish, for every headline', () {
      const headlines = <(HeadlineUi, String)>[
        (HeadlineUi.playerToMove(PlayerUi.two), 'Turno del Jugador 2'),
        (HeadlineUi.personToMove(), 'Tu turno'),
        (HeadlineUi.computerToMove(), 'El ordenador está pensando…'),
        (HeadlineUi.lookingForHint(), 'Buscando una pista…'),
        (
          HeadlineUi.playerWon(
            player: PlayerUi.one,
            winnerDice: 13,
            loserDice: 12,
          ),
          'Gana el Jugador 1 por 13 a 12',
        ),
        (
          HeadlineUi.personWon(winnerDice: 14, loserDice: 11),
          'Ganas por 14 a 11',
        ),
        (
          HeadlineUi.computerWon(winnerDice: 13, loserDice: 12),
          'Gana el ordenador por 13 a 12',
        ),
      ];

      for (final (headline, words) in headlines) {
        expect(mapper.map(headline, spanish), words);
      }
    });
  });
}
