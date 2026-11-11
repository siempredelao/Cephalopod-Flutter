import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_view_state_mapper.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = SettingsViewStateMapper();

  group('SettingsViewStateMapper', () {
    test('shows the default settings', () {
      expect(
        mapper.map(defaultSettings),
        const SettingsViewState(
          theme: ThemeUi.system,
          highlightLastMove: true,
          sound: true,
        ),
      );
    });

    test('shows every theme as itself', () {
      for (final theme in ThemePreference.values) {
        final settings = (theme: theme, highlightLastMove: true, sound: true);

        expect(mapper.map(settings).theme.name, theme.name);
      }
    });

    test('reads every theme back as itself', () {
      for (final theme in ThemePreference.values) {
        final shown = mapper.map((
          theme: theme,
          highlightLastMove: true,
          sound: true,
        )).theme;

        expect(mapper.themePreferenceOf(shown), theme);
      }
    });

    test('shows the last-move highlight turned off', () {
      const settings = (
        theme: ThemePreference.dark,
        highlightLastMove: false,
        sound: true,
      );

      expect(mapper.map(settings).highlightLastMove, isFalse);
    });

    test('shows sounds turned off', () {
      const settings = (
        theme: ThemePreference.system,
        highlightLastMove: true,
        sound: false,
      );

      expect(mapper.map(settings).sound, isFalse);
    });
  });
}
