import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';

/// Puts a page of How to play into words, in the language on screen: the
/// title and the explanation of its topic.
///
/// A text mapper (docs/adr/0015, docs/adr/0018): the page says which topic
/// it teaches; this class only puts it into words.
final class TutorialTextMapper {
  const TutorialTextMapper();

  /// The title of the page about [topic], such as "Take turns".
  String titleOf(TutorialTopic topic, AppLocalizations l10n) {
    return switch (topic) {
      TutorialTopic.takeTurns => l10n.howToPlayTakeTurnsTitle,
      TutorialTopic.placeAOne => l10n.howToPlayPlaceAOneTitle,
      TutorialTopic.captureWhenYouCan => l10n.howToPlayCaptureWhenYouCanTitle,
      TutorialTopic.dieShowsTheSum => l10n.howToPlayDieShowsTheSumTitle,
      TutorialTopic.chooseYourCapture => l10n.howToPlayChooseYourCaptureTitle,
      TutorialTopic.fillTheBoard => l10n.howToPlayFillTheBoardTitle,
    };
  }

  /// The explanation under the title of the page about [topic].
  String bodyOf(TutorialTopic topic, AppLocalizations l10n) {
    return switch (topic) {
      TutorialTopic.takeTurns => l10n.howToPlayTakeTurnsBody,
      TutorialTopic.placeAOne => l10n.howToPlayPlaceAOneBody,
      TutorialTopic.captureWhenYouCan => l10n.howToPlayCaptureWhenYouCanBody,
      TutorialTopic.dieShowsTheSum => l10n.howToPlayDieShowsTheSumBody,
      TutorialTopic.chooseYourCapture => l10n.howToPlayChooseYourCaptureBody,
      TutorialTopic.fillTheBoard => l10n.howToPlayFillTheBoardBody,
    };
  }
}
