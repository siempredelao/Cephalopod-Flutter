// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('InProgress', () {
    test('is equal when the player to move is', () {
      expect(InProgress(Player.black), InProgress(Player.black));
      expect(
        InProgress(Player.black).hashCode,
        InProgress(Player.black).hashCode,
      );
      expect(InProgress(Player.black), isNot(InProgress(Player.white)));
    });

    test('prints the player to move', () {
      expect(
        InProgress(Player.white).toString(),
        'InProgress(toMove: white)',
      );
    });
  });

  group('Finished', () {
    Finished finished({
      Player winner = Player.black,
      int blackDice = 13,
      int whiteDice = 12,
    }) => Finished(winner: winner, blackDice: blackDice, whiteDice: whiteDice);

    test('is equal when the winner and counts are', () {
      expect(finished(), finished());
      expect(finished().hashCode, finished().hashCode);
      expect(finished(), isNot(finished(winner: Player.white)));
      expect(finished(), isNot(finished(blackDice: 12)));
      expect(finished(), isNot(finished(whiteDice: 11)));
      expect(finished(), isNot(InProgress(Player.black)));
    });

    test('prints the winner and counts', () {
      expect(
        finished().toString(),
        'Finished(winner: black, blackDice: 13, whiteDice: 12)',
      );
    });
  });
}
