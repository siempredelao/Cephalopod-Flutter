import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

import 'game_agent_contract.dart';

void main() {
  GreedyAgent greedy(MoveGenerator moves, Random random) {
    return GreedyAgent(
      moves: moves,
      evaluator: PositionEvaluator(),
      random: random,
    );
  }

  gameAgentContract(greedy);

  group('GreedyAgent.chooseMove', () {
    final rules = CephalopodRules();

    test('takes the capture that removes opponent dice', () {
      final state = stateFromAscii('''
        w1 .  w1
        .  .  .
        .  .  .
      ''', toMove: Player.black);

      expect(
        greedy(rules, Random(0)).chooseMove(state),
        Move(
          const Position(0, 1),
          captures: {const Position(0, 0), const Position(0, 2)},
        ),
      );
    });

    test('gives up two of its dice to make one that cannot be captured', () {
      // Capturing its own 3s leaves one 6 (worth 5) instead of three dice.
      final state = stateFromAscii('''
        b3 .  b3
        .  .  .
        .  .  .
      ''', toMove: Player.black);

      expect(
        greedy(rules, Random(0)).chooseMove(state),
        Move(
          const Position(0, 1),
          captures: {const Position(0, 0), const Position(0, 2)},
        ),
      );
    });

    test('picks at random among equally good moves', () {
      // On an empty board every move places a 1, so all score the same.
      final agent = greedy(rules, Random(0));
      final state = rules.newGame();

      final chosen = {for (var i = 0; i < 500; i++) agent.chooseMove(state)};

      expect(chosen, unorderedEquals(rules.legalMoves(state)));
    });

    test('throws a StateError when the rules refuse a move they listed', () {
      final agent = greedy(_RefusingRules(rules), Random(0));

      expect(() => agent.chooseMove(rules.newGame()), throwsStateError);
    });
  });
}

/// Rules that list the real legal moves but refuse to play any of them: a
/// broken [MoveGenerator], to check the agent reports it.
final class _RefusingRules implements MoveGenerator {
  _RefusingRules(this._rules);

  final CephalopodRules _rules;

  @override
  List<Move> legalMoves(GameState state) => _rules.legalMoves(state);

  @override
  Result<GameState, IllegalMove> apply(GameState state, Move move) =>
      Err(GameOver());
}
