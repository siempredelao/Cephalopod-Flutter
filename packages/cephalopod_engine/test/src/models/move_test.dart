import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Move', () {
    const target = Position(2, 2);
    const above = Position(1, 2);
    const below = Position(3, 2);

    test('captures nothing by default', () {
      expect(Move(target).captures, isEmpty);
    });

    test('keeps an unmodifiable copy of its captures', () {
      final captures = {above, below};
      final move = Move(target, captures: captures);

      captures.clear();

      expect(move.captures, {above, below});
      expect(() => move.captures.add(target), throwsUnsupportedError);
    });

    test('moves with the same square and captures are equal', () {
      final move = Move(target, captures: {above, below});
      final sameInOtherOrder = Move(target, captures: {below, above});

      expect(move, sameInOtherOrder);
      expect(move.hashCode, sameInOtherOrder.hashCode);
      expect(move, isNot(Move(target)));
      expect(Move(target), isNot(Move(above)));
    });

    test('prints its square and captures', () {
      expect(
        Move(target, captures: {above}).toString(),
        'Move((2, 2), captures: {(1, 2)})',
      );
    });
  });
}
