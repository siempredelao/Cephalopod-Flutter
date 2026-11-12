import 'package:cephalopod/core/board/board_ui_mapper.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/features/how_to_play/presentation/bloc/tutorial_step.dart';
import 'package:cephalopod/features/how_to_play/presentation/models/tutorial_step_ui.dart';

/// Turns a [TutorialStep] into the page How to play draws: its topic, and
/// its example as a board.
final class TutorialStepUiMapper {
  const TutorialStepUiMapper({this._boardUiMapper = const BoardUiMapper()});

  /// The example is a game between two people, since the tutorial's words
  /// name Player 1 and Player 2: black is Player 1 and white is Player 2.
  static const SideUi _black = SideUi(
    player: PlayerUi.one,
    role: RoleUi.player,
  );
  static const SideUi _white = SideUi(
    player: PlayerUi.two,
    role: RoleUi.player,
  );

  final BoardUiMapper _boardUiMapper;

  /// The page for [step]. Its example marks the squares it states, whatever
  /// the settings say, because that is what the page explains.
  TutorialStepUi map(TutorialStep step) {
    final example = step.example;
    final boardUi = _boardUiMapper.map(
      board: example.game.board,
      black: _black,
      white: _white,
      marks: example.marks,
    );
    return TutorialStepUi(topic: step.topic, board: boardUi);
  }
}
