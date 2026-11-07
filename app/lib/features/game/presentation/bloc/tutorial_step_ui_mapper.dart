import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/board_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_step_ui.dart';

/// Turns a [TutorialStep] into the page How to play draws: its text, and
/// its example as a board.
final class TutorialStepUiMapper {
  const TutorialStepUiMapper({this._boardUiMapper = const BoardUiMapper()});

  final BoardUiMapper _boardUiMapper;

  /// The page for [step]. Its example is a game between two people, since
  /// the text names Player 1 and Player 2, and it always marks the last
  /// move, whatever the settings say, because that is what it explains.
  TutorialStepUi map(TutorialStep step) {
    final example = step.example;
    final boardUi = _boardUiMapper.map(
      game: example.game,
      phase: example.phase,
      lastMove: example.lastMove,
      opponent: const FriendOpponent(),
      highlightLastMove: true,
    );
    return TutorialStepUi(title: step.title, body: step.body, board: boardUi);
  }
}
