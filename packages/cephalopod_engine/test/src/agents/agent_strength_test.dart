import 'dart:math';

import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:test/test.dart';

import '../../helpers/result.dart';

/// Builds one difficulty level from its source of randomness.
typedef Level = GameAgent Function(Random random);

/// Seeded matches between difficulty levels: each level must beat the one
/// below it in most games. The thresholds leave a wide margin below the win
/// rates measured while tuning, so the tests do not depend on luck.
void main() {
  final rules = CephalopodRules();
  final evaluator = PositionEvaluator();

  GameAgent easy(Random random) => RandomAgent(moves: rules, random: random);

  GameAgent medium(Random random) {
    return GreedyAgent(moves: rules, evaluator: evaluator, random: random);
  }

  // A small budget keeps the test fast; the app's Hard level searches with
  // SearchAgent.defaultNodeBudget, 20 times more.
  GameAgent hard(Random random) {
    return SearchAgent(
      moves: rules,
      evaluator: evaluator,
      random: random,
      nodeBudget: 1000,
    );
  }

  /// Plays a game between [black] and [white] and returns the winner.
  Player play(GameAgent black, GameAgent white) {
    var state = rules.newGame();
    while (true) {
      switch (state.status) {
        case Finished(:final winner):
          return winner;
        case InProgress(:final toMove):
          final agent = toMove == Player.black ? black : white;
          state = rules.apply(state, agent.chooseMove(state)).valueOrFail;
      }
    }
  }

  /// How many of [games] seeded games [stronger] wins against [weaker].
  /// Colours alternate, so the stronger level does not always move first.
  int winsOf(Level stronger, Level weaker, {required int games}) {
    var wins = 0;
    for (var game = 0; game < games; game++) {
      final strong = stronger(Random(2 * game));
      final weak = weaker(Random(2 * game + 1));
      final won = game.isEven
          ? play(strong, weak) == Player.black
          : play(weak, strong) == Player.white;
      if (won) wins++;
    }
    return wins;
  }

  test('Medium beats Easy in at least 16 of 20 games', () {
    expect(winsOf(medium, easy, games: 20), greaterThanOrEqualTo(16));
  });

  test('Hard beats Medium in at least 8 of 10 games', () {
    expect(winsOf(hard, medium, games: 10), greaterThanOrEqualTo(8));
  });
}
