import 'dart:async';

import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/features/game/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/game/presentation/models/how_to_play_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_right_button_ui.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/step_dots.dart';
import 'package:cephalopod/features/game/presentation/view/how_to_play/tutorial_step_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

const double _spacing = 16;

/// How to play, one idea per page: swipe, or tap Next and Previous, through
/// the tutorial's steps, each with a board that shows it. It draws the
/// [HowToPlayViewState] of the [HowToPlayCubit] it gets from [createCubit],
/// and tells the cubit it opened.
class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({required this.createCubit, super.key});

  /// Builds the screen's cubit. The composition root wires it to the
  /// device's storage; tests wire it to memory.
  final HowToPlayCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = createCubit();
        unawaited(cubit.opened());
        return cubit;
      },
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

  void _turnBack() {
    _pageController.previousPage(
      duration: _turnDuration,
      curve: Curves.easeInOut,
    );
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
        _leave();
    }
  }

  /// Leaves the tutorial, from its last page or by skipping the rest.
  void _leave() => Navigator.of(context).maybePop();

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
      appBar: AppBar(
        title: Text(context.l10n.howToPlayTitle),
        actions: [
          // Skip, on every page but the last, where Done leaves too.
          BlocSelector<HowToPlayCubit, HowToPlayViewState, bool>(
            selector: (state) => state.canSkip,
            builder: (context, canSkip) => canSkip
                ? TextButton(
                    onPressed: _leave,
                    child: Text(context.l10n.howToPlaySkip),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HowToPlayCubit, HowToPlayViewState>(
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: cubit.showStep,
                  children: [
                    for (final step in state.steps)
                      TutorialStepView(step: step),
                  ],
                ),
              ),
              // The dots on a row of their own, centred, and the buttons
              // under them: Previous on the left, from the second page on,
              // and Next or Done on the right, which stays put either way:
              // on the first page an empty space holds Previous's place.
              Padding(
                padding: const EdgeInsets.all(_spacing),
                child: Column(
                  spacing: _spacing,
                  children: [
                    StepDots(
                      count: state.steps.length,
                      current: state.currentStep,
                    ),
                    // Each button may take up to half the row, and its words
                    // wrap rather than overflow when they need more, as in
                    // Spanish with large text.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: _spacing,
                      children: [
                        Flexible(
                          child: state.canGoBack
                              ? OutlinedButton(
                                  onPressed: _turnBack,
                                  child: Text(context.l10n.howToPlayPrevious),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Flexible(
                          child: FilledButton(
                            onPressed: () =>
                                _pressRightButton(state.rightButton),
                            child: Text(
                              _rightButtonLabelOf(
                                state.rightButton,
                                context.l10n,
                              ),
                            ),
                          ),
                        ),
                      ],
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
