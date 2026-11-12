import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/side_ui.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// Names one of the engine's players for the screen: its number, from its
/// colour, and its role, from who the person faces.
final class SideUiMapper {
  const SideUiMapper();

  SideUi map(Player player, Opponent opponent) {
    final playerUi = switch (player) {
      Player.black => PlayerUi.one,
      Player.white => PlayerUi.two,
    };
    final roleUi = switch (opponent) {
      FriendOpponent() => RoleUi.player,
      ComputerOpponent(player: final computer) when computer == player =>
        RoleUi.computer,
      ComputerOpponent() => RoleUi.person,
    };
    return SideUi(player: playerUi, role: roleUi);
  }
}
