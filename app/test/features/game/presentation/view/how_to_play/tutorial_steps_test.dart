import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_steps.dart';
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

  group('tutorialSteps', () {
    test('R5: show exactly the capture choices the rules allow', () {
      final choosing = [
        for (final step in tutorialSteps)
          if (step.example.phase case final ChoosingCapture phase)
            (game: step.example.game, phase: phase),
      ];

      expect(choosing, isNotEmpty);
      for (final (:game, :phase) in choosing) {
        final allowed = capturesAt(game, phase.target);
        expect(phase.options, unorderedEquals(allowed));
      }
    });

    test('R7: show a 1 only where nothing could be captured', () {
      for (final step in tutorialSteps) {
        final square = step.example.lastMove?.position;
        final die = step.example.game.board.dice[square];
        if (square == null || die == null || die.pips != 1) continue;

        final before = GameState(
          board: Board(
            size: step.example.game.board.size,
            dice: {...step.example.game.board.dice}..remove(square),
          ),
          status: step.example.game.status,
        );

        expect(capturesAt(before, square), [<Position>{}], reason: step.title);
      }
    });

    test('R8: end with the winner the referee declares', () {
      final last = tutorialSteps.last.example.game;

      expect(last.status, referee.statusOf(last.board, Player.black));
      expect(last.status, isA<Finished>());
    });
  });
}
