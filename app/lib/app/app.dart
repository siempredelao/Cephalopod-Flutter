import 'package:cephalopod/app/flavor.dart';
import 'package:cephalopod/app/theme.dart';
import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:cephalopod/core/l10n/locale_resolution.dart';
import 'package:cephalopod/features/settings/domain/models/app_settings.dart';
import 'package:cephalopod/features/settings/domain/models/theme_preference.dart';
import 'package:cephalopod/features/settings/domain/settings_store.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget. It receives everything it needs, so tests can build it with
/// any router, flavor and settings.
///
/// Its theme follows the [settings] store as they change.
class App extends StatelessWidget {
  const App({
    required this.flavor,
    required this.router,
    required this.settings,
    super.key,
  });

  final Flavor flavor;
  final GoRouter router;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: settings.changes,
      initialData: settings.current,
      builder: (context, snapshot) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle,
        // English first, so a phone in a language the app lacks gets English.
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveAppLocale,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _modeOf((snapshot.data ?? settings.current).theme),
        routerConfig: router,
        debugShowCheckedModeBanner: flavor == Flavor.dev,
      ),
    );
  }

  static ThemeMode _modeOf(ThemePreference theme) => switch (theme) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
