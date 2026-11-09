import 'package:cephalopod/core/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

export 'package:cephalopod/core/l10n/generated/app_localizations.dart';

/// Every translation the app needs: its own words, and the ones Flutter's
/// widgets show, such as the back button's tooltip.
///
/// Flutter's come from `material_ui` (docs/adr/0007), not from the
/// `localizationsDelegates` that gen-l10n writes: those are for
/// `package:flutter/material.dart`, whose widgets the app does not use.
const List<LocalizationsDelegate<Object?>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// The app's words in the language on screen, as `context.l10n.homeNewGame`.
///
/// The words live in `app_en.arb` and `app_es.arb`, next to this file;
/// `flutter gen-l10n` turns them into [AppLocalizations] (docs/adr/0017).
extension AppLocalizationsOfContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
