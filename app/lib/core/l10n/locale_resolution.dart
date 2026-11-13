import 'package:material_ui/material_ui.dart';

/// The language Norwegian phones are given: Bokmål, the written form most
/// Norwegians use.
const String _bokmal = 'nb';

/// The codes phones use for Norwegian, which the app has one translation for.
///
/// `no` is Norwegian in general and `nn` is Nynorsk, its other written form.
/// Bokmål is the one the app translates, so a phone that says either of
/// them is given it, rather than English.
const Set<String> _norwegianCodes = {'no', 'nn'};

/// Picks the app's language from the phone's, as Flutter does, except that
/// Norwegian as `no` or `nn` becomes Bokmål, `nb`, when the app speaks it.
///
/// A phone in a language the app does not speak gets the first of
/// [supportedLocales], English.
Locale resolveAppLocale(
  List<Locale>? phoneLocales,
  Iterable<Locale> supportedLocales,
) {
  return basicLocaleListResolution([
    for (final locale in phoneLocales ?? const <Locale>[]) _asBokmal(locale),
  ], supportedLocales);
}

/// [locale], as Bokmål if it is another way of saying Norwegian.
Locale _asBokmal(Locale locale) {
  if (!_norwegianCodes.contains(locale.languageCode)) return locale;
  return Locale(_bokmal, locale.countryCode);
}
