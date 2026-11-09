import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/translations.dart';

void main() {
  const mapper = PlayerTextMapper();

  group('PlayerTextMapper', () {
    test('numbers the players from 1', () {
      expect(mapper.map(PlayerUi.one, english), 'Player 1');
      expect(mapper.map(PlayerUi.two, english), 'Player 2');
    });

    test('speaks Spanish', () {
      expect(mapper.map(PlayerUi.one, spanish), 'Jugador 1');
    });
  });
}
