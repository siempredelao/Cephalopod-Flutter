import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  final validator = MoveValidator();
  const top = Position(0, 2);
  const leftOfTop = Position(0, 1);
  const rightOfTop = Position(0, 3);
  const belowTop = Position(1, 2);

  /// Rule sheet Fig. 4: two white 1s either side of the top centre square
  /// and a 5 below it, so three captures are possible there.
  final figure4 = stateFromAscii('''
    .  w1 .  w1 .
    .  .  b5 .  .
    .  .  .  .  .
    .  .  .  .  .
    .  .  .  .  .
  ''', toMove: Player.black);

  IllegalMove? violationOf(Move move) => validator.violationOf(figure4, move);

  group('MoveValidator.violationOf', () {
    test('accepts a legal move', () {
      final move = Move(top, captures: {leftOfTop, rightOfTop});

      expect(violationOf(move), isNull);
    });

    test('refuses a square outside the board', () {
      const outside = Position(5, 0);

      expect(
        violationOf(Move(outside)),
        isA<OutsideBoard>().having((e) => e.position, 'at', outside),
      );
    });

    test('R2: refuses an occupied square', () {
      expect(
        violationOf(Move(leftOfTop)),
        isA<SquareOccupied>().having((e) => e.position, 'at', leftOfTop),
      );
    });

    test('R5: a capture is mandatory where one is possible', () {
      expect(
        violationOf(Move(top)),
        isA<CaptureRequired>().having(
          (e) => e.options,
          'options',
          unorderedEquals([
            {leftOfTop, rightOfTop},
            {leftOfTop, belowTop},
            {rightOfTop, belowTop},
          ]),
        ),
      );
    });

    test('R4: refuses captures that are not an option', () {
      final invalid = <Set<Position>>[
        {leftOfTop, rightOfTop, belowTop},
        {leftOfTop},
        {leftOfTop, const Position(2, 2)},
        {leftOfTop, const Position(4, 4)},
      ];

      for (final captures in invalid) {
        expect(
          violationOf(Move(top, captures: captures)),
          isA<InvalidCapture>().having((e) => e.captures, 'captures', captures),
          reason: '$captures',
        );
      }
    });

    test('R4: refuses a capture where none is possible', () {
      final move = Move(const Position(2, 2), captures: {belowTop});

      expect(violationOf(move), isA<InvalidCapture>());
    });

    test('reports only the first rule a move breaks', () {
      final move = Move(leftOfTop, captures: {const Position(4, 4)});

      expect(violationOf(move), isA<SquareOccupied>());
    });
  });
}
