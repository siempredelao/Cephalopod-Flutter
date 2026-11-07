import 'package:cephalopod/features/game/domain/models/difficulty.dart';
import 'package:cephalopod/features/game/domain/models/opponent.dart';
import 'package:cephalopod/features/game/presentation/bloc/side_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = SideUiMapper();

  group('SideUiMapper', () {
    test('numbers Black as Player 1 and White as Player 2', () {
      const friend = FriendOpponent();

      expect(
        mapper.map(Player.black, friend),
        const SideUi(player: PlayerUi.one, role: RoleUi.player),
      );
      expect(
        mapper.map(Player.white, friend),
        const SideUi(player: PlayerUi.two, role: RoleUi.player),
      );
    });

    test("names the computer's side and the person's", () {
      const computer = ComputerOpponent(
        difficulty: Difficulty.easy,
        player: Player.black,
      );

      expect(
        mapper.map(Player.black, computer),
        const SideUi(player: PlayerUi.one, role: RoleUi.computer),
      );
      expect(
        mapper.map(Player.white, computer),
        const SideUi(player: PlayerUi.two, role: RoleUi.person),
      );
    });
  });
}
