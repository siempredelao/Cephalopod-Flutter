// Values are built at runtime on purpose, so equality is tested on distinct
// instances rather than on canonicalised constants.
// ignore_for_file: prefer_const_constructors

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Position', () {
    test('positions with the same row and column are equal', () {
      expect(Position(1, 2), Position(1, 2));
      expect(Position(1, 2).hashCode, Position(1, 2).hashCode);
      expect(Position(1, 2), isNot(Position(2, 1)));
    });

    test('prints as (row, col)', () {
      expect(Position(1, 2).toString(), '(1, 2)');
    });
  });
}
