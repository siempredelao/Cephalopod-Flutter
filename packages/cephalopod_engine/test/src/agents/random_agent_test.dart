import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

import 'game_agent_contract.dart';

void main() {
  gameAgentContract(
    (moves, random) => RandomAgent(moves: moves, random: random),
  );

  group('RandomAgent.chooseMove', () {
    test('can choose any legal move', () {
      final rules = CephalopodRules();
      final agent = RandomAgent(moves: rules, random: Random(0));
      final state = rules.newGame();

      final chosen = {for (var i = 0; i < 500; i++) agent.chooseMove(state)};

      expect(chosen, unorderedEquals(rules.legalMoves(state)));
    });
  });
}
