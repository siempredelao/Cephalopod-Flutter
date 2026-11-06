// Temporary: a frozen copy of SearchAgent from before the search reused the
// scores MoveRanker.playAll already computed. The equivalence test plays it
// against the current code and expects identical moves. Deleted once CI has
// run it.

import 'dart:math';

import 'package:cephalopod_engine/src/agents/game_agent.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/agents/search/move_ranker.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/move.dart';

import 'legacy_search_pass.dart';

/// SearchAgent as merged in #30, kept to compare against.
final class LegacySearchAgent implements GameAgent {
  /// An agent that asks `moveGenerator` for the legal moves and what they
  /// lead to, scores positions with `positionEvaluator`, and breaks ties with
  /// `random`.
  ///
  /// `nodeLimit` is how many positions it may generate to choose each move:
  /// the limit of its [NodeBudget].
  ///
  /// Throws a [RangeError] when `nodeLimit` is negative.
  LegacySearchAgent({
    required this._moveGenerator,
    required this._positionEvaluator,
    required this._random,
    this._nodeLimit = defaultNodeLimit,
  }) {
    RangeError.checkNotNegative(_nodeLimit, 'nodeLimit');
  }

  final MoveGenerator _moveGenerator;
  final PositionEvaluator _positionEvaluator;
  final Random _random;

  /// How many positions it may generate to choose each move.
  final int _nodeLimit;

  /// The node limit of the app's Hard level: deep enough to see a few moves
  /// ahead on a 5 × 5 board, small enough to answer in a fraction of a
  /// second.
  static const int defaultNodeLimit = 20000;

  @override
  Move chooseMove(GameState state) {
    final status = state.status;
    if (status is! InProgress) {
      throw ArgumentError.value(state, 'state', 'The game is over');
    }

    final player = status.toMove;
    final nodeBudget = NodeBudget(_nodeLimit);
    final moveRanker = MoveRanker(
      moveGenerator: _moveGenerator,
      positionEvaluator: _positionEvaluator,
    );
    final legalMoves = [..._moveGenerator.legalMoves(state)]..shuffle(_random);

    // The first pass looks 1 move ahead: it plays each move and scores the
    // result. The budget does not apply yet, so it always finishes.
    var rankedMoveCandidates = moveRanker.playAll(
      state,
      player,
      legalMoves,
      nodeBudget,
    );
    nodeBudget.enforce();

    for (var depth = 2; ; depth++) {
      final searchPass = LegacySearchPass(
        moveGenerator: _moveGenerator,
        positionEvaluator: _positionEvaluator,
        moveRanker: moveRanker,
        nodeBudget: nodeBudget,
        depth: depth,
      );
      final searchPassResult = searchPass.scoreMoves(
        rankedMoveCandidates,
        player,
      );
      // A pass cut short has not compared every move, so it is thrown away.
      if (nodeBudget.ranOut) break;

      rankedMoveCandidates = searchPassResult.rankedMoveCandidates;
      // Every line of play ended within this pass, so looking deeper would
      // change nothing.
      if (searchPassResult.sawEveryEnding) break;
    }

    return rankedMoveCandidates.first.move;
  }
}
