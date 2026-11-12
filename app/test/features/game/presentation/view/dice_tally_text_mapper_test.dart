import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod/features/game/presentation/view/dice_tally_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = DiceTallyTextMapper();
  const person = SideUi(player: PlayerUi.one, role: RoleUi.person);
  const computer = SideUi(player: PlayerUi.two, role: RoleUi.computer);
  const againstComputer = DiceTallyUi(
    playerOne: SideTallyUi(side: person, dice: 7, toMove: true),
    playerTwo: SideTallyUi(side: computer, dice: 1, toMove: false),
  );

  group('DiceTallyTextMapper', () {
    test('names the players by number between two people', () {
      const two = SideUi(player: PlayerUi.two, role: RoleUi.player);

      expect(mapper.nameOf(two, english), 'Player 2');
      expect(mapper.nameOf(two, spanish), 'Jugador 2');
    });

    test('names the person and the computer against the computer', () {
      expect(mapper.nameOf(person, english), 'You');
      expect(mapper.nameOf(computer, english), 'Computer');
      expect(mapper.nameOf(person, spanish), 'Tú');
      expect(mapper.nameOf(computer, spanish), 'Ordenador');
    });

    test('says the whole count, with one die or many', () {
      expect(
        mapper.spoken(againstComputer, english),
        'You: 7 dice. Computer: 1 die.',
      );
      expect(
        mapper.spoken(againstComputer, spanish),
        'Tú: 7 dados. Ordenador: 1 dado.',
      );
    });

    test('says no dice as a number too', () {
      const empty = DiceTallyUi(
        playerOne: SideTallyUi(side: person, dice: 0, toMove: true),
        playerTwo: SideTallyUi(side: computer, dice: 0, toMove: false),
      );

      expect(mapper.spoken(empty, english), 'You: 0 dice. Computer: 0 dice.');
    });
  });
}
