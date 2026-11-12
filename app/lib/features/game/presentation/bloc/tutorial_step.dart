import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A position from the rules, shown as an example: the `game` on the board,
/// and the `marks` that make squares stand out in it, such as the last move
/// or the dice a capture can take. A square without a mark does not stand
/// out.
///
/// A Dart record, so it is plain data with value equality.
typedef TutorialExample = ({
  GameState game,
  Map<Position, SquareMark> marks,
});

/// One page of the how-to-play tutorial: the [topic] it teaches, and an
/// [example] board that shows it. The words for the topic are in the
/// translation files (docs/adr/0018).
final class TutorialStep {
  const TutorialStep({required this.topic, required this.example});

  final TutorialTopic topic;
  final TutorialExample example;
}
