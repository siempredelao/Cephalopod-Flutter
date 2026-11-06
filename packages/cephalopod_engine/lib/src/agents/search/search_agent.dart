import 'dart:math';

import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/agents/search/move_ranker.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/src/agents/search/search_pass.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';

/// The Hard opponent: it thinks ahead the way a careful player does. "If I
/// play here, their best reply is there, and then my best answer is...".
///
/// Every extra move ahead multiplies the positions to check by the number of
/// legal moves: one per empty square, plus one more for each extra way a die
/// there can capture. That is 25 on an empty board. In simulated random games
/// it averaged 13, and passed 50 where several captures were possible. So it
/// cannot know in advance how far ahead it can afford to look. It makes a
/// pass looking 1 move ahead, then a new pass looking 2 ahead, then 3, until
/// its [NodeBudget] is spent. It plays the best move of the last pass it
/// finished, because a pass cut short has not compared every move. Textbooks
/// call this iterative deepening.
///
/// The work is split by job:
///
/// - [NodeBudget] counts the positions generated and says when to stop.
/// - [MoveRanker] plays moves and ranks the results, so good moves are tried
///   first. Equally good moves keep a random order, shuffled with `random`.
/// - [SearchPass] scores the moves by looking a fixed number of moves ahead,
///   skipping moves that cannot win.
///
/// The first pass is free, so even a budget of 0 plays like the Medium agent.
final class SearchAgent implements GameAgent {
  /// An agent that asks `moveGenerator` for the legal moves and what they
  /// lead to, scores positions with `evaluator`, and breaks ties with
  /// `random`.
  ///
  /// `nodeBudget` is how many positions it may generate to choose each move
  /// (see [NodeBudget]).
  ///
  /// Throws a [RangeError] when `nodeBudget` is negative.
  SearchAgent({
    required this._moveGenerator,
    required this._evaluator,
    required this._random,
    this._nodeBudget = defaultNodeBudget,
  }) {
    RangeError.checkNotNegative(_nodeBudget, 'nodeBudget');
  }

  final MoveGenerator _moveGenerator;
  final PositionEvaluator _evaluator;
  final Random _random;

  /// How many positions it may generate to choose each move.
  final int _nodeBudget;

  /// The node budget of the app's Hard level: deep enough to see a few moves
  /// ahead on a 5 × 5 board, small enough to answer in a fraction of a
  /// second.
  static const int defaultNodeBudget = 20000;

  @override
  Move chooseMove(GameState state) {
    final status = state.status;
    if (status is! InProgress) {
      throw ArgumentError.value(state, 'state', 'The game is over');
    }
    final player = status.toMove;
    final budget = NodeBudget(_nodeBudget);
    final ranker = MoveRanker(
      moveGenerator: _moveGenerator,
      evaluator: _evaluator,
    );
    final legalMoves = [..._moveGenerator.legalMoves(state)]..shuffle(_random);
    // The first pass looks 1 move ahead: it plays each move and scores the
    // result. The budget does not apply yet, so it always finishes.
    var rankedMoveCandidates = ranker.playAll(
      state,
      player,
      legalMoves,
      budget,
    );
    budget.enforce();
    for (var depth = 2; ; depth++) {
      final pass = SearchPass(
        moveGenerator: _moveGenerator,
        evaluator: _evaluator,
        ranker: ranker,
        budget: budget,
        depth: depth,
      );
      final result = pass.scoreMoves(rankedMoveCandidates, player);
      // A pass cut short has not compared every move, so it is thrown away.
      if (budget.ranOut) break;
      rankedMoveCandidates = result.rankedMoveCandidates;
      // Every line of play ended within this pass, so looking deeper would
      // change nothing.
      if (result.sawEveryEnding) break;
    }
    return rankedMoveCandidates.first.move;
  }
}
