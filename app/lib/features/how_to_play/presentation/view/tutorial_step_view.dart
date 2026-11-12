import 'package:cephalopod/core/board/board_grid.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/how_to_play/presentation/models/tutorial_step_ui.dart';
import 'package:cephalopod/features/how_to_play/presentation/view/tutorial_text_mapper.dart';
import 'package:material_ui/material_ui.dart';

const double _spacing = 16;

/// One page of How to play: the example board, then the title and the
/// explanation of the step's topic, in the language on screen.
class TutorialStepView extends StatelessWidget {
  const TutorialStepView({
    required this.step,
    this._tutorialTextMapper = const TutorialTextMapper(),
    super.key,
  });

  final TutorialTextMapper _tutorialTextMapper;

  /// The page to draw.
  final TutorialStepUi step;

  /// The board and the text get fixed shares of the page, whatever the text
  /// says, so the board is in the same place on every page.
  static const int _boardShare = 3;
  static const int _textShare = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        children: [
          // An illustration: the text says everything a screen reader needs,
          // and its squares do nothing when tapped.
          Expanded(
            flex: _boardShare,
            child: Center(
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: BoardGrid(board: step.board, onSquareTapped: null),
                ),
              ),
            ),
          ),
          const SizedBox(height: _spacing),
          Expanded(
            flex: _textShare,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    _tutorialTextMapper.titleOf(step.topic, l10n),
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: _spacing / 2),
                  Text(
                    _tutorialTextMapper.bodyOf(step.topic, l10n),
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
