import 'package:cephalopod/features/review/data/in_memory_finished_game_recorder.dart';
import 'package:cephalopod/features/review/domain/review_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

/// A recorder that cannot keep the count, as a broken store answers.
Future<int> _forgetfulRecorder() async => 0;

void main() {
  var requests = 0;

  setUp(() => requests = 0);

  Future<void> requestReview() async => requests++;

  /// The games after which a review was asked for, out of [games] finished
  /// one after another.
  Future<List<int>> gamesAskedAfter(ReviewPrompt prompt, int games) async {
    final asked = <int>[];
    for (var game = 1; game <= games; game++) {
      final before = requests;
      await prompt.afterFinishedGame();
      if (requests > before) asked.add(game);
    }
    return asked;
  }

  group('ReviewPrompt', () {
    test(
      'asks after the third game and after the tenth, and never more',
      () async {
        final prompt = ReviewPrompt(
          recordFinishedGame: inMemoryFinishedGameRecorder(),
          requestReview: requestReview,
        );

        expect(await gamesAskedAfter(prompt, 30), [3, 10]);
      },
    );

    test('goes on counting from the games finished before', () async {
      final prompt = ReviewPrompt(
        recordFinishedGame: inMemoryFinishedGameRecorder(finishedGames: 9),
        requestReview: requestReview,
      );

      expect(await gamesAskedAfter(prompt, 3), [1]);
    });

    test('never asks when the count cannot be kept', () async {
      final prompt = ReviewPrompt(
        recordFinishedGame: _forgetfulRecorder,
        requestReview: requestReview,
      );

      expect(await gamesAskedAfter(prompt, 30), isEmpty);
    });
  });
}
