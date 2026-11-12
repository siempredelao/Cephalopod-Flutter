import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// The examples teach the rules, so each one must be a position the engine
/// agrees with.
void main() {
  final rules = CephalopodRules();
  final referee = Referee();

  /// The captures the engine allows for a die placed on [square] in [game].
  List<Set<Position>> capturesAt(GameState game, Position square) => [
    for (final move in rules.legalMoves(game))
      if (move.position == square) move.captures,
  ];

  /// The squares of [step]'s example that carry [mark].
  List<Position> squaresMarked(TutorialStep step, SquareMark mark) => [
    for (final MapEntry(:key, :value) in step.example.marks.entries)
      if (value == mark) key,
  ];

  group('tutorialSteps', () {
    test('teach every topic once, in order', () {
      expect([
        for (final step in tutorialSteps) step.topic,
      ], TutorialTopic.values);
    });

    test('R5: mark exactly the dice the rules let a capture take', () {
      final choosing = [
        for (final step in tutorialSteps)
          if (squaresMarked(step, SquareMark.captureTarget) case [final target])
            (game: step.example.game, target: target, step: step),
      ];

      expect(choosing, isNotEmpty);
      for (final (:game, :target, :step) in choosing) {
        final allowed = capturesAt(game, target);
        final choices = {
          ...squaresMarked(step, SquareMark.captureOption),
          ...squaresMarked(step, SquareMark.captureSelected),
        };
        expect(choices, allowed.expand((captures) => captures).toSet());
      }
    });

    test('R7: show a 1 only where nothing could be captured', () {
      for (final step in tutorialSteps) {
        final marked = squaresMarked(step, SquareMark.lastMove);
        if (marked.length != 1) continue;
        final square = marked.single;
        final die = step.example.game.board.dice[square];
        if (die == null || die.pips != 1) continue;

        final before = GameState(
          board: Board(
            size: step.example.game.board.size,
            dice: {...step.example.game.board.dice}..remove(square),
          ),
          status: step.example.game.status,
        );

        expect(
          capturesAt(before, square),
          [<Position>{}],
          reason: step.topic.name,
        );
      }
    });

    test('R8: end with the winner the referee declares', () {
      final last = tutorialSteps.last.example.game;

      expect(last.status, referee.statusOf(last.board, Player.black));
      expect(last.status, isA<Finished>());
    });
  });
}
