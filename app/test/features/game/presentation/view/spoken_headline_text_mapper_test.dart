import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/view/spoken_headline_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = SpokenHeadlineTextMapper();
  const yourTurn = HeadlineUi.personToMove();
  const computerMove = ComputerMoveUi(row: 1, col: 3, pips: 3);

  group('SpokenHeadlineTextMapper', () {
    test('says the headline as written when the computer has not moved', () {
      expect(mapper.map(yourTurn, null, english), 'Your turn');
      expect(
        mapper.map(const HeadlineUi.computerToMove(), null, english),
        'The computer is thinking…',
      );
    });

    test('says what the computer did first, counting from 1', () {
      expect(
        mapper.map(yourTurn, computerMove, english),
        'The computer placed a 3 at row 2, column 4. Your turn',
      );
    });

    test('says what the computer did before the result', () {
      expect(
        mapper.map(
          const HeadlineUi.computerWon(winnerDice: 13, loserDice: 12),
          computerMove,
          english,
        ),
        'The computer placed a 3 at row 2, column 4. '
        'The computer wins 13 to 12',
      );
    });

    test('speaks Spanish', () {
      expect(
        mapper.map(yourTurn, computerMove, spanish),
        'El ordenador puso un 3 en la fila 2, columna 4. Tu turno',
      );
    });
  });
}
