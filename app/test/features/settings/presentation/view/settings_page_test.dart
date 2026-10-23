import 'package:cephalopod/core/settings/models/theme_preference.dart';
import 'package:cephalopod/core/settings/settings_cubit.dart';
import 'package:cephalopod/features/settings/data/in_memory_settings_repository.dart';
import 'package:cephalopod/features/settings/presentation/view/settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late SettingsCubit cubit;

  Future<void> pumpSettings(WidgetTester tester) async {
    cubit = SettingsCubit(repository: InMemorySettingsRepository());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const SettingsPage()),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('chooses the theme', (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(cubit.state.theme, ThemePreference.dark);
    });

    testWidgets('turns the last-move highlight off', (tester) async {
      await pumpSettings(tester);
      expect(cubit.state.highlightLastMove, isTrue);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(cubit.state.highlightLastMove, isFalse);
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isFalse);
    });
  });
}
