import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/src/agents/search/move_ranker.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

void main() {
  group('MoveRanker.playAll', () {
    final rules = CephalopodRules();
    final ranker = MoveRanker(moves: rules, evaluator: PositionEvaluator());

    // Black's only capture takes both white dice; every other move places a
    // plain 1 and leaves White a die ahead.
    final state = stateFromAscii('''
      w1 .  w1
      .  .  .
      .  .  .
    ''', toMove: Player.black);
    final legal = rules.legalMoves(state);
    final capture = Move(
      const Position(0, 1),
      captures: {const Position(0, 0), const Position(0, 2)},
    );

    test('puts the move that leads to the best position first', () {
      final ranked = ranker.playAll(state, Player.black, legal, NodeBudget(0));

      expect(ranked.first.move, capture);
      expect(ranked.first.score, 1);
    });

    test('keeps the given order for equally good moves', () {
      final ranked = ranker.playAll(state, Player.black, legal, NodeBudget(0));

      expect(
        ranked.skip(1).map((candidate) => candidate.move),
        legal.where((move) => move != capture),
      );
    });

    test('stops when the budget refuses a position', () {
      final budget = NodeBudget(2)..enforce();

      final ranked = ranker.playAll(state, Player.black, legal, budget);

      expect(ranked, hasLength(2));
      expect(budget.ranOut, isTrue);
    });
  });
}
