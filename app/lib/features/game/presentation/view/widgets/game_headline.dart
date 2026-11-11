import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/computer_move_ui.dart';
import 'package:cephalopod/features/game/presentation/models/headline_ui.dart';
import 'package:cephalopod/features/game/presentation/view/headline_text_mapper.dart';
import 'package:cephalopod/features/game/presentation/view/spoken_headline_text_mapper.dart';
import 'package:material_ui/material_ui.dart';

/// The line above the board: whose turn it is, or who won.
///
/// It is a live region: a screen reader says it again whenever it changes,
/// so the player hears whose turn it is, and what the computer did, without
/// searching the screen. What it says is a little more than what is written:
/// the [computerMove] that led here, if there is one, comes first.
class GameHeadline extends StatelessWidget {
  const GameHeadline({
    required this.headline,
    required this.computerMove,
    this._headlineTextMapper = const HeadlineTextMapper(),
    this._spokenHeadlineTextMapper = const SpokenHeadlineTextMapper(),
    super.key,
  });

  final HeadlineTextMapper _headlineTextMapper;
  final SpokenHeadlineTextMapper _spokenHeadlineTextMapper;

  /// What the line is about.
  final HeadlineUi headline;

  /// The move the computer just played, which a screen reader says first.
  final ComputerMoveUi? computerMove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      label: _spokenHeadlineTextMapper.map(headline, computerMove, l10n),
      excludeSemantics: true,
      child: Text(
        _headlineTextMapper.map(headline, l10n),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
