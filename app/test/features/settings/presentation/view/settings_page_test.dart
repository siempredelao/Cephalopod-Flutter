import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/domain/settings_store.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  late SettingsStore store;
  late SettingsCubit cubit;

  Future<void> pumpSettings(WidgetTester tester) async {
    store = SettingsStore(settingsRepository: InMemorySettingsRepository());
    await tester.pumpWidget(
      localizedApp(
        SettingsPage(
          createCubit: () => cubit = SettingsCubit(settingsStore: store),
        ),
      ),
    );
  }

  final highlightSwitch = find.widgetWithText(
    SwitchListTile,
    'Highlight the last move',
  );
  final soundSwitch = find.widgetWithText(SwitchListTile, 'Sound');

  group('SettingsPage', () {
    testWidgets('chooses the theme', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(cubit.state.theme, ThemeUi.dark);
    });

    testWidgets('turns the last-move highlight off', (tester) async {
      await pumpSettings(tester);
      expect(cubit.state.highlightLastMove, isTrue);

      await tester.tap(highlightSwitch);
      await tester.pumpAndSettle();

      expect(cubit.state.highlightLastMove, isFalse);
      expect(tester.widget<SwitchListTile>(highlightSwitch).value, isFalse);
      expect(tester.widget<SwitchListTile>(soundSwitch).value, isTrue);
    });

    testWidgets('turns sounds off', (tester) async {
      await pumpSettings(tester);
      expect(cubit.state.sound, isTrue);

      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();

      expect(cubit.state.sound, isFalse);
      expect(tester.widget<SwitchListTile>(soundSwitch).value, isFalse);
      expect(tester.widget<SwitchListTile>(highlightSwitch).value, isTrue);
    });

    testWidgets('closes its cubit when it leaves the screen', (tester) async {
      await pumpSettings(tester);

      await tester.pumpWidget(const SizedBox());

      expect(cubit.isClosed, isTrue);
    });
  });
}
