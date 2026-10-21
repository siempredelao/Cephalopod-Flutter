import 'package:cephalopod_engine/cephalopod_engine.dart';

/// How the screen names [player]. The engine follows the rule sheet's black
/// and white, but the board shows coral and cream dice, so the screen numbers
/// the players instead: Black, who moves first by default, is Player 1.
String playerNameOf(Player player) => switch (player) {
  Player.black => 'Player 1',
  Player.white => 'Player 2',
};
