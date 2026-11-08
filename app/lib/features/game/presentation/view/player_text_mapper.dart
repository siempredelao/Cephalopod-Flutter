import 'package:cephalopod/features/game/presentation/models/player_ui.dart';

/// Names a numbered player: "Player 1" or "Player 2".
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class PlayerTextMapper {
  const PlayerTextMapper();

  String map(PlayerUi player) => switch (player) {
    PlayerUi.one => 'Player 1',
    PlayerUi.two => 'Player 2',
  };
}
