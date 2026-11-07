import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/theme.dart';
import 'package:cephalopod/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:cephalopod/features/settings/presentation/models/settings_view_state.dart';
import 'package:cephalopod/features/settings/presentation/models/theme_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget. It receives everything it needs, so tests can build it with
/// any router, flavor and settings.
///
/// It provides [settings] to the whole app, and follows its theme choice.
class App extends StatelessWidget {
  const App({
    required this.flavor,
    required this.router,
    required this.settings,
    super.key,
  });

  final Flavor flavor;
  final GoRouter router;
  final SettingsCubit settings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: settings,
      child: BlocBuilder<SettingsCubit, SettingsViewState>(
        builder: (context, current) => MaterialApp.router(
          title: 'Cephalopod',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _modeOf(current.theme),
          routerConfig: router,
          debugShowCheckedModeBanner: flavor == Flavor.dev,
        ),
      ),
    );
  }

  static ThemeMode _modeOf(ThemeUi theme) => switch (theme) {
    ThemeUi.system => ThemeMode.system,
    ThemeUi.light => ThemeMode.light,
    ThemeUi.dark => ThemeMode.dark,
  };
}
