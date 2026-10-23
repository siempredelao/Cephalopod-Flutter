import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

void main() {
  group('GameRecord', () {
    const center = Position(2, 2);
    const top = Position(0, 2);
    final moves = [Move(center), Move(top)];

    test('is a new standard game by default', () {
      final record = GameRecord();

      expect(record.config, GameConfig.standard);
      expect(record.moves, isEmpty);
    });

    test('keeps an unmodifiable copy of its moves', () {
      final played = [...moves];
      final record = GameRecord(moves: played);

      played.clear();

      expect(record.moves, moves);
      expect(() => record.moves.add(Move(center)), throwsUnsupportedError);
    });

    test('records with the same config and moves are equal', () {
      const small = GameConfig(boardSize: 3);
      final record = GameRecord(moves: moves);
      final same = GameRecord(moves: [...moves]);
      final reordered = GameRecord(moves: moves.reversed.toList());
      final otherConfig = GameRecord(config: small, moves: moves);

      expect(record, same);
      expect(record.hashCode, same.hashCode);
      expect(record, isNot(reordered));
      expect(record, isNot(otherConfig));
    });

    test('prints its config and moves', () {
      final record = GameRecord(moves: [Move(center)]);

      expect(
        record.toString(),
        'GameRecord(config: ${GameConfig.standard}, '
        'moves: [Move((2, 2), captures: {})])',
      );
    });
  });
}
