import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:cephalopod_engine/testing.dart';
import 'package:test/test.dart';

import 'game_agent_contract.dart';

void main() {
  /// A Hard agent with a small budget, so the contract games stay fast.
  SearchAgent search(
    MoveGenerator moves,
    Random random, {
    int nodeBudget = 200,
  }) {
    return SearchAgent(
      moves: moves,
      evaluator: PositionEvaluator(),
      random: random,
      nodeBudget: nodeBudget,
    );
  }

  gameAgentContract(search);

  group('SearchAgent.chooseMove', () {
    final rules = CephalopodRules();

    // Black can capture White's two 1s with a 2: the best score right away,
    // and Medium's choice. That leaves Black's 1s at (1, 3) and (3, 3) for
    // White to capture together from (2, 3). Taking the 1 at (3, 3) into the
    // capture as well leaves White no such reply.
    final state = stateFromAscii('''
      .  b1 .  .  .
      .  .  .  b1 .
      .  .  w1 .  .
      .  .  .  b1 .
      .  w1 w1 .  .
    ''', toMove: Player.black);
    const target = Position(3, 2);
    final twoWhite = {const Position(2, 2), const Position(4, 2)};
    final twoWhiteOneBlack = {...twoWhite, const Position(3, 3)};

    test('looks past the best immediate move to the reply', () {
      final agent = search(rules, Random(0), nodeBudget: 5000);

      expect(agent.chooseMove(state), Move(target, captures: twoWhiteOneBlack));
    });

    test('with no budget, still looks one move ahead like Medium', () {
      final agent = search(rules, Random(0), nodeBudget: 0);

      expect(agent.chooseMove(state), Move(target, captures: twoWhite));
    });

    test('rejects a negative budget', () {
      expect(() => search(rules, Random(0), nodeBudget: -1), throwsRangeError);
    });

    test('throws a StateError when the rules refuse a move they listed', () {
      final agent = search(_RefusingRules(rules), Random(0));

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
