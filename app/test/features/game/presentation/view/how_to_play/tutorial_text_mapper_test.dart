import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_text_mapper.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/translations.dart';

void main() {
  const mapper = TutorialTextMapper();
  final languages = {'English': english, 'Spanish': spanish};

  /// The board that the tutorial shows on the page about [topic].
  TutorialExample exampleOf(TutorialTopic topic) {
    return tutorialSteps.singleWhere((step) => step.topic == topic).example;
  }

  group('TutorialTextMapper', () {
    test('words a page', () {
      const topic = TutorialTopic.captureWhenYouCan;

      expect(mapper.titleOf(topic, english), 'Capture when you can');
      expect(
        mapper.bodyOf(topic, english),
        'When two or more of those dice add up to 6 or less, you must '
        'capture them, whatever their colour.',
      );
    });

    test('speaks Spanish', () {
      const topic = TutorialTopic.captureWhenYouCan;

      expect(mapper.titleOf(topic, spanish), 'Captura cuando puedas');
      expect(
        mapper.bodyOf(topic, spanish),
        'Cuando dos o más de esos dados suman 6 o menos, debes capturarlos, '
        'sean del color que sean.',
      );
    });

    for (final MapEntry(key: language, value: l10n) in languages.entries) {
      test('gives every topic its own title and explanation in $language', () {
        final titles = {
          for (final topic in TutorialTopic.values) mapper.titleOf(topic, l10n),
        };
        final bodies = {
          for (final topic in TutorialTopic.values) mapper.bodyOf(topic, l10n),
        };

        expect(titles, hasLength(TutorialTopic.values.length));
        expect(bodies, hasLength(TutorialTopic.values.length));
        expect(titles.union(bodies), everyElement(isNotEmpty));
      });
    }

    test('translates every title and explanation', () {
      for (final topic in TutorialTopic.values) {
        expect(
          mapper.titleOf(topic, spanish),
          isNot(mapper.titleOf(topic, english)),
          reason: '${topic.name} has an English title in Spanish',
        );
        expect(
          mapper.bodyOf(topic, spanish),
          isNot(mapper.bodyOf(topic, english)),
          reason: '${topic.name} has an English explanation in Spanish',
        );
      }
    });
  });

  // The words name numbers that the example boards show. The boards are in
  // Dart and the words in the translation files, so these tests fail when
  // one changes without the other.
  group("The tutorial's words match its examples:", () {
    test('the sum is the one the capture gives', () {
      final capture = exampleOf(TutorialTopic.captureWhenYouCan);
      final choosing = capture.phase as ChoosingCapture;
      final captured = [
        for (final square in choosing.options.single)
          capture.game.board.dice[square]!.pips,
      ]..sort();
      final after = exampleOf(TutorialTopic.dieShowsTheSum);
      final newDie = after.game.board.dice[after.lastMove!.position]!;

      final sum = '${captured.join(' + ')} = ${newDie.pips}';
      for (final l10n in languages.values) {
        expect(
          mapper.bodyOf(TutorialTopic.dieShowsTheSum, l10n),
          contains(sum),
        );
      }
    });

    test('the score is the one the full board ends with', () {
      final result =
          exampleOf(TutorialTopic.fillTheBoard).game.status as Finished;
      final (winner, loser) = (result.blackDice, result.whiteDice);

      String bodyIn(AppLocalizations l10n) {
        return mapper.bodyOf(TutorialTopic.fillTheBoard, l10n);
      }

      expect(bodyIn(english), contains('Player 1 by $winner to $loser'));
      expect(bodyIn(spanish), contains('Jugador 1 por $winner a $loser'));
    });
  });
}
