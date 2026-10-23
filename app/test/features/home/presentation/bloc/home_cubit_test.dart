import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/home/presentation/bloc/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCubit', () {
    test('starts without a game to continue', () {
      final cubit = HomeCubit(hasGameToContinue: () async => true);
      addTearDown(cubit.close);

      expect(cubit.state, isFalse);
    });

    blocTest<HomeCubit, bool>(
      'offers to continue when there is a saved game',
      build: () => HomeCubit(hasGameToContinue: () async => true),
      act: (cubit) => cubit.refresh(),
      expect: () => [true],
    );

    blocTest<HomeCubit, bool>(
      'emits nothing new when there is still no saved game',
      build: () => HomeCubit(hasGameToContinue: () async => false),
      act: (cubit) => cubit.refresh(),
      expect: () => <bool>[],
    );

    var saved = true;
    blocTest<HomeCubit, bool>(
      'follows the saved game each time it asks again',
      setUp: () => saved = true,
      build: () => HomeCubit(hasGameToContinue: () async => saved),
      act: (cubit) async {
        await cubit.refresh();
        saved = false;
        await cubit.refresh();
      },
      expect: () => [true, false],
    );

    test('does not emit once closed', () async {
      final cubit = HomeCubit(hasGameToContinue: () async => true);
      final refreshing = cubit.refresh();
      await cubit.close();

      await expectLater(refreshing, completes);
    });
  });
}
