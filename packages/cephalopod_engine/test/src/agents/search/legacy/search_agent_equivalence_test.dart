import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

import '../../../../helpers/result.dart';
import 'legacy_search_agent.dart';

/// Temporary: proves that reusing playAll's scores changed no move. It is
/// deleted, with the legacy copies, once CI has run it on the change.
void main() {
  final rules = CephalopodRules();
  final evaluator = PositionEvaluator();

  for (final nodeLimit in const [0, 200, 1000, 3000]) {
    test(
      'chooses the same moves as before reusing scores, limit $nodeLimit',
      () {
        for (var seed = 0; seed < 3; seed++) {
          final current = SearchAgent(
            moveGenerator: rules,
            positionEvaluator: evaluator,
            random: Random(seed),
            nodeLimit: nodeLimit,
          );
          final legacy = LegacySearchAgent(
            moveGenerator: rules,
            positionEvaluator: evaluator,
            random: Random(seed),
            nodeLimit: nodeLimit,
          );
          // A random opponent spreads the game over more kinds of positions.
          final opponent = RandomAgent(
            moveGenerator: rules,
            random: Random(seed),
          );
          var state = rules.newGame();
          for (var turn = 0; state.status is InProgress; turn++) {
            final move = current.chooseMove(state);
            expect(legacy.chooseMove(state), move, reason: 'seed $seed');
            final played = turn.isEven ? move : opponent.chooseMove(state);
            state = rules.apply(state, played).valueOrFail;
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  }
}
