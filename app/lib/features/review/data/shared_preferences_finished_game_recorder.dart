import 'package:cephalopod/core/errors/error_reporter.dart';
import 'package:cephalopod/features/review/domain/finished_game_recorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The one key the count is kept under.
const String _finishedGamesKey = 'finishedGames';

/// A [FinishedGameRecorder] on shared_preferences (docs/adr/0012), with one
/// key for the count.
///
/// Storage never stops the app (docs/adr/0016). When shared_preferences
/// fails, the error goes to [errorReporter], the app goes on, and the
/// answer is 0, which is never a time to ask for a review.
///
/// Only `Exception`s are caught, which is how storage reports a failure. An
/// `Error` is a bug, so it goes on to the app-wide error reporting.
FinishedGameRecorder sharedPreferencesFinishedGameRecorder({
  required SharedPreferencesAsync sharedPreferencesAsync,
  required ErrorReporter errorReporter,
}) {
  return () async {
    try {
      final before = await sharedPreferencesAsync.getInt(_finishedGamesKey);
      final finished = (before ?? 0) + 1;
      await sharedPreferencesAsync.setInt(_finishedGamesKey, finished);
      return finished;
    } on Exception catch (error, stackTrace) {
      errorReporter(error, stackTrace, reason: 'counting a finished game');
      return 0;
    }
  };
}
