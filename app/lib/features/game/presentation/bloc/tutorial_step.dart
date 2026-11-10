import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_topic.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A position from the rules, shown as an example: the `game` on the board,
/// what the screen would be waiting for in it (`phase`), and the `lastMove`,
/// if any, to mark.
///
/// A Dart record, so it is plain data with value equality.
typedef TutorialExample = ({GameState game, TurnPhase phase, Move? lastMove});

/// One page of the how-to-play tutorial: the [topic] it teaches, and an
/// [example] board that shows it. The words for the topic are in the
/// translation files (docs/adr/0018).
final class TutorialStep {
  const TutorialStep({required this.topic, required this.example});

  final TutorialTopic topic;
  final TutorialExample example;
}
