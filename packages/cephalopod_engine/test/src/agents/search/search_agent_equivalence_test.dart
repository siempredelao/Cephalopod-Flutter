import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

import '../../../helpers/result.dart';
import 'legacy_search_agent.dart';

/// Temporary: proves that splitting SearchAgent changed no move. It is
/// deleted, with LegacySearchAgent, once CI has run it on the split.
void main() {
  final rules = CephalopodRules();
  final evaluator = PositionEvaluator();

  for (final budget in const [0, 200, 1000, 3000]) {
    test(
      'chooses the same moves as before the split, budget $budget',
      () {
        for (var seed = 0; seed < 3; seed++) {
          final current = SearchAgent(
            moves: rules,
            evaluator: evaluator,
            random: Random(seed),
            nodeBudget: budget,
          );
          final legacy = LegacySearchAgent(
            moves: rules,
            evaluator: evaluator,
            random: Random(seed),
            nodeBudget: budget,
          );
          // A random opponent spreads the game over more kinds of positions.
          final opponent = RandomAgent(moves: rules, random: Random(seed));
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
