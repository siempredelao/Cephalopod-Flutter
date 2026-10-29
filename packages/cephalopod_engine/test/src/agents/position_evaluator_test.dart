import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  final evaluator = PositionEvaluator();

  group('PositionEvaluator.score', () {
    test('R8: a finished game scores a win for the winner only', () {
      final finished = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.white);

      expect(
        evaluator.score(finished, Player.black),
        PositionEvaluator.winScore,
      );
      expect(
        evaluator.score(finished, Player.white),
        -PositionEvaluator.winScore,
      );
    });

    test('counts own dice for the player and the opponent dice against', () {
      final state = stateFromAscii('''
        b1 w2 .
        .  b4 .
        .  .  .
      ''', toMove: Player.white);

      expect(evaluator.score(state, Player.black), 1);
      expect(evaluator.score(state, Player.white), -1);
    });

    test('values a die no capture can remove above an ordinary one', () {
      // A 6 cannot be captured: with any other die the sum passes 6.
      final state = stateFromAscii('''
        b6 w5 w1
        .  .  .
        .  .  .
      ''', toMove: Player.white);

      expect(
        evaluator.score(state, Player.black),
        PositionEvaluator.permanentDieValue - 2 * PositionEvaluator.dieValue,
      );
    });

    test('decides which dice cannot be captured from the config', () {
      // Sums of at most 4: a 4 cannot be captured, a 3 still can.
      final lowSum = stateFromAscii(
        '''
        b4 w3 .
        .  .  .
        .  .  .
        ''',
        toMove: Player.white,
        config: const GameConfig(boardSize: 3, maxCaptureSum: 4),
      );
      // Captures of 3 or more dice: a 5 plus two 1s passes 6, a 4 does not.
      final threeDice = stateFromAscii(
        '''
        b5 w4 .
        .  .  .
        .  .  .
        ''',
        toMove: Player.white,
        config: const GameConfig(boardSize: 3, minCaptureDice: 3),
      );

      expect(evaluator.score(lowSum, Player.black), 4);
      expect(evaluator.score(threeDice, Player.black), 4);
    });
  });
}
