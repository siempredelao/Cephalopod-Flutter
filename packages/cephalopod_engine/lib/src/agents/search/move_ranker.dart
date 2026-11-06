import 'package:cephalopod_engine/src/agents/apply_legal_move.dart';
import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/move.dart';
import 'package:cephalopod_engine/src/models/player.dart';
import 'package:collection/collection.dart';

/// A move being considered: the `move`, the `state` it leads to, and its
/// `score` for the player who makes it.
typedef Candidate = ({Move move, GameState state, int score});

/// Plays moves and ranks the results, so the search tries good moves first.
///
/// The sooner the search finds a good move, the more of the others it can
/// skip (see `SearchPass`). The position right after a move is a cheap
/// guess at how good the move is, so moves are ranked by it.
final class MoveRanker {
  /// A ranker that plays moves with `moveGenerator` and scores the results with
  /// `positionEvaluator`.
  MoveRanker({required this._moveGenerator, required this._positionEvaluator});

  final MoveGenerator _moveGenerator;
  final PositionEvaluator _positionEvaluator;

  /// Plays each of the [legalMoves] of [player] in [state] and scores the
  /// result for [player], best first. Equally good moves keep the order they
  /// had in [legalMoves].
  ///
  /// Each position spends one node of [budget]. When the budget refuses one,
  /// it stops and returns the moves played so far; the budget then says it
  /// [NodeBudget.ranOut], and the pass that asked must be thrown away.
  List<Candidate> playAll(
    GameState state,
    Player player,
    List<Move> legalMoves,
    NodeBudget budget,
  ) {
    final candidates = <Candidate>[];
    for (final move in legalMoves) {
      if (!budget.trySpend()) break;
      final nextState = _moveGenerator.applyLegal(state, move);
      final score = _positionEvaluator.score(nextState, player);
      candidates.add((move: move, state: nextState, score: score));
    }
    candidates.sortBestFirst();
    return candidates;
  }
}

/// Sorting candidates for the search.
extension SortBestFirst on List<Candidate> {
  /// Sorts by score, highest first. `mergeSort` keeps the order of equal
  /// items, so equal scores stay in their shuffled order.
  void sortBestFirst() {
    mergeSort(this, compare: (a, b) => b.score.compareTo(a.score));
  }
}
