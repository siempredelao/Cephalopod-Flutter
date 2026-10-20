import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  final referee = Referee();

  group('Referee.statusOf', () {
    test('R8: the game goes on while a square is vacant', () {
      final board = boardFromAscii('''
        b1 w1 b1
        w1 .  w1
        b1 w1 b1
      ''');

      expect(
        referee.statusOf(board, Player.white),
        const InProgress(Player.white),
      );
    });

    test('R8: on a full board the player with more dice wins', () {
      final blackMajority = boardFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''');
      final whiteMajority = boardFromAscii('''
        w1 b1 w1
        b1 w1 b1
        w1 b1 w1
      ''');

      expect(
        referee.statusOf(blackMajority, Player.white),
        const Finished(winner: Player.black, blackDice: 5, whiteDice: 4),
      );
      expect(
        referee.statusOf(whiteMajority, Player.black),
        const Finished(winner: Player.white, blackDice: 4, whiteDice: 5),
      );
    });
  });
}
