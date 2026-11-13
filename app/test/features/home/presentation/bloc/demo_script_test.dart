import 'package:cephalopod/core/board/board_durations.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Home's demo shows two captures, so they must be ones the engine agrees
/// with, on a 5 × 5 board like the real game, and its frames must give each
/// change time to finish.
void main() {
  final rules = CephalopodRules();
  final [empty, position, capture1, after1, capture2, after2] =
      homeDemoScript.frames;
  final [first, second] = demoMoves;

  GameState play(GameState state, Move move) {
    final result = rules.apply(state, move);
    return (result as Ok<GameState, IllegalMove>).value;
  }

  group('homeDemoScript', () {
    test('starts from an empty board, so the dice grow in', () {
      expect(empty.board.dice, isEmpty);
    });

    test('plays on the 5 × 5 board of the real game', () {
      for (final frame in homeDemoScript.frames) {
        expect(frame.board.size, 5);
      }
    });

    test('R5: shows two captures the rules allow, one for each player', () {
      expect(demoPosition.board, position.board);
      expect(rules.legalMoves(demoPosition), contains(first));
      expect(first.captures, hasLength(3));

      final afterFirst = play(demoPosition, first);
      expect(afterFirst.status, const InProgress(Player.white));
      expect(rules.legalMoves(afterFirst), contains(second));
      expect(second.captures, hasLength(2));
    });

    test('R6: ends each move on the board it leaves, with the sum as the '
        'die', () {
      final afterFirst = play(demoPosition, first);
      final afterSecond = play(afterFirst, second);

      expect(after1.board, afterFirst.board);
      expect(afterFirst.board.dice[first.position]?.pips, 6);
      expect(after2.board, afterSecond.board);
      expect(afterSecond.board.dice[second.position]?.pips, 5);
    });

    test('shows the new die and the dice it captures together, once', () {
      expect(capture1.board.dice, {
        ...position.board.dice,
        first.position: after1.board.dice[first.position],
      });
      expect(capture2.board.dice, {
        ...after1.board.dice,
        second.position: after2.board.dice[second.position],
      });
    });

    test('marks the target and the dice it captures, then the last move', () {
      expect(capture1.marks, {
        first.position: SquareMark.captureTarget,
        for (final square in first.captures) square: SquareMark.captureSelected,
      });
      expect(after1.marks, {first.position: SquareMark.lastMove});
      expect(capture2.marks, {
        second.position: SquareMark.captureTarget,
        for (final square in second.captures)
          square: SquareMark.captureSelected,
      });
      expect(after2.marks, {second.position: SquareMark.lastMove});
    });

    test('holds every frame for longer than a die takes to grow or shrink', () {
      for (final frame in homeDemoScript.frames) {
        expect(frame.hold, greaterThan(dieAnimationDuration));
      }
    });

    test('stands still on the frame that shows the first capture', () {
      expect(homeDemoScript.still, capture1);
    });
  });
}
