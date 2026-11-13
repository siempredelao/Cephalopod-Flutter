import 'package:cephalopod/features/review/domain/finished_game_recorder.dart';

/// A [FinishedGameRecorder] that counts in memory only, so it forgets when
/// the app closes. For tests, and as the reference the contract tests hold
/// other recorders to.
///
/// It starts with no games finished, unless [finishedGames] says how many
/// were.
FinishedGameRecorder inMemoryFinishedGameRecorder({int finishedGames = 0}) {
  var finished = finishedGames;
  return () async => ++finished;
}
