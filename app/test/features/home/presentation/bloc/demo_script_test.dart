import 'package:cephalopod/core/board/board_durations.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Home's demo shows a capture, so it must be one the engine agrees with, and
/// its frames must give each change time to finish.
void main() {
  final rules = CephalopodRules();
  final [empty, position, capture, after] = homeDemoScript.frames;
  final target = demoMove.position;

  group('homeDemoScript', () {
    test('starts from an empty board, so the dice grow in', () {
      expect(empty.board.dice, isEmpty);
    });

    test('R5: shows a capture the rules allow', () {
      expect(demoPosition.board, position.board);
      expect(rules.legalMoves(demoPosition), contains(demoMove));
      expect(demoMove.captures, hasLength(3));
    });

    test('R6: ends on the board the move leaves, with the sum as the die', () {
      final result = rules.apply(demoPosition, demoMove);
      final played = (result as Ok<GameState, IllegalMove>).value;

      expect(after.board, played.board);
      expect(played.board.dice[target]?.pips, 6);
    });

    test('shows the new die and the dice it captures together, once', () {
      final played = {
        ...position.board.dice,
        target: after.board.dice[target]!,
      };

      expect(capture.board.dice, played);
    });

    test('marks the target and the dice it captures, then the last move', () {
      expect(capture.marks, {
        target: SquareMark.captureTarget,
        for (final square in demoMove.captures)
          square: SquareMark.captureSelected,
      });
      expect(after.marks, {target: SquareMark.lastMove});
    });

    test('holds every frame for longer than a die takes to grow or shrink', () {
      for (final frame in homeDemoScript.frames) {
        expect(frame.hold, greaterThan(dieAnimationDuration));
      }
    });

    test('stands still on the frame that shows the capture', () {
      expect(homeDemoScript.still, capture);
    });
  });
}
