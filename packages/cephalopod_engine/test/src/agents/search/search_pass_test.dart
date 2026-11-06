import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/src/agents/search/move_ranker.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/src/agents/search/search_pass.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  group('SearchPass.scoreMoves', () {
    final rules = CephalopodRules();
    final evaluator = PositionEvaluator();
    final ranker = MoveRanker(
      moveGenerator: rules,
      positionEvaluator: evaluator,
    );

    /// Runs one pass for Black, to move in [state], looking [depth] moves
    /// ahead, with a budget it cannot run out of.
    SearchPassResult search(GameState state, {required int depth}) {
      const player = Player.black;
      final budget = NodeBudget(1000000)..enforce();
      final legal = rules.legalMoves(state);
      final first = ranker.playAll(state, player, legal, budget);
      final pass = SearchPass(
        moveGenerator: rules,
        moveRanker: ranker,
        nodeBudget: budget,
        depth: depth,
      );
      return pass.scoreMoves(first, player);
    }

    test('looking 2 moves ahead, avoids a capture that leaves a reply', () {
      // Capturing White's two 1s scores best right away, but leaves Black's
      // 1s at (1, 3) and (3, 3) for White to capture from (2, 3). Taking the
      // 1 at (3, 3) into the capture as well leaves no such reply.
      final state = stateFromAscii('''
        .  b1 .  .  .
        .  .  .  b1 .
        .  .  w1 .  .
        .  .  .  b1 .
        .  w1 w1 .  .
      ''', toMove: Player.black);

      final result = search(state, depth: 2);

      expect(
        result.rankedMoveCandidates.first.move,
        Move(
          const Position(3, 2),
          captures: {
            const Position(2, 2),
            const Position(4, 2),
            const Position(3, 3),
          },
        ),
      );
    });

    test('reports it saw every ending when the game ends within it', () {
      // No capture is possible, so the game ends after the last two moves.
      final state = stateFromAscii('''
        b1 w4 b1
        w4 .  b4
        b4 w4 .
      ''', toMove: Player.black);

      final result = search(state, depth: 2);

      expect(result.sawEveryEnding, isTrue);
    });

    test('reports it did not when the game goes on past its depth', () {
      final result = search(rules.newGame(), depth: 2);

      expect(result.sawEveryEnding, isFalse);
    });
  });
}
