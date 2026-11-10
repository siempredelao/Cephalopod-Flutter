import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/game/presentation/models/how_to_play_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_right_button_ui.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_step_ui.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/step_dots.dart';
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

  /// Turns to the next page, or leaves the tutorial, as [rightButton] says.
  void _pressRightButton(TutorialRightButtonUi rightButton) {
    switch (rightButton) {
      case TutorialRightButtonUi.next:
        _pageController.nextPage(
          duration: _turnDuration,
          curve: Curves.easeInOut,
        );
      case TutorialRightButtonUi.finish:
        Navigator.of(context).maybePop();
    }
  }

  /// The words on [rightButton], in the language on screen.
  static String _rightButtonLabelOf(
    TutorialRightButtonUi rightButton,
    AppLocalizations l10n,
  ) {
    return switch (rightButton) {
      TutorialRightButtonUi.next => l10n.howToPlayNext,
      TutorialRightButtonUi.finish => l10n.howToPlayDone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HowToPlayCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.howToPlayTitle)),
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
                    StepDots(
                      count: state.steps.length,
                      current: state.currentStep,
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _pressRightButton(state.rightButton),
                      child: Text(
                        _rightButtonLabelOf(state.rightButton, context.l10n),
                      ),
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
