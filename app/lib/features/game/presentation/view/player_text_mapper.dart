import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/player_ui.dart';

/// Names a numbered player: "Player 1" or "Player 2", in the language on
/// screen.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class PlayerTextMapper {
  const PlayerTextMapper();

  String map(PlayerUi player, AppLocalizations l10n) => switch (player) {
    PlayerUi.one => l10n.playerName(1),
    PlayerUi.two => l10n.playerName(2),
  };
}
