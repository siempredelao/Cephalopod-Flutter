import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/how_to_play/presentation/view/tutorial_progress_text_mapper.dart';
import 'package:material_ui/material_ui.dart';

/// A dot per step of How to play, the [current] one highlighted. Screen
/// readers announce how far in it is.
class StepDots extends StatelessWidget {
  const StepDots({
    required this.count,
    required this.current,
    this._tutorialProgressTextMapper = const TutorialProgressTextMapper(),
    super.key,
  });

  final TutorialProgressTextMapper _tutorialProgressTextMapper;

  /// How many steps there are.
  final int count;

  /// The step on screen, counting from 0.
  final int current;

  static const double _size = 8;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: _tutorialProgressTextMapper.map(
        context.l10n,
        currentStep: current,
        stepCount: count,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _size,
        children: [
          for (var step = 0; step < count; step++)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step == current ? colors.primary : colors.outlineVariant,
              ),
              child: const SizedBox.square(dimension: _size),
            ),
        ],
      ),
    );
  }
}
