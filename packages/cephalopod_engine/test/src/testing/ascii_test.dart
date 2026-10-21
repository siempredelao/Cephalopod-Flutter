import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  group('boardFromAscii', () {
    test('reads dice and vacant squares, ignoring indentation', () {
      final board = boardFromAscii('''

        b1 .  w6

        .  .  .
        .  b3 .
      ''');

      expect(
        board,
        Board(
          size: 3,
          dice: {
            const Position(0, 0): const Die(owner: Player.black, pips: 1),
            const Position(0, 2): const Die(owner: Player.white, pips: 6),
            const Position(2, 1): const Die(owner: Player.black, pips: 3),
          },
        ),
      );
    });

    test('rejects an empty grid', () {
      expect(() => boardFromAscii('  \n  '), throwsFormatException);
    });

    test('rejects a grid that is not square', () {
      expect(() => boardFromAscii('. .\n. .\n. .'), throwsFormatException);
    });

    test('rejects a square it does not understand', () {
      expect(() => boardFromAscii('b7'), throwsFormatException);
      expect(() => boardFromAscii('x1'), throwsFormatException);
    });
  });

  group('boardToAscii', () {
    test('prints a grid that boardFromAscii reads back', () {
      final board = boardFromAscii('''
        b1 .  w3
        .  .  .
        w6 b2 .
      ''');

      expect(boardToAscii(board), 'b1 .  w3\n.  .  .\nw6 b2 .');
      expect(boardFromAscii(boardToAscii(board)), board);
    });
  });

  group('stateFromAscii', () {
    test('uses the standard rules sized to the grid', () {
      final state = stateFromAscii('''
        .  .  .
        .  w1 .
        .  .  .
      ''', toMove: Player.black);

      expect(state.config, const GameConfig(boardSize: 3));
      expect(state.status, const InProgress(Player.black));
    });

    test('takes its status from the referee', () {
      final state = stateFromAscii('''
        b1 w1 b1
        w1 b1 w1
        b1 w1 b1
      ''', toMove: Player.white);

      expect(state.status, isA<Finished>());
    });

    test('uses the config it is given', () {
      const config = GameConfig(boardSize: 3, firstPlayer: Player.white);

      final state = stateFromAscii(
        '. . .\n. . .\n. . .',
        toMove: Player.white,
        config: config,
      );

      expect(state.config, config);
    });
  });
}
