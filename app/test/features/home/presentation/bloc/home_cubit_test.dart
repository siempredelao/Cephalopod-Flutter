import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_script.dart';
import 'package:cephalopod/features/home/presentation/bloc/demo_ui_mapper.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const savedGame = HomeViewState(canContinue: true);
  const noSavedGame = HomeViewState(canContinue: false);

  group('HomeCubit', () {
    test('starts without a game to continue', () {
      final cubit = HomeCubit(
        hasGameToContinue: () async => true,
        hasSeenHowToPlay: () async => true,
      );
      addTearDown(cubit.close);

      expect(cubit.state, noSavedGame);
    });

    test('has the demo Home plays', () {
      final cubit = HomeCubit(
        hasGameToContinue: () async => true,
        hasSeenHowToPlay: () async => true,
      );
      addTearDown(cubit.close);

      expect(cubit.demo, const DemoUiMapper().map(homeDemoScript));
    });

    blocTest<HomeCubit, HomeViewState>(
      'offers to continue when there is a saved game',
      build: () => HomeCubit(
        hasGameToContinue: () async => true,
        hasSeenHowToPlay: () async => true,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [savedGame],
    );

    // Bloc skips a state equal to the current one, except the first emit.
    blocTest<HomeCubit, HomeViewState>(
      'does not offer to continue when nothing is saved',
      build: () => HomeCubit(
        hasGameToContinue: () async => false,
        hasSeenHowToPlay: () async => true,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [noSavedGame],
    );

    var saved = true;
    blocTest<HomeCubit, HomeViewState>(
      'follows the saved game each time it asks again',
      setUp: () => saved = true,
      build: () => HomeCubit(
        hasGameToContinue: () async => saved,
        hasSeenHowToPlay: () async => true,
      ),
      act: (cubit) async {
        await cubit.refresh();
        saved = false;
        await cubit.refresh();
      },
      expect: () => [savedGame, noSavedGame],
    );

    group('on a first launch', () {
      var askedAboutHowToPlay = 0;

      HomeCubit buildFirstLaunch() {
        askedAboutHowToPlay = 0;
        return HomeCubit(
          hasGameToContinue: () async => false,
          hasSeenHowToPlay: () async {
            askedAboutHowToPlay++;
            return false;
          },
        );
      }

      blocTest<HomeCubit, HomeViewState>(
        'opens How to play',
        build: buildFirstLaunch,
        act: (cubit) => cubit.refresh(),
        expect: () => [noSavedGame.copyWith(showHowToPlay: true)],
      );

      blocTest<HomeCubit, HomeViewState>(
        'opens it once, and asks only the first time',
        build: buildFirstLaunch,
        act: (cubit) async {
          await cubit.refresh();
          cubit.howToPlayOpened();
          await cubit.refresh();
        },
        expect: () => [noSavedGame.copyWith(showHowToPlay: true), noSavedGame],
        verify: (_) => expect(askedAboutHowToPlay, 1),
      );
    });

    blocTest<HomeCubit, HomeViewState>(
      'does not open How to play once it was seen',
      build: () => HomeCubit(
        hasGameToContinue: () async => true,
        hasSeenHowToPlay: () async => true,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => [savedGame],
    );

    test('does not emit once closed', () async {
      final cubit = HomeCubit(
        hasGameToContinue: () async => true,
        hasSeenHowToPlay: () async => true,
      );
      final refreshing = cubit.refresh();
      await cubit.close();

      await expectLater(refreshing, completes);
    });
  });
}
