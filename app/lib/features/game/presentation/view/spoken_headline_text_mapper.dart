import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/models/hint_ui.dart';
import 'package:cephalopod/features/game/presentation/view/headline_text_mapper.dart';

/// Words the line above the board for a screen reader, in the language on
/// screen: the headline as it is written, and before it, right after the
/// computer moved, what the computer did, or, once a hint is found, the
/// hint.
///
/// One sentence rather than two announcements, because a screen reader that
/// gets a second one while it speaks the first cuts the first off.
///
/// A text mapper (docs/adr/0015): UI model in, words out.
final class SpokenHeadlineTextMapper {
  const SpokenHeadlineTextMapper({
    this._headlineTextMapper = const HeadlineTextMapper(),
  });

  final HeadlineTextMapper _headlineTextMapper;

  /// The words for [headline], such as "Your turn"; when [computerMove] is
  /// given, "The computer placed a 3 at row 2, column 4. Your turn"; and
  /// when [hint] is, "Hint: place your die at row 1, column 3, capturing 2
  /// dice. Your turn". Rows and columns count from 1.
  String map(
    HeadlineUi headline,
    ComputerMoveUi? computerMove,
    AppLocalizations l10n, {
    HintUi? hint,
  }) {
    final words = _headlineTextMapper.map(headline, l10n);
    if (hint != null) {
      return l10n.gameHeadlineWithHint(
        hint.row + 1,
        hint.col + 1,
        hint.captures,
        words,
      );
    }
    if (computerMove == null) return words;
    return l10n.gameHeadlineAfterComputerMove(
      computerMove.pips,
      computerMove.row + 1,
      computerMove.col + 1,
      words,
    );
  }
}
