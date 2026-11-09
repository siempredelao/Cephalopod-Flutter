import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// A [MaterialApp] with the app's translations, showing [home] in
/// [locale]: English, unless the test asks for another language.
///
/// A widget that reads `context.l10n` needs one around it, as the app gives
/// every screen.
MaterialApp localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
