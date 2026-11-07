import 'package:cephalopod/features/game/presentation/models/player_ui.dart';

/// How the screen names a numbered [player]: "Player 1" or "Player 2".
String playerUiNameOf(PlayerUi player) => switch (player) {
  PlayerUi.one => 'Player 1',
  PlayerUi.two => 'Player 2',
};
