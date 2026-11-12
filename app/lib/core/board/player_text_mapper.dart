import 'package:cephalopod/core/board/models/player_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';

/// Names a numbered player: "Player 1" or "Player 2", in the language on
/// screen.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class PlayerTextMapper {
  const PlayerTextMapper();

  String map(PlayerUi player, AppLocalizations l10n) => switch (player) {
    PlayerUi.one => l10n.gamePlayerName(1),
    PlayerUi.two => l10n.gamePlayerName(2),
  };
}
