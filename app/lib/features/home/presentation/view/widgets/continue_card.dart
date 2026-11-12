import 'package:cephalopod/core/board/board_thumbnail.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/home/presentation/models/saved_game_ui.dart';
import 'package:cephalopod/features/home/presentation/view/saved_game_text_mapper.dart';
import 'package:material_ui/material_ui.dart';

/// A card for the saved game: a picture of its board, who the person plays,
/// whose turn it is and each side's dice. Tapping it picks the game up.
class ContinueCard extends StatelessWidget {
  const ContinueCard({
    required this.game,
    required this.onPressed,
    this._savedGameTextMapper = const SavedGameTextMapper(),
    super.key,
  });

  final SavedGameTextMapper _savedGameTextMapper;

  final SavedGameUi game;
  final VoidCallback onPressed;

  static const double _thumbnailSize = 88;
  static const double _padding = 12;
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: _savedGameTextMapper.spokenOf(game, l10n),
      onTap: onPressed,
      excludeSemantics: true,
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: _thumbnailSize,
                  child: BoardThumbnail(board: game.board),
                ),
                const SizedBox(width: _gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeContinue, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _savedGameTextMapper.opponentOf(game, l10n),
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        _savedGameTextMapper.detailsOf(game, l10n),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
