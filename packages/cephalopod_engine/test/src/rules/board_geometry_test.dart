import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  final geometry = BoardGeometry();

  group('BoardGeometry', () {
    test('R1: a 5 × 5 board has 25 squares in row-major order', () {
      final squares = geometry.squares(5);

      expect(squares, hasLength(25));
      expect(squares.first, const Position(0, 0));
      expect(squares[1], const Position(0, 1));
      expect(squares[5], const Position(1, 0));
      expect(squares.last, const Position(4, 4));
    });

    test('contains only squares on the board', () {
      expect(geometry.contains(const Position(0, 0), 5), isTrue);
      expect(geometry.contains(const Position(4, 4), 5), isTrue);
      expect(geometry.contains(const Position(-1, 0), 5), isFalse);
      expect(geometry.contains(const Position(0, -1), 5), isFalse);
      expect(geometry.contains(const Position(5, 0), 5), isFalse);
      expect(geometry.contains(const Position(0, 5), 5), isFalse);
    });

    test('R3: a corner square has 2 neighbours', () {
      expect(
        geometry.neighbours(const Position(4, 4), 5),
        unorderedEquals([const Position(3, 4), const Position(4, 3)]),
      );
    });

    test('R3: an edge square has 3 neighbours', () {
      expect(
        geometry.neighbours(const Position(0, 2), 5),
        unorderedEquals([
          const Position(0, 1),
          const Position(0, 3),
          const Position(1, 2),
        ]),
      );
    });

    test('R3: an inner square has 4 orthogonal neighbours', () {
      expect(
        geometry.neighbours(const Position(2, 2), 5),
        unorderedEquals([
          const Position(1, 2),
          const Position(2, 1),
          const Position(2, 3),
          const Position(3, 2),
        ]),
      );
    });
  });
}
