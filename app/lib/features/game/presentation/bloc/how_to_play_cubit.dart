import 'package:bloc/bloc.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/models/how_to_play_view_state.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_right_button_ui.dart';
import 'package:cephalopod/features/game/presentation/models/tutorial_step_ui.dart';

/// How to play's view model: maps the tutorial's steps to pages once, and
/// follows which page is on screen. It starts on the first.
class HowToPlayCubit extends Cubit<HowToPlayViewState> {
  HowToPlayCubit({
    TutorialStepUiMapper tutorialStepUiMapper = const TutorialStepUiMapper(),
  }) : super(_at(tutorialSteps.map(tutorialStepUiMapper.map).toList(), 0));

  /// The tutorial's [steps], with [step] on screen, counting from 0.
  static HowToPlayViewState _at(List<TutorialStepUi> steps, int step) {
    return HowToPlayViewState(
      steps: steps,
      currentStep: step,
      canGoBack: step > 0,
      rightButton: _rightButtonAt(step, steps.length),
    );
  }

  /// What the right button does on [step] of [stepCount]: it finishes the
  /// tutorial from the last step, and turns to the next one from any other.
  static TutorialRightButtonUi _rightButtonAt(int step, int stepCount) {
    final isLastStep = step == stepCount - 1;
    if (isLastStep) return TutorialRightButtonUi.finish;
    return TutorialRightButtonUi.next;
  }

  /// The page on screen is now [step], after a swipe or Next.
  void showStep(int step) => emit(_at(state.steps, step));
}
