import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/how_to_play/data/in_memory_how_to_play_repository.dart';
import 'package:cephalopod/features/how_to_play/presentation/bloc/how_to_play_cubit.dart';
import 'package:cephalopod/features/how_to_play/presentation/bloc/tutorial_step_ui_mapper.dart';
import 'package:cephalopod/features/how_to_play/presentation/bloc/tutorial_steps.dart';
import 'package:cephalopod/features/how_to_play/presentation/models/how_to_play_view_state.dart';
import 'package:cephalopod/features/how_to_play/presentation/models/tutorial_right_button_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final steps = tutorialSteps.map(const TutorialStepUiMapper().map).toList();
  final lastStep = steps.length - 1;
  late InMemoryHowToPlayRepository repository;

  setUp(() => repository = InMemoryHowToPlayRepository());

  HowToPlayCubit buildCubit() =>
      HowToPlayCubit(howToPlayRepository: repository);

  group('HowToPlayCubit', () {
    test('remembers How to play was seen once it opened', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      expect(await repository.hasSeenHowToPlay(), isFalse);

      await cubit.opened();

      expect(await repository.hasSeenHowToPlay(), isTrue);
    });

    test("starts on the first of the tutorial's steps", () {
      expect(
        buildCubit().state,
        HowToPlayViewState(
          steps: steps,
          currentStep: 0,
          canGoBack: false,
          canSkip: true,
          rightButton: TutorialRightButtonUi.next,
        ),
      );
    });

    blocTest<HowToPlayCubit, HowToPlayViewState>(
      'follows the step on screen, which can turn back to the first',
      build: buildCubit,
      act: (cubit) => cubit.showStep(1),
      expect: () => [
        HowToPlayViewState(
          steps: steps,
          currentStep: 1,
          canGoBack: true,
          canSkip: true,
          rightButton: TutorialRightButtonUi.next,
        ),
      ],
    );

    blocTest<HowToPlayCubit, HowToPlayViewState>(
      'finishes the tutorial from the last step, with nothing left to skip',
      build: buildCubit,
      act: (cubit) => cubit.showStep(lastStep),
      expect: () => [
        HowToPlayViewState(
          steps: steps,
          currentStep: lastStep,
          canGoBack: true,
          canSkip: false,
          rightButton: TutorialRightButtonUi.finish,
        ),
      ],
    );
  });
}
