import 'package:cephalopod/features/game/presentation/models/die_ui.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/square_ui.dart';
import 'package:cephalopod/features/game/presentation/view/square_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = SquareTextMapper();

  /// The square at row 1, column 2, counting from 0, with a 5 owned by
  /// [player] in [role].
  SquareUi fiveOf(PlayerUi player, RoleUi role) {
    return SquareUi(
      row: 1,
      col: 2,
      die: DieUi(
        pips: 5,
        owner: SideUi(player: player, role: role),
      ),
      mark: SquareMark.none,
    );
  }

  group('SquareTextMapper', () {
    test('says where an empty square is, counting from 1', () {
      const square = SquareUi(row: 0, col: 2, die: null, mark: SquareMark.none);

      expect(mapper.map(square, english), 'Row 1, column 3, empty');
    });

    test("names a player's die between two people", () {
      final square = fiveOf(PlayerUi.one, RoleUi.player);

      expect(
        mapper.map(square, english),
        'Row 2, column 3, Player 1 die showing 5',
      );
    });

    test("calls the person's die theirs against the computer", () {
      final square = fiveOf(PlayerUi.two, RoleUi.person);

      expect(
        mapper.map(square, english),
        'Row 2, column 3, your die showing 5',
      );
    });

    test("calls the computer's die the computer's", () {
      final square = fiveOf(PlayerUi.one, RoleUi.computer);

      expect(
        mapper.map(square, english),
        "Row 2, column 3, the computer's die showing 5",
      );
    });

    test('speaks Spanish, for every owner', () {
      const empty = SquareUi(row: 0, col: 2, die: null, mark: SquareMark.none);

      expect(mapper.map(empty, spanish), 'Fila 1, columna 3, vacía');
      expect(
        mapper.map(fiveOf(PlayerUi.one, RoleUi.player), spanish),
        'Fila 2, columna 3, dado del Jugador 1 con 5 puntos',
      );
      expect(
        mapper.map(fiveOf(PlayerUi.two, RoleUi.person), spanish),
        'Fila 2, columna 3, tu dado con 5 puntos',
      );
      expect(
        mapper.map(fiveOf(PlayerUi.one, RoleUi.computer), spanish),
        'Fila 2, columna 3, dado del ordenador con 5 puntos',
      );
    });

    test('says "1 punto", not "1 puntos", in Spanish', () {
      const one = SquareUi(
        row: 0,
        col: 0,
        die: DieUi(
          pips: 1,
          owner: SideUi(player: PlayerUi.two, role: RoleUi.person),
        ),
        mark: SquareMark.none,
      );

      expect(
        mapper.map(one, spanish),
        'Fila 1, columna 1, tu dado con 1 punto',
      );
    });
  });
}
