import 'package:cephalopod/features/game/presentation/view/how_to_play/models/tutorial_step.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:material_ui/material_ui.dart';

const double _spacing = 16;

/// How to play, one idea per page: swipe or tap Next through
/// [tutorialSteps], each with a board that shows it.
class HowToPlayPage extends StatefulWidget {
  const HowToPlayPage({super.key});

  @override
  State<HowToPlayPage> createState() => _HowToPlayPageState();
}

class _HowToPlayPageState extends State<HowToPlayPage> {
  static const Duration _turnDuration = Duration(milliseconds: 300);

  final PageController _pages = PageController();
  int _current = 0;

  bool get _onLastStep => _current == tutorialSteps.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Turns to the next page, or leaves the tutorial from the last one.
  void _next() {
    if (_onLastStep) {
      Navigator.of(context).maybePop();
      return;
    }
    _pages.nextPage(duration: _turnDuration, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to play')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _current = page),
                children: [
                  for (final step in tutorialSteps) _StepView(step: step),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(_spacing),
              child: Row(
                children: [
                  _StepDots(count: tutorialSteps.length, current: _current),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_onLastStep ? 'Got it' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One page: the example board, then the title and the explanation.
class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final TutorialStep step;

  /// The board and the text get fixed shares of the page, whatever the text
  /// says, so the board is in the same place on every page.
  static const int _boardShare = 3;
  static const int _textShare = 2;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                  child: GameBoard(state: step.example, onSquareTapped: (_) {}),
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
                    step.title,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: _spacing / 2),
                  Text(
                    step.body,
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

/// A dot per page, the current one highlighted.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.current});

  final int count;
  final int current;

  static const double _size = 8;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Step ${current + 1} of $count',
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
