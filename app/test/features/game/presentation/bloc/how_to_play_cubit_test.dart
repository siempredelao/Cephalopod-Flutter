import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/game/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_step_ui_mapper.dart';
import 'package:cephalopod/features/game/presentation/bloc/tutorial_steps.dart';
import 'package:cephalopod/features/game/presentation/models/how_to_play_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final steps = tutorialSteps.map(const TutorialStepUiMapper().map).toList();
  final lastStep = steps.length - 1;

  group('HowToPlayCubit', () {
    test("starts on the first of the tutorial's steps", () {
      expect(
        HowToPlayCubit().state,
        HowToPlayViewState(steps: steps, currentStep: 0, isLastStep: false),
      );
    });

    blocTest<HowToPlayCubit, HowToPlayViewState>(
      'follows the step on screen',
      build: HowToPlayCubit.new,
      act: (cubit) => cubit.showStep(1),
      expect: () => [
        HowToPlayViewState(steps: steps, currentStep: 1, isLastStep: false),
      ],
    );

    blocTest<HowToPlayCubit, HowToPlayViewState>(
      'knows when the last step is on screen',
      build: HowToPlayCubit.new,
      act: (cubit) => cubit.showStep(lastStep),
      expect: () => [
        HowToPlayViewState(
          steps: steps,
          currentStep: lastStep,
          isLastStep: true,
        ),
      ],
    );
  });
}
