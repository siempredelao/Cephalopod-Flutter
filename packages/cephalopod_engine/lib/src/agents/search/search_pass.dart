import 'dart:math';

import 'package:cephalopod_engine/src/agents/move_generator.dart';
import 'package:cephalopod_engine/src/agents/position_evaluator.dart';
import 'package:cephalopod_engine/src/agents/search/move_ranker.dart';
import 'package:cephalopod_engine/src/agents/search/node_budget.dart';
import 'package:cephalopod_engine/src/models/game_state.dart';
import 'package:cephalopod_engine/src/models/game_status.dart';
import 'package:cephalopod_engine/src/models/player.dart';

/// What a pass found: the moves, `ranked` best first, and whether it
/// `sawEveryEnding` within its depth, so that looking deeper would change
/// nothing.
typedef PassResult = ({List<Candidate> ranked, bool sawEveryEnding});

/// One pass of the search: it scores each move by looking a fixed number of
/// moves ahead, assuming the opponent always picks the reply that hurts most.
///
/// It tries each move and calls itself to find the opponent's best answer.
/// One player's gain is the other's loss, so the opponent's score, negated,
/// is the player's. That lets one method play both sides. Textbooks call this
/// negamax.
///
/// **Skipping moves that cannot win.** Say one move is known to score 3.
/// While checking a second move it finds a reply that leaves it only 1. The
/// opponent would play that reply, so the second move cannot beat the first,
/// however good its other replies are, and it stops looking at it. Textbooks
/// call this alpha-beta pruning.
///
/// A win counts for less the later it comes, so of two wins it takes the
/// quicker one, and it puts off a loss as long as it can.
final class SearchPass {
  /// A pass that looks `depth` moves ahead. It asks `moves` for the legal
  /// moves and who plays next, has `ranker` play and order them, scores the
  /// positions it stops at with `evaluator`, and spends `budget`.
  SearchPass({
    required this._depth,
    required this._moves,
    required this._evaluator,
    required this._ranker,
    required this._budget,
  });

  final int _depth;
  final MoveGenerator _moves;
  final PositionEvaluator _evaluator;
  final MoveRanker _ranker;
  final NodeBudget _budget;

  /// Higher than any real score, as its negative is lower than any. The search
  /// starts from these to mean "no limit yet", because any real score beats
  /// them.
  static const int _infinity = PositionEvaluator.winScore + 1;

  /// Whether every line of play so far ended before the depth ran out.
  bool _sawEveryEnding = true;

  /// The moves of [player] in [ranked], best first, scored again by looking
  /// the pass's depth ahead.
  ///
  /// When the budget runs out during the pass, the result is meaningless:
  /// check [NodeBudget.ranOut] before using it.
  PassResult rerank(List<Candidate> ranked, Player player) {
    _sawEveryEnding = true;
    final opponent = _moves.opponentOf(player);
    var bestSoFar = -_infinity;
    final rescored = <Candidate>[];
    for (final candidate in ranked) {
      final reply = _lookAhead(
        candidate.state,
        opponent,
        1,
        -_infinity,
        -bestSoFar,
      );
      final score = -reply;
      rescored.add((
        move: candidate.move,
        state: candidate.state,
        score: score,
      ));
      bestSoFar = max(bestSoFar, score);
    }
    rescored.sortBestFirst();
    return (ranked: rescored, sawEveryEnding: _sawEveryEnding);
  }

  /// The score of [state] for [player], who moves next in it, [movesPlayed]
  /// moves after the start of the pass.
  ///
  /// Two limits let it skip moves that cannot matter:
  ///
  /// - [floor] is what [player] can already get by choosing differently
  ///   earlier, so anything lower will not be chosen.
  /// - [ceiling] is the most the opponent will allow. They too can choose
  ///   differently earlier, so once [player] reaches it the opponent avoids
  ///   this position, and the remaining moves here need no look.
  ///
  /// Only a score between the two is exact. Outside them the result just shows
  /// which side it fell on, which is all the caller needs.
  int _lookAhead(
    GameState state,
    Player player,
    int movesPlayed,
    int floor,
    int ceiling,
  ) {
    // The pass will be thrown away, so stop as quickly as possible.
    if (_budget.ranOut) return 0;
    if (state.status is Finished) {
      return _finalScore(state, player, movesPlayed);
    }
    if (movesPlayed == _depth) {
      _sawEveryEnding = false;
      return _evaluator.score(state, player);
    }
    final legal = _moves.legalMoves(state);
    final candidates = _ranker.rank(state, player, legal, _budget);
    final opponent = _moves.opponentOf(player);
    var best = -_infinity;
    var secured = floor;
    for (final candidate in candidates) {
      // Seen from the opponent's side, scores are negated, so the limits swap.
      final reply = _lookAhead(
        candidate.state,
        opponent,
        movesPlayed + 1,
        -ceiling,
        -secured,
      );
      best = max(best, -reply);
      secured = max(secured, best);
      if (secured >= ceiling) break;
    }
    return best;
  }

  /// The score of the finished game [state] for [player], reached
  /// [movesPlayed] moves from now. A win counts for less the later it comes,
  /// and a loss for less the longer it is put off.
  int _finalScore(GameState state, Player player, int movesPlayed) {
    final score = _evaluator.score(state, player);
    return score > 0 ? score - movesPlayed : score + movesPlayed;
  }
}
