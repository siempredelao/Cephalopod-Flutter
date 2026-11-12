import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/core/saved_game/saved_game_summary.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// A saved game against the computer on the Hard level, one move in, for
/// tests that need Home to have a game to continue.
final SavedGameSummary savedGameSummary = SavedGameSummary(
  board: Board(
    size: 3,
    dice: {const Position(1, 1): const Die(owner: Player.black, pips: 1)},
  ),
  black: (
    side: const SideUi(player: PlayerUi.one, role: RoleUi.person),
    dice: 1,
    toMove: false,
  ),
  white: (
    side: const SideUi(player: PlayerUi.two, role: RoleUi.computer),
    dice: 0,
    toMove: true,
  ),
  computerLevel: ComputerLevel.hard,
);
