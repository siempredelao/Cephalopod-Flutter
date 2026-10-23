import 'package:cephalopod/features/game/presentation/bloc/game_view_state.dart';

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
  final GameViewState example;
}
