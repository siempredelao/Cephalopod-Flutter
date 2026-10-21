import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/core/settings/app_settings.dart';
import 'package:cephalopod/core/settings/settings_cubit.dart';
import 'package:cephalopod/core/settings/theme_preference.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySettingsRepository repository;
  const dark = (theme: ThemePreference.dark, highlightLastMove: true);
  const noHighlight = (theme: ThemePreference.system, highlightLastMove: false);

  setUp(() => repository = InMemorySettingsRepository());

  SettingsCubit build() => SettingsCubit(repository: repository);

  group('SettingsCubit', () {
    test('starts with the default settings', () {
      expect(build().state, defaultSettings);
    });

    blocTest<SettingsCubit, AppSettings>(
      'loads the saved settings',
      setUp: () => repository.save(dark),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [dark],
    );

    blocTest<SettingsCubit, AppSettings>(
      'changes the theme and saves it',
      build: build,
      act: (cubit) => cubit.chooseTheme(ThemePreference.dark),
      expect: () => [dark],
      verify: (_) async => expect(await repository.load(), dark),
    );

    blocTest<SettingsCubit, AppSettings>(
      'turns the last-move highlight off and on, saving each change',
      build: build,
      act: (cubit) async {
        await cubit.toggleLastMoveHighlight();
        expect(await repository.load(), noHighlight);
        await cubit.toggleLastMoveHighlight();
      },
      expect: () => [noHighlight, defaultSettings],
      verify: (_) async => expect(await repository.load(), defaultSettings),
    );
  });
}
