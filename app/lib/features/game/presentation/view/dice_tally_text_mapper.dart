import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod/features/game/presentation/models/role_ui.dart';
import 'package:cephalopod/features/game/presentation/models/side_ui.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';

/// Words the dice count above the board, in the language on screen: each
/// side's name, and what a screen reader says for the whole count.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class DiceTallyTextMapper {
  const DiceTallyTextMapper({
    this._playerTextMapper = const PlayerTextMapper(),
  });

  final PlayerTextMapper _playerTextMapper;

  /// "Player 1" between two people; "You" or "Computer" against the
  /// computer.
  String nameOf(SideUi side, AppLocalizations l10n) => switch (side.role) {
    RoleUi.player => _playerTextMapper.map(side.player, l10n),
    RoleUi.person => l10n.gameTallyYou,
    RoleUi.computer => l10n.gameTallyComputer,
  };

  /// "You: 7 dice. Computer: 1 die.", Player 1's side first.
  String spoken(DiceTallyUi tally, AppLocalizations l10n) {
    String sideOf(SideTallyUi side) =>
        l10n.gameTallySide(nameOf(side.side, l10n), side.dice);
    return l10n.gameTallySpoken(
      sideOf(tally.playerOne),
      sideOf(tally.playerTwo),
    );
  }
}
