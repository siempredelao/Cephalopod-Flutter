import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  final geometry = BoardGeometry();
  final finder = CaptureFinder(geometry: geometry);
  const center = Position(2, 2);

  List<Set<Position>> optionsAt(String grid, Position target) =>
      finder.optionsAt(boardFromAscii(grid), target, GameConfig.standard);

  group('CaptureFinder.optionsAt', () {
    test('R4: no neighbours means no capture', () {
      expect(optionsAt('. . . . .\n' * 5, center), isEmpty);
    });

    test('R4: a single neighbour cannot be captured', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  w1 .  .
        .  .  .  .  .
        .  .  .  .  .
        .  .  .  .  .
      ''', center);

      expect(options, isEmpty);
    });

    test('R4: two neighbours summing to 6 or less can be captured', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  w2 .  .
        .  .  .  b4 .
        .  .  .  .  .
        .  .  .  .  .
      ''', center);

      expect(options, [
        {const Position(1, 2), const Position(2, 3)},
      ]);
    });

    test('R4: two neighbours summing to 7 cannot be captured (Fig. 5)', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  .  .  w5
        .  .  .  .  .
        .  .  .  .  b2
        .  .  .  .  .
      ''', const Position(2, 4));

      expect(options, isEmpty);
    });

    test('R4: colour does not matter; own dice can be captured', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  b1 .  .
        .  b1 .  .  .
        .  .  .  .  .
        .  .  .  .  .
      ''', center);

      expect(options, hasLength(1));
    });

    test('R4: four neighbours of 1 + 1 + 1 + 3 give all 11 subsets', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  w1 .  .
        .  b1 .  w1 .
        .  .  b3 .  .
        .  .  .  .  .
      ''', center);

      expect(options, hasLength(11), reason: '6 pairs, 4 triples, 1 quad');
      expect(
        options,
        anyElement(equals(geometry.neighbours(center, 5).toSet())),
        reason: 'all four together: 1 + 1 + 1 + 3 = 6',
      );
    });

    test('R4: only subsets with a sum of 6 or less are options', () {
      final options = optionsAt('''
        .  .  .  .  .
        .  .  w3 .  .
        .  b3 .  w1 .
        .  .  .  .  .
        .  .  .  .  .
      ''', center);

      expect(
        options,
        unorderedEquals([
          {const Position(1, 2), const Position(2, 1)},
          {const Position(1, 2), const Position(2, 3)},
          {const Position(2, 1), const Position(2, 3)},
        ]),
        reason: '3 + 3 + 1 = 7 is too much',
      );
    });
  });

  group('CaptureFinder.pipSum', () {
    test('R6: adds the pips on the squares; vacant squares count 0', () {
      final board = boardFromAscii('''
        b1 w2 .
        .  b3 .
        .  .  .
      ''');

      expect(
        finder.pipSum(board, {
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
          const Position(1, 1),
        }),
        6,
      );
    });
  });
}
