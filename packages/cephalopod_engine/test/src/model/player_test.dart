import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Player', () {
    test('R1: there are exactly two players, black and white', () {
      expect(Player.values, [Player.black, Player.white]);
    });

    test('R1: the opponent of black is white', () {
      expect(Player.black.opponent, Player.white);
    });

    test('R1: the opponent of white is black', () {
      expect(Player.white.opponent, Player.black);
    });

    test('R1: turns alternate, so the opponent of the opponent is self', () {
      for (final player in Player.values) {
        expect(player.opponent.opponent, player);
      }
    });
  });
}
