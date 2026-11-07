import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:cephalopod/features/home/presentation/models/home_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const savedGame = HomeViewState(canContinue: true);
  const noSavedGame = HomeViewState(canContinue: false);

  group('HomeCubit', () {
    test('starts without a game to continue', () {
      final cubit = HomeCubit(hasGameToContinue: () async => true);
      addTearDown(cubit.close);

      expect(cubit.state, noSavedGame);
    });

    blocTest<HomeCubit, HomeViewState>(
      'offers to continue when there is a saved game',
      build: () => HomeCubit(hasGameToContinue: () async => true),
      act: (cubit) => cubit.refresh(),
      expect: () => [savedGame],
    );

    // Bloc skips a state equal to the current one, except the first emit.
    blocTest<HomeCubit, HomeViewState>(
      'does not offer to continue when nothing is saved',
      build: () => HomeCubit(hasGameToContinue: () async => false),
      act: (cubit) => cubit.refresh(),
      expect: () => [noSavedGame],
    );

    var saved = true;
    blocTest<HomeCubit, HomeViewState>(
      'follows the saved game each time it asks again',
      setUp: () => saved = true,
      build: () => HomeCubit(hasGameToContinue: () async => saved),
      act: (cubit) async {
        await cubit.refresh();
        saved = false;
        await cubit.refresh();
      },
      expect: () => [savedGame, noSavedGame],
    );

    test('does not emit once closed', () async {
      final cubit = HomeCubit(hasGameToContinue: () async => true);
      final refreshing = cubit.refresh();
      await cubit.close();

      await expectLater(refreshing, completes);
    });
  });
}
