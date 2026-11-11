# Plan: architecture fixes, fitted to the milestones

## Overview

The architecture review of 2026-11-08 found the structure sound, plus a short
list of problems. This plan fixes them and fits each fix into the README
roadmap:

- **Before M5:** fixes that every platform needs, and changes to files that
  M5 will touch.
- **Inside M5:** translations, which are M5's "English and Spanish" item.
  They are done first within M5, because accessibility labels, the About
  page and goldens all show text.
- **The web build is dropped** (2026-11-10), so the two problems that exist
  only on the web are not planned. They stay written down below in case that
  changes.
- **M7:** crash reporting plugs into the error reporter added before M5.

Each task is one pull request, as usual here: a Conventional Commits title,
squash-merged, `dart run melos run verify` green. Task numbers stay as first
planned, so they can be referred to. The checklist is in `tasks/todo.md`.

## Decisions

- **The computer's move is chosen and played in two steps** (Task 1). The bloc
  asks for the move, checks it is still open, then plays it with `PlayMove`.
- **A failed save does not stop the game** (Task 5). It is reported, and play
  goes on. The shared_preferences repository does it, so the use cases stay
  as they are.
- **Settings get one store for the whole app** (Tasks 6 and 7). It is pure
  Dart, in `settings/domain/`. A future language setting would live there
  too.
- **Languages:**
  - English is the default. Spanish (Spain, `es`) comes second.
  - The app follows the device: a Spanish device gets Spanish, and any other
    device gets English. There is no language choice in Settings for now.
  - English is listed first in `supportedLocales`, which is what makes
    Flutter fall back to it.
  - Adding a language later means adding one `.arb` file and one locale.
    The check that no text is missing covers every language.
- **Translations use Flutter's `gen-l10n`** (Task 8). The `.arb` files and the
  generated class live in `lib/core/l10n/`, so every feature may use them.
  The generated Dart is not committed, like freezed's: the `generate` Melos
  script runs `flutter gen-l10n`.
- **Text mappers receive the translations as an argument**:
  `map(headline, l10n)`. Their tests use
  `lookupAppLocalizations(const Locale('es'))` and need no widgets.
- **The tutorial's text leaves the bloc folder** (Task 11). Each step names a
  `TutorialTopic`, which a text mapper in `view/` words.
- **No full on-device test for now** (Task 17, changed). See "Why no full
  on-device test" below.
- **The two web-only problems are dropped with the web build** (Tasks 2 and
  3). Android declares no deep links and does not restore routes, so a
  `/game` link or a refresh only happens on the web. `compute` blocks the
  screen only on the web too.

## Why no full on-device test

The existing tests already cover almost everything such a test would:

- The storage format: shared_preferences' in-memory platform and the
  repository contract tests.
- The app's wiring: `test/app/app_test.dart` builds every module the way
  `bootstrap` does.
- Every flow: bloc and widget tests.

One gap is real. No test sends an agent to another isolate (a separate Dart
thread), which is what `compute` does on a phone. If a field that cannot be
copied were added to an agent, the computer would crash on a device while
every test still passed. Task 17 closes that gap with one quick engine test.

A full on-device test pays off when you release to Google Play. Revisit it in
M7.

## Before M5

**Task 1. `fix(game): stop a closed game from saving the computer's move`** (S)

Leaving a game while the computer thinks, then starting another game, lets the
old search overwrite the new save. This happens on every platform.

- Rename `RequestAgentMove` to `ChooseAgentMove`. It returns a `Move` and
  saves nothing.
- `GameBloc._letComputerPlay` chooses the move, returns if `isClosed`, then
  plays it with `PlayMove`. An illegal agent move still throws a
  `StateError`.

Acceptance:
- A bloc test reproduces the race: computer thinking, bloc closed, a new game
  saved, search released. The new game is still the save.
- Every current computer-turn test still passes.

Files: `domain/use_cases/request_agent_move.dart` (renamed),
`presentation/bloc/game_bloc.dart`, `game_module.dart`,
`test/helpers/game_bloc_factory.dart`, `game_bloc_test.dart`,
`game_use_cases_test.dart`.

**Task 4. `feat(app): report uncaught errors`** (S)

- In `bootstrap`, set `FlutterError.onError` and
  `PlatformDispatcher.instance.onError`. Both hand errors to one
  `ErrorReporter`, which for now writes them to the console as Flutter
  writes its own errors.
- No `BlocObserver`: bloc throws an event handler's error again after
  telling its observer, so it reaches `PlatformDispatcher.onError` anyway.
  An observer that reported too would report each error twice.
- `installUncaughtErrorReporting` sets the two hooks.
- The `ErrorReporter` type lives in `core/errors/`, in a file that imports
  nothing. Task 5's repository, in `game/data/`, takes one, and features may
  not import `app/`. Importing nothing keeps the type usable by the domain
  layer, which must stay pure Dart.
- The console reporter, `logError`, lives in `app/`: only the composition
  root picks a reporter.
- In M7, crash reporting replaces the console reporter, and nothing else
  changes.

Acceptance:
- A test shows that an error inside Flutter and any other uncaught error
  both reach the reporter.

Files: `core/errors/error_reporter.dart` (new),
`app/uncaught_error_reporting.dart` (new), `app/log_error.dart` (new),
`app/bootstrap.dart`, tests.

**Task 5. `fix(game): keep playing when the game cannot be saved`** (S)

- `SharedPreferencesGameRepository` takes an `ErrorReporter` and catches its
  own storage failures (`Exception`s only):
  - A failed `save` or `clear` is reported and swallowed.
  - A failed `load` is reported and gives `null`.
- The plugin, `SharedPreferencesAsync`, stays the data source: it only reads
  and writes strings. The rule belongs to the repository, next to the JSON.
- Tests fail the storage with `FailingSharedPreferences`, a shared_preferences
  platform that throws the plugin's `PlatformException`.

Acceptance:
- With storage whose writes fail, a move still shows on the board and the
  reporter receives the error.

Files: `game/data/shared_preferences_game_repository.dart`,
`app/bootstrap.dart`, `test/helpers/failing_shared_preferences.dart` (new),
tests. ADR 0016 records the rule.

Depends on Task 4.

**Task 6. `refactor(settings): add one settings store for the whole app`** (M)

- Add `SettingsStore` in `settings/domain/`, pure Dart:
  - `current` and a broadcast `changes` stream.
  - `load()` does not overwrite a change made while it was loading.
  - `update(settings)` shows the change at once, then saves it.
- `SharedPreferencesSettingsRepository` takes an `ErrorReporter` and catches
  its own storage failures, as Task 5 does for the game (ADR 0016). A failed
  load gives the defaults; a failed save leaves the change on screen.
- `App` listens to the store and maps `ThemePreference` to `ThemeMode`.
- `GameModule` reads `highlightLastMove` from `store.current`.

Acceptance:
- With a slow repository, a change made before `load()` finishes survives.
- With `FailingSharedPreferences`, a change still applies and the reporter
  receives the error.
- The theme still follows the setting.

Files: `settings/domain/settings_store.dart` (new),
`shared_preferences_settings_repository.dart`, `settings_module.dart`,
`app/app.dart`, `app/bootstrap.dart`, tests.

**Task 7. `refactor(settings): give the settings page its own cubit`** (S)

Done in the same pull request as Task 6: once `App` follows the store, it
no longer needs to provide the cubit, so the page builds its own.

- `SettingsCubit` is built for each visit by `SettingsModule.createCubit`. It
  reads and updates the store.
- `App` no longer provides it.

Acceptance:
- The settings page shows, changes and saves both settings as before.
- No widget outside the settings page reads `SettingsCubit`.

Files: `settings_cubit.dart`, `settings_module.dart`, `settings_page.dart`,
tests. No ADR: none says the cubit lives as long as the app.

Depends on Task 6.

**Task 14. `refactor(game): small game screen tweaks`** (S)

Done before M5 because M5's animations and board palettes change the same
widgets.

- `BlocSelector` for the undo and redo buttons.
- A `BoardColors.of(context)` helper in place of the three
  `extension<BoardColors>()!`.
- Mark `GameBloc`'s `position` with `@visibleForTesting`.

Acceptance:
- Behaviour unchanged, and every test passes.

**Task 15. `perf(game): undo two moves with one replay and one save`** (S)

Done before M5's animations, which will need to know what an undo removed.

- `UndoMove` takes a `count`, defaulting to 1.

Acceptance:
- An undo against the computer replays and saves once (checked with a
  counting repository).

**Task 17. `test(engine): check that every agent runs on another isolate`**
(S, changed)

- The agent contract, which every agent's test runs, chooses a move through
  `Isolate.run`, as `compute` does on a phone, and checks it matches the
  move chosen on the same isolate.
- The testing table in `docs/architecture.md` loses the "Integration" row
  and gains the agent contract, with a note on the full device test for M7.

Acceptance:
- The test fails if an agent holds something that cannot be copied to
  another isolate.

Files: `packages/cephalopod_engine/test/src/agents/game_agent_contract.dart`,
`docs/architecture.md`.

### Any time (no milestone depends on them)

**Task 13. `refactor(game): keep each screen enum conversion in one place`**
(S)

- Both directions of `DifficultyUi`, `PersonMovesUi` and `ThemeUi` move into
  the matching mapper. The cubits call the mapper.

Acceptance:
- No cubit contains a `switch` over a screen enum.

**Task 16. `refactor(game): read saved games with map patterns`** (S)

- `_decodeConfig` and `_decodeMove` check and read their keys with one map
  pattern each.

Acceptance:
- The codec tests pass unchanged.

**Task 18. `ci: use the same Flutter version as local`** (XS)

- Set `FLUTTER_VERSION` in `ci.yaml` to 3.47.9.

### Checkpoint: ready for M5
- [ ] `dart run melos run verify` passes
- [ ] By hand on Android: a game against Hard; leave mid-search and start a
      game against a friend, then reopen the app; change the theme at
      startup

## M5: English and Spanish (first within M5)

**Task 8. `feat(app): set up translations`** (M)

- Add `flutter_localizations` and `intl`, and `generate: true` in the app's
  pubspec.
- Add `l10n.yaml`: `arb-dir: lib/core/l10n`,
  `output-dir: lib/core/l10n/generated`, English first, formatted output.
- Add `app_en.arb` (the template) and `app_es.arb`.
- Git, the analyzer and the coverage gate skip any `generated/` folder. Run
  `flutter gen-l10n` in the `generate` Melos script.
- Add `core/l10n/l10n.dart`: a `context.l10n` extension, and
  `appLocalizationsDelegates`, which takes Flutter's translations from
  `material_ui`. The delegates gen-l10n writes are for
  `package:flutter/material.dart`, and leave `material_ui`'s widgets without
  Spanish.
- Add a `localizedApp` test helper with the same delegates.
- Wire `App`: delegates, `supportedLocales` (English first),
  `onGenerateTitle`.
- Move the strings of Home, Settings and About into both `.arb` files.
- Make `verify` fail when any language is missing a key: a test compares the
  `.arb` files, since gen-l10n falls back to English without failing.

Acceptance:
- A Spanish device shows Spanish on Home, Settings and About. Any other
  language shows English.
- A key missing from `app_es.arb` fails `verify`.

Files: `app/pubspec.yaml`, `app/l10n.yaml`, `lib/core/l10n/*` (new),
`app/app.dart`, `home_view.dart`, `settings_page.dart`, `about_page.dart`,
the root `pubspec.yaml` (Melos), `.gitignore`, tests. New ADR: translations
with gen-l10n, English as the default, generated code not committed.

Depends on Task 7 (both change `app.dart`).

**Task 9. `feat(game): translate the text mappers`** (M)

- `HeadlineTextMapper`, `PlayerTextMapper`, `SquareTextMapper`,
  `CaptureTextMapper` and `TutorialProgressTextMapper` take `l10n` in `map`.
- Use ICU placeholders for the numbers.
- Spanish wording is Spain's: "el ordenador".

Acceptance:
- Each mapper test checks both English and Spanish, without widgets.

Files: the five mappers, the widgets that call them, and their tests.

Depends on Task 8.

**Task 10. `feat(game): translate the game screen and new-game dialog`** (S)

- Move the remaining literal strings into both `.arb` files: app bar,
  tooltips, buttons, dialog sections and segments.

Acceptance:
- No `Text('…')` literal is left in `features/game/presentation/view/`,
  except in previews.

Files: `game_view.dart`, `new_game_dialog.dart`, `capture_controls.dart`,
`how_to_play_page.dart`, tests.

Depends on Task 8.

**Task 11. `feat(game): translate How to play`** (M)

- Give `TutorialStep` and `TutorialStepUi` a `TutorialTopic` enum (in
  `presentation/models/`) instead of `title` and `body`.
- Add a `TutorialTextMapper` in `view/` that words each topic.

Acceptance:
- `tutorial_steps.dart` holds no text.
- A test shows that every topic has a title and a body in both languages.

Files: `tutorial_step.dart`, `tutorial_steps.dart`, `tutorial_step_ui.dart`,
`tutorial_step_ui_mapper.dart`, `how_to_play_page.dart`,
`tutorial_text_mapper.dart` (new), tests. Add an ADR that replaces ADR
0015's exception for How to play's text. Accepted ADRs are never edited, so
0015 stays as it is.

Depends on Task 8.

**Task 12. `test(app): check the app in Spanish`** (S)

- A widget test runs the app in Spanish and checks Home, the dialog, the
  game screen and How to play, with no overflow at phone width (360 dp).

Acceptance:
- The test passes.
- By hand, no clipped or wrapped segment labels in either language.

Depends on Tasks 9–11.

### The rest of M5, after the translations

Order: accessibility first (it changes how the screens announce themselves),
then colours, then animations (which need both), then About, then goldens
last, when text and colours are final. Each is one pull request.

**Task 19. `feat(game): announce the game's changes to screen readers`** (S)

- The headline above the board becomes a live region, so a screen reader
  says "Your turn" or "The computer is thinking…" when it changes, without
  the player hunting for it.
- A move the computer makes is announced in words, such as "The computer
  placed a 3 at row 2, column 4": the square's label already exists in
  `SquareTextMapper`, and the new message goes through a text mapper too.

Acceptance:
- A widget test finds the headline's live-region flag, and the announcement
  after a computer move, in both languages.

**Task 20. `test(app): check accessibility on every screen`** (S)

- Run Flutter's accessibility guidelines on Home, the dialog, the game
  screen, How to play, Settings and About: tap targets (Android's 48 dp),
  labelled tap targets, and text contrast.
- The same screens at 200% text size, in both languages, with no overflow.

Acceptance:
- The guideline tests pass. Where one fails, the screen is fixed in this
  pull request, and it says what was changed.

**Task 21. `feat(app): give the board a palette for each theme`** (M)

- `BoardColors.dark` stops being a copy of `light` (see
  `board_colors.dart`). The board is dark teal in both themes today, so the
  light theme gets its own board: pale sage, with lighter squares.
- The dice keep their colours, coral and cream, in both themes, so the
  tutorial's words ("the coral dice and the cream ones") stay true. On the
  pale squares the cream die needs a dark brown edge, since its face is
  almost white. The coral die's edge stays.
- Rings change too, to darker shades that show on a pale board.
- A test checks that the contrast between a die's edge and its square, and
  between a marked square's ring and the board, passes in both palettes.

The colours were drawn and agreed on before the task (the numbers are in
the sketch of 2026-11-10); the starting values are:

| | Dark (now) | Light |
| --- | --- | --- |
| Board / edge | `0C3D37` / `1D5E55` | `C9DED8` / `8FB3AA` |
| Square | `082C28` | `EAF3F0` |
| Cream die edge | `CBBE9F` | `7A6A44` |
| Last move / target / option / selected ring | `5EEAD4` / `FFB199` / `5EEAD4` / `FF7A5C` | `0B7A6B` / `C2410C` / `0B7A6B` / `B42318` |

Acceptance:
- Both themes look right by hand (the screenshots go in the pull request).
- Contrast of at least 3:1 for the rings and the dice's edges against the
  board and squares, as WCAG asks of graphics.
- Player 2's dice are still cream and Player 1's coral in both themes.

Considered and left out: brown, green or blue for Player 2. Green is
almost the same as coral to a red-blind player, brown falls below 3:1 on
the dark board, and blue works but means rewording the tutorial.

**Task 22. `feat(game): animate placing a die`** (S)

- The new die grows into its square, and the player's tap gets an answer
  right away.
- No animation at all when the device asks for reduced motion
  (`MediaQuery.disableAnimations`).

**Task 23. `feat(game): animate a capture`** (M)

- The captured dice shrink away and the new die shows its sum. Undo and redo
  stay instant.
- Same rule for reduced motion. Tests pump frames by hand rather than
  `pumpAndSettle`, so they check the middle of an animation.

Acceptance (22 and 23):
- Moves, undo, redo and the computer's turn still behave the same: the
  bloc's states do not change, only how the view draws the change.

Changed while building Task 23: the state gained one field, `movePlayed`.
The view cannot tell a move from a turn taken back by looking at the board:
against the computer, taking back a capture of the die just placed looks
like a move with a capture. So the bloc says whether a move was just
played, and the board animates only then. Nothing else in the states
changed.

Also changed: the dice take 500 ms, not 200, and after every move the bloc
waits that long (`moveSettleTime`) before the next move: taps are ignored
and the computer does not reply until the board has stopped moving.

**Task 24. `feat(about): link the rule sheet and show the app's version`** (M)

- The rule sheet's address becomes a link that opens in the browser
  (`url_launcher`).
- The version and build number appear under the title (`package_info_plus`).
- The new words go straight into both `.arb` files.
- An ADR records the two dependencies, since the app has had none beyond
  Flutter's and storage until now.

Acceptance:
- The link opens the rule sheet on Android.
- A test replaces both plugins with fakes, so it runs without a device.

Built as three PRs, one after the other, to keep each short to review:
the About page drawn from a cubit (no new behaviour), then the version
(`package_info_plus`, its own ADR), then the link (`url_launcher`, its own
ADR). The task is ticked in `todo.md` with the last one.

**Task 25. `test(app): add golden images of the main screens`** (M)

- Goldens for Home, the dialog with the computer chosen, the game screen
  and How to play, in English and Spanish, light and dark.
- The images are made on Linux and checked by CI, which runs on Linux, so
  they match.
- Text is drawn in Roboto, with the `loadRealFonts` test helper that Task 20
  added, so the images show real words and lock in typography too. Roboto
  comes with the Flutter SDK, and the README pins one Flutter version, so
  everyone's images match. This replaces the first idea, the test font Ahem,
  whose letters are plain boxes.

Acceptance:
- `flutter test --update-goldens` is documented in the README's testing
  section, and CI fails on a change nobody updated.

Built as two PRs: #85 set up the helper, the README section and one image;
the next added the rest. Settings and About were left out (2026-11-11): a
subset of the screens is enough.

**Task 26. `docs: mark M5 done`** (XS)

- README status and roadmap, `docs/architecture.md`'s testing table.

### Decisions for M5 (answered 2026-11-10)

1. **The light board (Task 21).** The light theme gets a light board. Dice
   stay coral and cream; the cream die gets a dark edge.
2. **Two new dependencies (Task 24).** `url_launcher` and `package_info_plus`
   are added, and an ADR records them.
3. **Goldens and the test font (Task 25).** Ahem text was accepted. Task 20
   found that real Roboto loads in tests, so the goldens use it instead.

## Dropped: the web build

The web is not a priority of this project (2026-11-10), so these two tasks
are not planned. Nothing else depends on them. They are kept here, with
their fix, in case a web build comes back.

**Task 2. `fix(game): make the game route always show the saved game`** (M,
mostly deletions)

On the web, refreshing `/game?computer=…` or opening a link to it starts a
new game, which erases the one in progress.

- `NewGameCubit` takes `StartNewGame`. Start saves the new game, then the
  dialog closes with the location of `/game`.
- `GameModule` builds the dialog's cubit.
- The `/game` route always opens with `GameResumed`. Delete `?resume=true`,
  `_openingOf`, `OpponentQueryCodec` and its test, the `GamePage.opening`
  parameter, and `GameStarted` if nothing sends it any more.

Acceptance:
- Refreshing `/game` in Chrome shows the same game.
- A `/game` link never replaces a saved game.

**Task 3. `fix(game): show "thinking" before the computer searches on the
web`** (XS)

- `GameModule`'s background runner waits for
  `WidgetsBinding.instance.endOfFrame`, then calls `compute`.
- Then decide whether the search should pause between passes, so the page
  never freezes.

Acceptance:
- In Chrome, against Hard, "The computer is thinking…" is drawn before the
  computer's move appears.

## To fix later

**Task 27. `fix(game): show the game screen's title in full on small
phones`** (S)

Found by the goldens (Task 25, 2026-11-11): on a 360 dp phone, the game
screen's title is cut to "Cepha…", because four icons share the app bar
with it (undo, redo, How to play, new game).

- Options: drop the title on the game screen, or move one or two icons
  into an overflow menu. Decide before building.
- Fix it before the Play Store screenshots (M7), which would show it.

Acceptance:
- The game screen's app bar shows nothing cut at 360 dp, in English and
  Spanish.
- The game goldens are drawn again, and the PR shows the old and new ones.

## M7: Google Play

- Crash reporting goes into Task 4's reporter.
- **Play Store screenshots, made by a test.** An `integration_test` runs the
  real app on an emulator, sets up each moment (a game mid-capture, the
  new-game dialog with the computer chosen, How to play, the dark theme),
  and saves the screen with `takeScreenshot`. `flutter drive` runs it once
  per language and writes the images to `art/play-store/`. On a device the
  text is drawn in the real font, unlike widget tests. After a visual
  change, one command makes them again. Needs checking when built: how the
  test sets the language on the emulator.
- **The same test is the release check.** It plays a game, saves it and
  resumes it on a real device, which is the full on-device test that
  "Why no full on-device test" leaves for M7. Build the screenshots after
  the screens have settled, once M5 is done.
- The store needs a 1024 × 500 feature graphic as well; that one is made
  by hand from the art in `art/`.

## Not planned, and why

- **Narrowing the engine's exports:** the engine's own tests use
  `BoardGeometry`, `CaptureFinder` and `Referee` through the barrel. Little
  gain for the churn.
- **Primary constructors:** style only. Worth adopting in new code if you
  like them, but not worth a rewrite.
- **`HasGameToContinue` clearing a corrupted save:** documented, and
  harmless.
- **Mappers injected with `const` defaults that no test replaces:**
  harmless. Just don't add more.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Spanish text is longer and overflows segmented buttons | Medium | Task 12 tests at 360 dp; the M5 goldens lock it in |
| The generated translations break the analyzer or the architecture check | Low | Exclude the generated file; it lives in `core/`, which every feature may import |
| Tasks 6–8 all touch `app.dart` | Low | Done in order, not in parallel |
| The before-M5 work delays M5 | Low | Seven small tasks and one medium; Tasks 13, 16 and 18 can slip into M5 |

## Answered questions (2026-11-08)

1. A failed save: keep playing and report it.
2. Languages: English by default; more languages later. The app follows the
   device and has no language setting.
3. The full on-device test: not now. One isolate test covers the real gap,
   and the full test can be revisited at M7.
4. The web search: dropped with the web build (2026-11-10).
5. Spanish: Spain's.
