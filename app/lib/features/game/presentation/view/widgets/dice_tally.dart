import 'package:cephalopod/core/board/models/die_ui.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/models/dice_tally_ui.dart';
import 'package:cephalopod/features/game/presentation/view/dice_tally_text_mapper.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/die_face.dart';
import 'package:material_ui/material_ui.dart';

/// How many dice each side has on the board: a chip per side, Player 1's
/// first, each with a small die in the side's colour, its name and its
/// count. The side to move stands out.
///
/// Screen readers hear the whole count as one sentence. It is not a live
/// region: the headline already announces each turn.
class DiceTally extends StatelessWidget {
  const DiceTally({
    required this.tally,
    this._diceTallyTextMapper = const DiceTallyTextMapper(),
    super.key,
  });

  final DiceTallyTextMapper _diceTallyTextMapper;

  final DiceTallyUi tally;

  static const double _spacing = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      label: _diceTallyTextMapper.spoken(tally, l10n),
      excludeSemantics: true,
      // A Wrap, so with large text the second chip goes under the first
      // rather than off the screen.
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: _spacing,
        runSpacing: _spacing / 2,
        children: [
          for (final side in [tally.playerOne, tally.playerTwo])
            _SideChip(
              side: side,
              name: _diceTallyTextMapper.nameOf(side.side, l10n),
            ),
        ],
      ),
    );
  }
}

/// One side's count: its die, [name] and number of dice, with a filled
/// background and a stronger outline while it is the side to move.
class _SideChip extends StatelessWidget {
  const _SideChip({required this.side, required this.name});

  final SideTallyUi side;
  final String name;

  static const double _dieSize = 20;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final toMove = side.toMove;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: toMove ? colors.secondaryContainer : null,
        shape: StadiumBorder(
          side: toMove
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            SizedBox.square(
              dimension: _dieSize,
              child: DieFace(die: DieUi(pips: 1, owner: side.side)),
            ),
            Text(name, style: theme.textTheme.labelLarge),
            Text(
              '${side.dice}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                // Every digit the same width, so the chip keeps its size
                // as the count changes.
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
