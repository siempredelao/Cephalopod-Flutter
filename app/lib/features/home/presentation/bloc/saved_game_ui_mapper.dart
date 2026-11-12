import 'package:cephalopod/core/board/board_ui_mapper.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod/features/home/presentation/models/saved_game_ui.dart';

/// Turns the [SavedGameSummary] the game gives into the [SavedGameUi] Home's
/// card draws: the engine's board becomes the UI board.
final class SavedGameUiMapper {
  const SavedGameUiMapper({this._boardUiMapper = const BoardUiMapper()});

  final BoardUiMapper _boardUiMapper;

  SavedGameUi map(SavedGameSummary summary) {
    return SavedGameUi(
      board: _boardUiMapper.map(
        board: summary.board,
        black: summary.black.side,
        white: summary.white.side,
      ),
      black: summary.black,
      white: summary.white,
      computerLevel: summary.computerLevel,
    );
  }
}
