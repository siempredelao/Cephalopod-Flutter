# Cephalopod

[![CI](https://github.com/siempredelao/Cephalopod-Flutter/actions/workflows/ci.yaml/badge.svg)](https://github.com/siempredelao/Cephalopod-Flutter/actions/workflows/ci.yaml)

A Flutter implementation of **Cephalopod**, the two-player dice game invented by
[Mark Steere](https://www.marksteeregames.com) in 2006. The project doubles as a
reference for clean architecture, SOLID and testing in Flutter: the rules live in
a pure-Dart package, the app sits on top, and CI enforces the boundaries.

**Status:** M0, foundations. The workspace, the engine package, the app shell,
CI and the first architecture decision records are in place. The game becomes
playable at M2.

## The game

Two players take turns placing dice of their colour on a 5×5 board.

- A die placed next to two or more dice whose pips add up to 6 or less
  **captures** them: they leave the board and the new die shows their sum.
- Any other placement shows a 1.
- When all 25 squares are full, the player with more dice wins. There are no
  draws.

Full rules: [official rule sheet](https://www.marksteeregames.com/Cephalopod_rules.pdf).
Cephalopod is © Mark Steere, who allows anyone to program the game provided its
name and rules stay unchanged and he is credited. This app does both.

## Architecture

```text
  presentation ──────────▶ domain ◀────────── data
  views, blocs        use cases,         repositories,
       │              repo interfaces    services
       │                   │                  │
       └───────────────────┼──────────────────┘
                           ▼
     cephalopod_engine: pure Dart, no Flutter, no I/O
```

- **`packages/cephalopod_engine`** holds the rules. It has no Flutter
  dependency, so the compiler keeps UI code out, and every rule is tested
  without a device.
- **`app`** follows Flutter's recommended MVVM split (views, view models,
  repositories, services) with a small domain layer, organised by feature.
- **`tool/check_architecture.dart`** fails CI when an import breaks the
  dependency rule.

Details: [docs/architecture.md](docs/architecture.md). Decisions and their
trade-offs: [docs/adr](docs/adr/README.md).

## Repository layout

```text
.
├── app/                         Flutter app (package: cephalopod)
│   ├── lib/
│   │   ├── app/                 App widget, router, theme, composition root
│   │   ├── core/                Code shared by features
│   │   └── features/<name>/     domain/ · data/ · presentation/
│   └── test/                    Mirrors lib/
├── packages/cephalopod_engine/  Rules engine, pure Dart
├── tool/                        Architecture and coverage checks
├── docs/                        Architecture notes and ADRs
└── pubspec.yaml                 Pub workspace root and Melos scripts
```

## Getting started

Requirements: Flutter 3.47.1 (Dart 3.13.1).

```sh
flutter pub get                      # resolves the whole workspace
dart run melos run verify            # everything CI checks
cd app && flutter run -t lib/main_dev.dart
```

### One-time: generate the platform folders

The repository holds only Dart code until platform folders are committed.
Generate them once from `app/`:

```sh
cd app
flutter create --platforms=android,ios,web --org dev.siempredelao --project-name cephalopod .
rm -f test/widget_test.dart          # sample test from the template; not used here
```

Commit the new `android/`, `ios/`, `web/` folders and `.metadata`. CI then also
runs Android and web smoke builds.

## Quality gates

Every push and pull request runs, in order:

1. `dart format` check
2. `flutter analyze --fatal-infos` with [very_good_analysis](https://pub.dev/packages/very_good_analysis)
3. Architecture check
4. Engine tests, 100% line coverage required
5. App tests, 85% line coverage required
6. Android APK and web smoke builds

Run the same checks locally with `dart run melos run verify`. Optional git
hooks: install [lefthook](https://lefthook.dev) and run `lefthook install`.

## Roadmap

- [x] **M0 · Foundations**: workspace, lints, CI, ADRs, app shell
- [ ] **M1 · Rules engine**: board, moves, captures, property tests
- [ ] **M2 · Playable MVP**: hot-seat game on one device
- [ ] **M3 · Persistence and undo**: resume, undo/redo, settings
- [ ] **M4 · AI opponent**: three difficulty levels
- [ ] **M5 · Polish**: accessibility, English and Spanish, dark mode, goldens
- [ ] **M6 · Release v1.0**: playable web build on GitHub Pages

## Contributing

Conventional Commits, short-lived branches, squash merges into `main`. The pull
request template lists what a change needs before review.
