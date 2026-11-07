import 'package:cephalopod/features/game/presentation/models/player_ui.dart';
import 'package:cephalopod_engine/cephalopod_engine.dart';

/// How the screen names [player]. The engine follows the rule sheet's black
/// and white, but the board shows coral and cream dice, so the screen numbers
/// the players instead: Black, who moves first by default, is Player 1.
String playerNameOf(Player player) => switch (player) {
  Player.black => 'Player 1',
  Player.white => 'Player 2',
};

/// How the screen names a numbered [player]: "Player 1" or "Player 2".
String playerUiNameOf(PlayerUi player) => switch (player) {
  PlayerUi.one => 'Player 1',
  PlayerUi.two => 'Player 2',
};
