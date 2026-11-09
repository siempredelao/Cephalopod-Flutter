import 'package:cephalopod/core/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// The app's words in English, for tests that need them without a widget,
/// such as a text mapper's.
final AppLocalizations english = lookupAppLocalizations(const Locale('en'));

/// The app's words in Spanish, as English's [english].
final AppLocalizations spanish = lookupAppLocalizations(const Locale('es'));
