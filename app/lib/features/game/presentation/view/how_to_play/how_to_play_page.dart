import 'package:cephalopod/features/game/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/game/presentation/models/how_to_play_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_button_ui.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_step_ui.dart';
import 'package:cephalopod/features/game/presentation/view/widgets/game_board.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

const double _spacing = 16;

/// How to play, one idea per page: swipe or tap Next through the tutorial's
/// steps, each with a board that shows it. It draws the
/// [HowToPlayViewState] of the [HowToPlayCubit] it creates.
class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HowToPlayCubit(),
      child: const _TutorialPages(),
    );
  }
}

/// The pages and the controls under them. The page controller is the
/// widget's own; the cubit follows which page it shows.
class _TutorialPages extends StatefulWidget {
  const _TutorialPages();

  @override
  State<_TutorialPages> createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<_TutorialPages> {
  static const Duration _turnDuration = Duration(milliseconds: 300);

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Turns to the next page, or leaves the tutorial, as [button] says.
  void _press(TutorialButtonUi button) {
    switch (button) {
      case TutorialButtonUi.next:
        _pageController.nextPage(
          duration: _turnDuration,
          curve: Curves.easeInOut,
        );
      case TutorialButtonUi.finish:
        Navigator.of(context).maybePop();
    }
  }

  /// The words on [button].
  static String _labelOf(TutorialButtonUi button) => switch (button) {
    TutorialButtonUi.next => 'Next',
    TutorialButtonUi.finish => 'Got it',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HowToPlayCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('How to play')),
      body: SafeArea(
        child: BlocBuilder<HowToPlayCubit, HowToPlayViewState>(
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: cubit.showStep,
                  children: [
                    for (final step in state.steps) _StepView(step: step),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(_spacing),
                child: Row(
                  children: [
                    _StepDots(
                      count: state.steps.length,
                      current: state.currentStep,
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _press(state.rightButton),
                      child: Text(_labelOf(state.rightButton)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One page: the example board, then the title and the explanation.
class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final TutorialStepUi step;

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
                  child: GameBoard(board: step.board, onSquareTapped: null),
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
