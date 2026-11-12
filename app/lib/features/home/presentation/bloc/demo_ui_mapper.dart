import 'package:cephalopod/core/board/board_ui_mapper.dart';
import 'package:cephalopod/core/board/models/board_ui.dart';
import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod/features/home/presentation/models/demo_frame_ui.dart';
import 'package:cephalopod/features/home/presentation/models/demo_ui.dart';

/// Turns a [DemoScript] into the [DemoUi] Home draws, with each frame's
/// board as a [BoardUi].
final class DemoUiMapper {
  const DemoUiMapper({this._boardUiMapper = const BoardUiMapper()});

  /// The demo is a game between two people: black is Player 1 and white is
  /// Player 2.
  static const SideUi _black = SideUi(
    player: PlayerUi.one,
    role: RoleUi.player,
  );
  static const SideUi _white = SideUi(
    player: PlayerUi.two,
    role: RoleUi.player,
  );

  final BoardUiMapper _boardUiMapper;

  DemoUi map(DemoScript script) {
    return DemoUi(
      frames: [for (final frame in script.frames) _frameOf(frame)],
      still: _frameOf(script.still),
    );
  }

  DemoFrameUi _frameOf(DemoFrame frame) {
    return DemoFrameUi(
      board: _boardUiMapper.map(
        board: frame.board,
        black: _black,
        white: _white,
        marks: frame.marks,
      ),
      hold: frame.hold,
    );
  }
}
