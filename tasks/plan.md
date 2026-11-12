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
- **M6 (UX, planned 2026-11-11):** How to play on first launch, a simpler
  game app bar, a dice count, a hint, and effects and sounds for captures and
  wins. Refactors and foundations come before the features they carry.
- **M7:** crash reporting plugs into the error reporter added before M5.
  Ten more languages and a rating prompt join it.

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
  - M7 adds French, Italian, Portuguese (Brazil), German, Polish, Turkish,
    Danish, Norwegian (Bokmål), Swedish and Dutch (planned 2026-11-11).
  - The app follows the device: a device in one of its languages gets that
    language, and any other device gets English. There is no language choice
    in Settings for now.
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
- [x] `dart run melos run verify` passes
- [x] By hand on Android: a game against Hard; leave mid-search and start a
      game against a friend, then reopen the app; change the theme at
      startup (checked on a Pixel 10, 2026-11-12)

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
phones`** (S). Done by Task 28 (M6), which moves undo, redo and new game
into a "more" menu.

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

## M6: UX (planned 2026-11-11)

Before M7, the game gets easier to learn and nicer to play: How to play on
first launch, easier tutorial navigation, a less crowded game app bar, a dice
count, a hint, a burst and a sound on captures, and confetti and a sound for
a win.

**How the work is split.** Refactors come first and change nothing the
player sees, so the goldens stay the same. A feature with more than one layer
becomes two or three PRs. First come the foundations, which add data, use
cases or drawing code that nothing on screen uses yet, each tested on its
own. Then a feature PR switches it on. A task keeps its number, and its PRs
are lettered (33a, 33b, …), as Task 24 did. Refactors 38 and 39 are numbered
in the order they were planned, not the order they are built.

### Is the code scaling? What was checked (2026-11-11)

| Area | Today | Under the new work | Verdict |
| --- | --- | --- | --- |
| `game_view.dart` | 154 lines: app bar, headline, board, controls | + menu, tally, hint, confetti, 2 sound listeners | Task 38 splits it |
| "What just happened" | `_computerMove` and `_movePlayed` in the bloc, and `computerMove` and `movePlayed` in the state | + captured dice, captured squares, win | Task 39 makes it one value |
| `board_square.dart` | 193 lines: ring plus die grow and shrink | + a pulsing hint ring, a 2nd controller | 33b moves the ring out |
| "How to play was seen" | (new) | would put something that is not a choice into `AppSettings`, and need a `ready` future | How to play's own store (31a) |
| `GameViewStateMapper.map` | 9 named parameters | Task 39 takes 2 away; the hint rides in the phase | Fine |
| `GameBloc` | 378 lines, one event switch | the hint is part of the phase that awaits a placement | Fine |
| How to play cubit and state | small, an enum for the right button | + `canGoBack`, `canSkip` | Fine |
| Settings, Home, `GameModule` wiring | plain-function wiring | + one switch, one callback | Fine |
| Test helper `createTestGameBloc` | one place builds the bloc | + `SuggestMove` in one place | Fine |

### Order

| # | PR | Kind | Size |
| --- | --- | --- | --- |
| 1 | 38 · split the game screen into widgets | refactor | S |
| 2 | 39 · one value for the move just played | refactor | S |
| 3 | 28 · actions in a "more" menu | feature | S |
| 4 | 29 · dots on their own row, Previous | feature | S |
| 5 | 30 · Skip How to play | feature | XS |
| 6 | 31a · remember whether How to play was seen | foundation | S |
| 7 | 31b · How to play on first launch | feature | S |
| 8 | 32a · count each player's dice in the state | foundation | S |
| 9 | 32b · the dice tally on screen | feature | S |
| 10 | 33a · `SuggestMove` use case | foundation | S |
| 11 | 33b · a square's ring in its own widget | refactor | S |
| 12 | 33c · the board can draw a hint | foundation | S |
| 13 | 33d · Hint in the menu | feature | S |
| 14 | 37a · the played move says what it captured and whether it won | foundation | S |
| 15 | 34a · particle drawing | foundation | S |
| 16 | 34b · burst a captured die | feature | S |
| 17 | 37b · confetti for a win | feature | S |
| 18 | 35a · the settings remember Sound | foundation | S |
| 19 | 35b · Sound switch in Settings | feature | S |
| 20 | 36a-1 · the sound files and the script that makes them | foundation | S |
| 21 | 36a-2 · audio playback (ADR, package, `SoundEffects`) | foundation | S |
| 22 | 36b · sound on a capture | feature | S |
| 23 | 36c · sound on a win | feature | XS |

### Refactors first

**Task 38. `refactor(game): split the game screen into widgets`** (S)

- `widgets/game_app_bar.dart`: the app bar and its actions, a
  `PreferredSizeWidget`. It takes over `_HistoryButtons` and its
  `BlocSelector`.
- `widgets/game_headline.dart`: the live-region headline, with both text
  mappers.
- `GameView` keeps only the layout. Later tasks add
  `widgets/dice_tally.dart` (32b) and one wrapper,
  `widgets/game_effects.dart`, holding the confetti layer (37b) and the sound
  listener (36b, 36c).

Acceptance:
- No behaviour change: the widget tests pass unchanged, and the goldens do
  not change.

**Task 39. `refactor(game): describe the move just played in one value`** (S)

- `GameViewState`'s `movePlayed` and `computerMove` become one field,
  `playedMove: PlayedMoveUi?`. It is null when the board changed some other
  way: undo, redo, a new game, a resumed game. When set, its `computer`
  (a `ComputerMoveUi?`) is non-null if the computer played it.
- In the bloc, `_computerMove` and `_movePlayed` become one `_playedMove`,
  set and cleared in `_show`.
- One place says "a move just happened". Task 37a adds what it captured and
  whether it won, and the burst, the confetti and both sounds read it, so they
  cannot disagree.

Acceptance:
- No behaviour change: the bloc tests are rewritten field for field, and the
  goldens do not change.

### Features

**Task 28. `feat(game): move the game's actions into a menu`** (S)

- The app bar keeps the How to play icon and gets a "more" icon
  (`Icons.more_vert`). It opens a menu with Undo, Redo and New game, each
  enabled under the same rule as today. New game still sends `GameRestarted`.
- A new `gameMenuTooltip` in both `.arb` files; the items reuse the existing
  words.
- Fixes Task 27: two icons leave room for the title.

Acceptance:
- The title shows in full at 360 dp, in both languages.
- The game goldens are drawn again, and the PR shows the old and new ones.

**Task 29. `feat(game): centre How to play's dots and add Previous`** (S)

- Under the pages, two rows: the `StepDots`, centred, on top; below, Previous
  on the left (an empty space of the same width on the first page) and Next
  or Done on the right.
- `HowToPlayViewState` gets `canGoBack`, false on the first step. Previous
  turns the page back.
- New text: "Previous" / "Anterior".

**Task 30. `feat(game): let the player skip How to play`** (XS)

- "Skip" / "Omitir" in How to play's app bar. It leaves the tutorial, as
  Done does. It is hidden on the last page, where Done does the same. The
  state gets `canSkip`.

**Task 31. How to play the first time the app opens** (two PRs)

- **31a. `feat(game): remember whether How to play was seen`** (foundation,
  S). "Seen" describes How to play, so the store lives with it, in the game
  feature: a `HowToPlayRepository` in `game/domain/`, a shared_preferences
  implementation and an in-memory one, and contract tests for both. A failed
  read counts as seen (docs/adr/0016), so a broken store never traps the
  player in the tutorial. `AppSettings` stays as it is.
- **31b. `feat(app): show How to play the first time the app opens`**
  (feature, S). `HowToPlayCubit` marks it seen when the page opens, from
  wherever it opens, so Back, Skip and Done all count. `GameModule` hands
  Home a plain `hasSeenHowToPlay` function, as it does
  `hasGameToContinue`, and the composition root wires it. `HomeCubit` asks
  it on its first `refresh`, and `HomeView` opens How to play once.

  Decided 2026-11-11, in #94: first planned as Home's store, marked by Home
  as it opened How to play. Moved, so that the screen the flag describes is
  the one that writes it, and Home only reads it.

Acceptance:
- A fresh install opens on How to play, and going back shows Home. It never
  opens by itself again.

**Task 32. Show how many dice each player has** (two PRs)

- **32a. `feat(game): count each player's dice in the game state`**
  (foundation, S). `GameViewState` gets `tally: DiceTallyUi`: each side's
  player, colour and count, and who is to move.
- **32b. `feat(game): show how many dice each player has`** (feature, S).
  Two chips between the headline and the board, each with a small `DieFace`
  in that player's colour, the player's name and the count. The player to
  move is highlighted. Screen readers hear one label, such as "You 7 dice,
  Computer 5 dice". Counts use an ICU `plural` from the start, so M7's
  languages with more plural forms fit.

Acceptance:
- Both languages at 360 dp and at 200% text, and the game goldens drawn
  again.

**Task 33. A hint** (four PRs)

- **33a. `feat(game): add a use case that suggests a move`** (foundation, S).
  `SuggestMove`, shaped like `ChooseAgentMove`: the Hard agent chooses a move
  on the background runner for the player to move. It refuses a finished
  game.
- **33b. `refactor(game): draw a square's ring in its own widget`**
  (refactor, S). The ring leaves `BoardSquare` for `SquareRing`, which will
  be stateful only to pulse. No behaviour change.
- **33c. `feat(game): let the board draw a hint`** (foundation, S).
  `SquareMark` gets `hintTarget` and `hintCapture`, with ring colours in both
  palettes (at least 3:1, as in Task 21). The target pulses, except under
  reduced motion. Screen readers hear "suggested" or "would be captured".
  Nothing sets these marks yet.
- **33d. `feat(game): give a hint`** (feature, S). A `HintState` (none,
  searching, found), a freezed union carried by
  `TurnPhase.awaitingPlacement`, the only phase in which a hint makes sense
  (changed in #102 from a state kept next to the phase). A
  `HintRequested` event, allowed only when a die can be placed, works the
  way the computer's turn does: the board takes no taps and the headline says
  "Looking for a hint…". When the search ends, the marks show until the next
  event. The "more" menu gets Hint, enabled only when a die can be placed:
  not while the computer thinks, while a capture is chosen, or after the game
  ends.

Acceptance:
- The hint clears on a tap, undo or a new game, is refused while the
  computer thinks and after the game ends, and is dropped if the screen
  closes during the search.

Built as three PRs (split on review of #101, 2026-11-11): 33d-1 puts the
hint into the game's state and the mappers, with the "Looking for a hint…"
headline; 33d-2 the spoken hint; 33d-3 the bloc's search and the menu's
Hint.

**Task 37a. `feat(game): say what the move just played captured, and whether
it won`** (foundation, S)

- `PlayedMoveUi` gains `captured` (each square and the side its die belonged
  to) and `celebrate`. `celebrate` is true when the move ends the game and
  the person won; in a game between two people, every end is a win for one
  of them (the board has an odd number of squares), so it is true there too.
- Undo, redo and a resumed game have no `playedMove`, so they never
  celebrate or report a capture.

**Task 34. Burst a captured die** (two PRs)

- **34a. `feat(game): draw particles`** (foundation, S). Plain Dart in
  `view/effects/particles.dart`: particles with a start, a speed, a colour, a
  size and a spin; where each one is, and how faded, at any moment, under
  gravity and drag; and a painter. It takes a `Random`, so tests are the same
  every run. One engine for the burst and the confetti, so no new package.
- **34b. `feat(game): burst a captured die`** (feature, S). About 12 pieces
  in the die's colour fly out of each captured square and fade, with a short
  flash, inside `dieAnimationDuration`. They are drawn in one layer over the
  board, so they cross neighbouring squares. The squares come from
  `playedMove.captured`.

Acceptance (34b):
- No burst under reduced motion. Undo and redo stay instant. Tests pump
  frames by hand, as in Task 23.

**Task 37b. `feat(game): throw confetti when the player wins`** (feature, S)

- When `playedMove.celebrate` is true, about 100 pieces in coral, cream and
  the theme's colours fall over the whole screen, app bar included, for about
  3 seconds. The layer ignores taps, so the menu still works.
- No confetti under reduced motion, after a loss, or after undo or redo into
  a finished game.

**Task 35. Sound switch** (two PRs, split on 2026-11-11 to keep each one
small)

- **35a. `feat(settings): remember whether sounds are on`** (foundation, S).
  `AppSettings.sound`, on by default, saved and loaded by the settings
  repository under its own key, with the contract tests. Nothing shows it.
- **35b. `feat(settings): add a Sound switch`** (feature, S). A switch on
  the Settings page, with its words in both languages, through the
  settings cubit and its view state.
- `GameModule` reading the setting (`bool Function() soundOn`, the way it
  reads `highlightLastMove`) moves to 36b, the first PR that plays a sound.

**Task 36. Capture and win sounds** (four PRs; 36a split in two on
2026-11-11 to keep each one small)

- **36a-1. `feat(game): add the capture and win sounds`** (foundation, S).
  Two sounds, a short pop and a short rising chime, made from sine waves by
  `tool/make_sounds.dart` (`melos run sounds`), so there is no licence
  question. Declared as app assets. Nothing plays them.
- **36a-2. `feat(game): add audio playback`** (foundation, S).
  `audioplayers`, with ADR 0021. A `SoundEffects` interface (`playCapture`,
  `playWin`) in the domain, and its `audioplayers` implementation in
  `data/`, tested with a fake player. Nothing builds or calls it yet.
- **36b. `feat(game): play a sound on a capture`** (feature, S). On every
  capture, by either side, when the switch is on. Undo and redo stay silent.
  `GameModule` gets `soundOn` and the `SoundEffects` here (the composition
  root builds the audioplayers one), and the tests get a fake. The
  `GameBloc` plays the sound as it shows the move, not a listener in
  `game_effects.dart`: views may not import the domain, where
  `SoundEffects` lives.
- **36c. `feat(game): play a sound when the player wins`** (feature, XS).
  The same moments as the confetti. A move plays one sound at most, and a
  win comes first. No move both captures and wins, though: a capture leaves
  squares empty, and only a full board ends the game.

Acceptance (36b, 36c):
- With the fake: each sound plays when it should and not otherwise, and
  never with the switch off. By hand on Android: it follows the media volume
  and leaves music from another app playing (ADR 0021).

### Decisions for M6 (answered 2026-11-11)

1. **The dice count** is a live count of each player's dice on the board,
   drawn with a small die of each colour. Players do not start with a fixed
   number of dice in Cephalopod.
2. **The capture sound** plays on every capture, by either side. Settings
   gets a Sound switch, on by default.
3. **The hint** comes from the Hard search agent and only marks squares; it
   plays nothing. Where the hint stands is a `HintState` (none, searching,
   found), carried by `TurnPhase.awaitingPlacement`: a hint exists only
   while a die is to be placed. First planned apart from `TurnPhase`;
   changed on review of #102, so the types rule out a hint in any other
   phase, and a new phase clears it.
4. **The menu** uses the "more" icon (⋮), Android's usual icon for it.
5. **The refactors** (38, 39, 33b) and a store of its own for "How to play
   was seen" were approved before any feature. The store is How to play's,
   in the game feature (changed in #94 from Home's).

## M6 follow-ups (planned 2026-11-12)

Ideas raised during M6 were parked until M6 was done, then planned here
together with a new Home screen. They come before M7, because they change
screens and files that M7's translations and screenshots then cover once.

Answers from the user (2026-11-12):
- **Captured dice go one at a time.** Each die keeps the full 500 ms shrink,
  the dice start 150 ms apart, and the wait after a move grows with the
  number of dice captured.
- **One pop per captured die**, timed with its burst.
- **The licenses screen stays in M7.**
- **Home gets a new look** (the user: "not attractive at all for the
  player"). From mockups, the user chose all of these:
  - a live demo board on top that plays a capture on a loop
  - one big main button, with How to play, Settings and About as a row of
    icons at the bottom
  - a Continue card that shows the saved game
  - a teal background
  - a shorter tagline
- **Whether the app needs a DI library is set aside for now.**

### Order

| # | PR | Kind | Size |
| --- | --- | --- | --- |
| 1 | T1 · one test file per use case | test | S |
| 2 | H1 · the board's UI models move to `core/` | refactor | S |
| 3 | H2 · the board's drawing moves to `core/` | refactor | S |
| 4 | H3 · the board mapper takes marks, not a turn phase | refactor | S |
| 5 | H4 · How to play becomes its own feature | refactor | S–M |
| 6 | HM1 · a clearer Home: one main button, icons below, teal background, shorter tagline | feature | S |
| 7 | HM2 · a demo board on Home that plays a capture | feature | S |
| 8 | HM3 · the game describes its saved game for Home | foundation | S |
| 9 | HM4 · continue from a card that shows the saved game | feature | S |
| 10 | S1 · wait longer after a bigger capture | feature | S |
| 11 | S2 · captured dice shrink and burst one at a time | feature | S |
| 12 | S3 · one pop per captured die | feature | S |

H1–H4 come first: the Home board, the card's thumbnail and S2 all need the
board's drawing in `core/`, where Home can use it without importing the
game feature.

### Tasks

**T1. `test(game): one test file per use case`** (S)
- `game_use_cases_test.dart` (416 lines, 7 groups) becomes one file per use
  case, named after its source file.
- The shared setup goes to `test/helpers/use_case_fixture.dart`: the rules,
  positions, opponents, in-memory repository, the four use cases, `saved()`
  and `play()`. `_FixedAgent` joins `FirstMoveAgent` in
  `test/helpers/computer_turns.dart`.
- Acceptance: no test changes what it checks; the test count and coverage
  stay the same.

**H1–H4. How to play becomes its own feature.** How to play lives in the
game feature only because its example boards use the game's board drawing
and `BoardUiMapper`. That mapper needs the game's `TurnPhase`, `HintState`
and `Opponent`. So the drawing moves to `core/board/` first, then How to
play moves out. All four are refactors, and the goldens don't change.
- **H1. `refactor(core): move the board's UI models to core`**:
  `BoardUi`, `SquareUi`, `DieUi`, `SideUi`, `PlayerUi`, `RoleUi` and
  `SquareMark` move to `core/board/models/`. Only imports change.
- **H2. `refactor(core): move the board's drawing to core`**:
  `BoardSquare`, `SquareRing`, `DieFace`, `SquareTextMapper`,
  `PlayerTextMapper` (which `SquareTextMapper` uses) and
  `dieAnimationDuration` move to `core/board/`, with their previews and
  tests. A new `BoardGrid` is today's grid, with an optional `overlay` drawn
  over the squares. The game's `GameBoard` becomes `BoardGrid` plus the
  `CaptureBurst` layer as its overlay, which stays in the game feature.
- **H3. `refactor(game): let the board mapper take marks, not a turn
  phase`**: a core `BoardUiMapper` builds a `BoardUi` from an engine
  `Board`, each player's `SideUi` and a map of square marks. The game's
  mapper, renamed `GameBoardUiMapper` so the two names differ, still works
  out the marks and sides, then calls it. A tutorial example states its
  marks directly (`TutorialExample` is a `game` and its `marks`, no longer
  a `TurnPhase` and a last move), and the tutorial's mapper gives it the
  two sides of a game between people. The tests that check the examples
  against the rules (R5, R7) read the marks instead.
- **H4. `refactor(how_to_play): make How to play a feature of its own`**:
  `features/how_to_play/` gets the repository, its two implementations, the
  cubit, steps, mappers, view state, page and its widgets, and a module with
  the route and `hasSeenHowToPlay`. `GameModule` loses them, and the game's
  app bar still opens How to play by route name. Tests and goldens move
  with them. If it grows well past 300 lines, split it first.

**HM1–HM4. A new Home.** Mockups (2026-11-12): the PR that added this
plan shows them. Each PR redraws the Home goldens and shows the old and new
images.
- **HM1. `feat(home): make Home clearer`**:
  - One full-width main button.
  - How to play, Settings and About become a row of icon-and-label buttons
    at the bottom.
  - A teal gradient from the top (the theme's primary container fading into
    the surface), in light and dark.
  - A shorter tagline: "Place dice. Add them up. Capture." and a Spanish
    line to match.
  - The title stays text, for now.
  - Accessibility test: every button keeps its label.
- **HM2. `feat(home): show a board that plays a capture`**:
  - A 3 × 3 board above the title, drawn with `core/board`'s `BoardGrid`.
  - It loops a scripted capture: dice grow in, one captures its neighbours,
    and the sum appears.
  - The frames are plain data with their timing, tested on their own.
  - It is decorative, so screen readers skip it. Under reduced motion it
    shows one still frame.
  - No burst on Home, since the particles stay in the game feature.
- **HM3. `feat(game): describe the saved game for Home`** (foundation):
  - A small core model, `SavedGameSummary`, with the saved game's board,
    each side's identity, dice count and whether it is to move, and the
    computer's level (`null` against a friend). The sides are the
    `SideUi`s the board already uses, so Home can word "you", "computer"
    or "Player 1" without knowing the game.
  - `HasGameToContinue` becomes `GameToContinue`, which gives the game
    worth continuing, and `SavedGameSummaryMapper` describes it.
  - `GameModule` gives it through a plain function, as it gave
    `hasGameToContinue`, which it replaces. Home's cubit only checks that
    there is one. Nothing draws it yet.
- **HM4. `feat(home): continue from a card that shows the saved game`**:
  - When a game is saved, Continue becomes a card.
  - The card has a thumbnail of the board: a new `BoardThumbnail` in
    `core/board`, coloured squares without pips, because the full board's
    gaps hide the dice at that size.
  - Next to it, "vs Computer · Hard" and "Your turn · you 5, computer 5",
    worded by a Home text mapper in both languages.
  - New game becomes the second, softer button.

**S1–S3. Captured dice one at a time.** The timing lives in
`features/game/presentation/bloc/move_timing.dart`:
- `captureStagger` is 150 ms.
- Die `i` of a capture (in reading order) starts `i × 150 ms` after the
  move shows.
- `settleDurationFor(n)` is 500 ms + `(n − 1) × 150 ms`, and 500 ms with no
  capture. So 4 dice wait 950 ms.

- **S1. `feat(game): wait longer after a bigger capture`**:
  - `PlayedMoveUi.captured` comes in reading order.
  - `CountdownTimer.start` takes the length of the wait, which the bloc
    sets from the move's captures. `moveSettleDuration` goes.
- **S2. `feat(game): shrink and burst captured dice one at a time`**:
  - `BoardSquare` takes an optional `shrinkDelay`.
  - `CaptureBurst` gives each die's pieces their own start.
  - Reduced motion still shows nothing, and undo and redo stay instant.
  - A short screen recording goes in the PR.
- **S3. `feat(game): pop once per captured die`**:
  - The bloc plays one `playCapture()` per die, 150 ms apart.
  - Pops still waiting are cancelled when the board changes or the bloc
    closes.
  - Tested with `fake_async`, and by ear on a phone.

### Checkpoint

`verify` green. By hand on Android:
- How to play opens on first launch and from the game.
- Home's board plays its capture, and stands still under reduced motion.
- The Continue card shows the saved game.
- A 3- or 4-die capture goes one die at a time, with a pop each, and the
  computer waits for it.

## M7: Google Play

### Order (planned 2026-11-12)

| # | PR | Kind | Size |
| --- | --- | --- | --- |
| 1 | feat(about): show the open-source licenses | feature | S |
| 2 | L1 · get ready for more languages | foundation | S |
| 3 | L2 · French, Italian, Portuguese (Brazil) | feature | M |
| 4 | L3 · German, Dutch, Danish, Norwegian, Swedish | feature | M |
| 5 | L4 · Polish, Turkish | feature | S |
| 6 | R1 · the review feature counts finished games (`in_app_review`, ADR) | foundation | S |
| 7 | R2 · ask for a review after a game | feature | S |
| 8 | R3 · "Rate the app" on About | feature | XS |
| 9 | I1 · launcher icons from `art/` | feature | S |
| 10 | I2 · splash screen | feature | S |
| 11 | P1 · sign release builds | build | S |
| 12 | E1 · an on-device test plays, saves and resumes a game | test | S |
| 13 | E2 · the same test takes the store screenshots | test | S |
| 14 | docs: the store listing in English and Spanish | docs | S |

The licenses screen comes first so L2–L4 translate its link with everything
else. The languages come before the screenshots, which are made once per
language.

- **No crash reporting in the first release** (decided 2026-11-12). Errors
  still go to `logError`, and Play Console's Android vitals show native
  crashes and freezes. The Data safety form can then say no data is
  collected. A service can be added later behind the same `ErrorReporter`,
  without changing its callers.
- **I1. `feat(app): use the Cephalopod icon on the launcher`** (S). The
  launcher still shows Flutter's default icon. `flutter_launcher_icons`
  (a dev dependency, with a short ADR) makes every Android size from `art/`:
  - the adaptive background and foreground layers
  - the monochrome layer, for Android 13 themed icons

  `art/README.md` already has the settings.
- **I2. `feat(app): show the icon on the splash screen`** (S). Android 12+
  draws the splash from the theme: the background in the app's colours,
  light and dark, with the icon's foreground. The older `launch_background`
  matches it.
- **P1. `build(android): sign release builds`** (S).
  - The build reads an upload key from `android/key.properties`, which git
    ignores, and falls back to debug signing without it, so CI still
    builds.
  - The README says how to make the key and back it up.
  - Check `versionCode` and `versionName`, `targetSdk` against Play's
    current minimum, and the app id `gc.david.cephalopod`.
- **By hand in Play Console (the user):**
  - the account, and Play App Signing with P1's key
  - the listing: texts, screenshots, the icon and the feature graphic
  - Data safety: no data collected or shared
  - the content rating, and a privacy policy URL if asked
  - internal testing, then production
- **Checkpoint:**
  - `verify` green, and E1 passes on an emulator.
  - A signed bundle is installed from internal testing.
  - The rating prompt shows after the 3rd game.
  - Each language shows when the phone uses it.
  - About → Licenses lists the packages.
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
- **Ten more languages** (planned 2026-11-11), early in M7, before the
  screenshots, which are made once per language. French, Italian, Portuguese
  (Brazil), German, Polish, Turkish, Danish, Norwegian (Bokmål), Swedish and
  Dutch join English and Spanish. The app still follows the device, and any
  other language gets English.
  - **L1. `feat(app): get ready for more languages`** (foundation, S). The
    Spanish screen tests loop over every supported language, at 360 dp and at
    200% text. The arb-files test also checks that every placeholder and
    plural in English is in each other file. Every message with a count uses
    ICU `plural` (Polish needs `one`, `few` and `many`). Phones that report
    Norwegian as `no` or `nn` get `nb`. Nothing goes through `toUpperCase()`,
    which breaks Turkish `i`. ADR 0017 is updated.
  - **L2. `feat(app): translate into French, Italian and Portuguese`** (M)
  - **L3. `feat(app): translate into German, Dutch, Danish, Norwegian and
    Swedish`** (M)
  - **L4. `feat(app): translate into Polish and Turkish`** (S)
  - In each: one `.arb` file per language with every key, How to play
    included. Claude drafts them, and they merge once read; mistakes are
    fixed from user reports. Goldens of the game and How to play, light only,
    for each new language. The store listing texts, drafted into
    `art/play-store/<lang>/`.
- **Ask for a rating** (planned 2026-11-11). Google's review sheet only shows
  for apps installed from Play, so it comes in M7.
  - Foundation: `in_app_review` with its own ADR, and a small `review`
    feature that counts finished games in its own store (the pattern of
    Task 31a) and asks after the 3rd game, and once more at most, after the
    10th. Google limits it further.
  - Feature: the game reports a finished game through a plain callback that
    the composition root wires to the review feature.
  - Feature: About gets a "Rate the app" link to the store page.
- **Open-source licenses** (noted 2026-11-11). About gets a "Licenses" link
  to a screen listing the licenses of the packages the app uses, as stores
  and many of those licenses ask. Flutter has one ready: `showLicensePage`
  (or an `AboutListTile`) lists every license that `LicenseRegistry` holds,
  and the packages register theirs on their own. Check that the generated
  sounds and the fonts need no entry. One small PR; the words go into every
  language's `.arb` file.

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
