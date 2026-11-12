import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/features/home/presentation/bloc/saved_game_ui_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/saved_game_summary.dart';

void main() {
  const mapper = SavedGameUiMapper();

  group('SavedGameUiMapper', () {
    final game = mapper.map(savedGameSummary);

    test('draws the saved board with the sides it names', () {
      expect(game.board.rows, hasLength(3));
      expect(
        game.board.rows[1][1].die,
        DieUi(pips: 1, owner: savedGameSummary.black.side),
      );
      expect(game.board.rows[0][0].die, isNull);
    });

    test("keeps each side's dice and turn, and the computer's level", () {
      expect(game.black, savedGameSummary.black);
      expect(game.white, savedGameSummary.white);
      expect(game.computerLevel, savedGameSummary.computerLevel);
    });
  });
}
