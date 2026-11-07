import 'package:cephalopod/features/game/presentation/bloc/turn_phase.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A position from the rules, shown as an example: the [game] on the board,
/// what the screen would be waiting for in it ([phase]), and the [lastMove],
/// if any, to mark.
///
/// A Dart record, so it is plain data with value equality.
typedef TutorialExample = ({GameState game, TurnPhase phase, Move? lastMove});

/// One page of the how-to-play tutorial: a [title], a short explanation in
/// [body], and an [example] board that shows it.
final class TutorialStep {
  const TutorialStep({
    required this.title,
    required this.body,
    required this.example,
  });

  final String title;
  final String body;
  final TutorialExample example;
}
