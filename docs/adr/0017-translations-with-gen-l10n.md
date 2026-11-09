# 0017. Translations with gen-l10n, English by default

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

M5 brings the app to English and Spanish, and more languages may follow.
Every word on screen was written into the widgets and the text mappers in
English. The player should get their device's language when the app speaks
it, and English otherwise, without a choice to make in Settings.

The app takes its Material widgets from `material_ui`
([ADR 0007](0007-material-ui-package.md)), which brings its own copy of
Flutter's translations, such as the back button's tooltip.

## Decision

Flutter's own tool, `gen-l10n`, turns one `.arb` file per language into an
`AppLocalizations` class:

- The `.arb` files live in `lib/core/l10n/`, so every feature can use them.
  `app_en.arb` is the template. Each message in it has a description for
  translators.
- The generated Dart goes to `lib/core/l10n/generated/`, and is never
  committed, like freezed's ([ADR 0011](0011-freezed-for-ui-states.md)).
  `flutter pub get` and `melos run generate` rebuild it.
- Widgets read the words with `context.l10n`, from `core/l10n/l10n.dart`.
- The app follows the device's language. English comes first in the
  supported languages, so a device in any language the app does not speak
  gets English. Spanish is Spain's.
- The app's delegates are its own plus `material_ui`'s
  `GlobalMaterialLocalizations.delegates`, in one list,
  `appLocalizationsDelegates`. The delegates gen-l10n writes are for
  `package:flutter/material.dart`, and leave `material_ui`'s widgets without
  Spanish.
- A test checks that every `.arb` file has the same messages. gen-l10n falls
  back to English for a missing message without failing, so without the test
  a forgotten line would show in English on a Spanish phone.

## Consequences

- A new language is one more `.arb` file. The test makes sure it has every
  message.
- Text mappers will take an `AppLocalizations`, so they keep turning UI
  models into words, now in the language on screen.
- Widget tests that show a screen need the translations around it, through
  the `localizedApp` test helper.
- Generated code lives in a `generated/` folder. Git, the analyzer and the
  coverage gate skip any folder with that name.

## Alternatives considered

- **A package such as `easy_localization` or `slang`.** More features, such
  as changing language without a restart, but another dependency and
  another way of doing what Flutter's tool already does.
- **Committing the generated Dart.** Saves a step after cloning, but the
  generated files would show in every review and could drift from the
  `.arb` files.
- **A language choice in Settings.** Not needed while the app speaks two
  languages, and easy to add later: the settings store would hold it, and
  `App` would pass it as `locale`.
