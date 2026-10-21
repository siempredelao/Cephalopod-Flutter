// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Die', () {
    test('dice with the same owner and pips are equal', () {
      final die = Die(owner: Player.black, pips: 3);

      expect(die, Die(owner: Player.black, pips: 3));
      expect(die.hashCode, Die(owner: Player.black, pips: 3).hashCode);
      expect(die, isNot(Die(owner: Player.white, pips: 3)));
      expect(die, isNot(Die(owner: Player.black, pips: 4)));
    });

    test('prints as colour initial and pips', () {
      expect(Die(owner: Player.black, pips: 3).toString(), 'b3');
      expect(Die(owner: Player.white, pips: 6).toString(), 'w6');
    });
  });
}
