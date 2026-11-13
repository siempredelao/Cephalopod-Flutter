import 'package:cephalopod/features/review/domain/finished_game_recorder.dart';
import 'package:cephalopod/features/review/domain/review_policy.dart';
import 'package:cephalopod/features/review/domain/review_requester.dart';

/// What the app does when a game ends: it counts the game, and asks the
/// store for a review if this is a time to ask (see [isTimeToAskForReview]).
final class ReviewPrompt {
  ReviewPrompt({
    required this._recordFinishedGame,
    required this._requestReview,
  });

  final FinishedGameRecorder _recordFinishedGame;
  final ReviewRequester _requestReview;

  /// Counts the game that just finished, and asks for a review if it is
  /// time to.
  Future<void> afterFinishedGame() async {
    final finished = await _recordFinishedGame();
    if (isTimeToAskForReview(finished)) await _requestReview();
  }
}
