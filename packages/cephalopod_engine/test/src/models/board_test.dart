import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Board', () {
    const a = Position(0, 0);
    const b = Position(1, 1);
    const blackOne = Die(owner: Player.black, pips: 1);
    const whiteTwo = Die(owner: Player.white, pips: 2);

    test('is empty by default', () {
      final board = Board(size: 5);

      expect(board.size, 5);
      expect(board.dice, isEmpty);
    });

    test('keeps an unmodifiable copy of its dice', () {
      final dice = {a: blackOne};
      final board = Board(size: 3, dice: dice);

      dice.clear();

      expect(board.dice, {a: blackOne});
      expect(() => board.dice[b] = whiteTwo, throwsUnsupportedError);
    });

    test('boards with the same size and dice are equal', () {
      final board = Board(size: 3, dice: {a: blackOne, b: whiteTwo});
      final sameInOtherOrder = Board(size: 3, dice: {b: whiteTwo, a: blackOne});

      expect(board, sameInOtherOrder);
      expect(board.hashCode, sameInOtherOrder.hashCode);
      expect(board, isNot(Board(size: 3, dice: {a: blackOne})));
      expect(Board(size: 3), isNot(Board(size: 5)));
    });

    test('prints its size and dice', () {
      expect(
        Board(size: 3, dice: {a: blackOne}).toString(),
        'Board(size: 3, dice: {(0, 0): b1})',
      );
    });
  });
}
