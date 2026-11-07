import 'package:bloc_test/bloc_test.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_view_state_mapper.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySettingsRepository repository;
  const dark = (theme: ThemePreference.dark, highlightLastMove: true);
  const noHighlight = (theme: ThemePreference.system, highlightLastMove: false);

  setUp(() => repository = InMemorySettingsRepository());

  SettingsCubit build() => SettingsCubit(settingsRepository: repository);

  /// What the settings page shows of [settings].
  SettingsViewState screenOf(AppSettings settings) {
    return const SettingsViewStateMapper().map(settings);
  }

  group('SettingsCubit', () {
    test('starts with the default settings', () {
      final cubit = build();

      expect(cubit.state, screenOf(defaultSettings));
      expect(cubit.settings, defaultSettings);
    });

    blocTest<SettingsCubit, SettingsViewState>(
      'loads the saved settings',
      setUp: () => repository.save(dark),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [screenOf(dark)],
      verify: (cubit) => expect(cubit.settings, dark),
    );

    blocTest<SettingsCubit, SettingsViewState>(
      'changes the theme and saves it',
      build: build,
      act: (cubit) => cubit.chooseTheme(ThemeUi.dark),
      expect: () => [screenOf(dark)],
      verify: (_) async => expect(await repository.load(), dark),
    );

    test('chooses every theme as itself', () async {
      final cubit = build();
      addTearDown(cubit.close);

      for (final theme in ThemeUi.values) {
        await cubit.chooseTheme(theme);

        expect(cubit.settings.theme.name, theme.name);
      }
    });

    blocTest<SettingsCubit, SettingsViewState>(
      'turns the last-move highlight off and on, saving each change',
      build: build,
      act: (cubit) async {
        await cubit.toggleLastMoveHighlight();
        expect(await repository.load(), noHighlight);
        await cubit.toggleLastMoveHighlight();
      },
      expect: () => [screenOf(noHighlight), screenOf(defaultSettings)],
      verify: (_) async => expect(await repository.load(), defaultSettings),
    );
  });
}
