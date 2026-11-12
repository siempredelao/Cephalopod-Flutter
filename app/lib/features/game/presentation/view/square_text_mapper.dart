import 'package:cephalopod/core/board/models/role_ui.dart';
import 'package:cephalopod/core/board/models/square_mark.dart';
import 'package:cephalopod/core/board/models/square_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/view/player_text_mapper.dart';

/// Words what screen readers announce for a square, in the language on
/// screen: where it is, counting rows and columns from 1, what is on it,
/// and what a hint says about it, when one does.
///
/// Whose die it is changes the whole sentence ("your die", "the computer's
/// die"), so each owner has a message of its own rather than a word slotted
/// into one: languages do not all build those phrases the same way.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class SquareTextMapper {
  const SquareTextMapper({this._playerTextMapper = const PlayerTextMapper()});

  final PlayerTextMapper _playerTextMapper;

  /// "Row 2, column 3, Player 1 die showing 5", "Row 2, column 3, your die
  /// showing 5", or "Row 1, column 3, empty", followed by what a hint says
  /// about the square, if one does: "Row 1, column 3, empty. Hint: place
  /// your die here".
  String map(SquareUi square, AppLocalizations l10n) {
    final words = _contentOf(square, l10n);
    return switch (square.mark) {
      SquareMark.hintTarget => l10n.gameSquareHintTarget(words),
      SquareMark.hintCapture => l10n.gameSquareHintCapture(words),
      _ => words,
    };
  }

  /// Where [square] is, and what is on it.
  String _contentOf(SquareUi square, AppLocalizations l10n) {
    final row = square.row + 1;
    final column = square.col + 1;
    final die = square.die;
    if (die == null) return l10n.gameSquareEmpty(row, column);
    return switch (die.owner.role) {
      RoleUi.player => l10n.gameSquarePlayerDie(
        row,
        column,
        _playerTextMapper.map(die.owner.player, l10n),
        die.pips,
      ),
      RoleUi.person => l10n.gameSquareYourDie(row, column, die.pips),
      RoleUi.computer => l10n.gameSquareComputerDie(row, column, die.pips),
    };
  }
}
