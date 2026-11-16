# Contributing to Cephalopod

Thank you for your interest in Cephalopod! This page says how a change gets into
`main`.

## Contributing a fix or feature

Contributions are managed with issues and pull requests.

1. Open an [issue](https://github.com/siempredelao/Cephalopod-Flutter/issues)
   that describes the fix or feature, so it can be talked about before any code
   is written.
2. When the issue is accepted, fork the repository and make a short-lived branch
   from `main`.
3. Make the change, as small as you can. A person reads every pull request, so
   several short ones are easier to review than one long one.
4. Make sure it follows the [code style and structure](#code-style-and-structure)
   and that it is tested.
5. Run `dart run melos run verify` (see [Quality gates](README.md#quality-gates)).
   It runs what CI runs, so it should be green before you open the pull request.
6. Open a pull request and fill in its template. It lists what a change needs
   before review.

Pull requests are squash-merged into `main`, so the pull request title becomes
the commit message.

## Commit messages and titles

Use [Conventional Commits](https://www.conventionalcommits.org): `feat:`, `fix:`,
`refactor:`, `test:`, `docs:`, `chore:` or `ci:`, then a short sentence in the
present tense, for example `feat(game): give a hint`.

## Code style and structure

- Flutter and Dart are the versions in [Getting started](README.md#getting-started).
- `dart format` and `flutter analyze --fatal-infos` with
  [very_good_analysis](https://pub.dev/packages/very_good_analysis) must pass.
  Optional git hooks run them for you: install [lefthook](https://lefthook.dev)
  and run `lefthook install`.
- Keep to the dependency rule in [docs/architecture.md](docs/architecture.md):
  the rules live in the pure-Dart `cephalopod_engine` package, and the app sits on
  top of it. CI checks the boundaries.
- Write readable names and short methods.
- Add or update tests. The engine needs 100% line coverage and the app 85%.
- When you change a decision, add or update an
  [ADR](docs/adr/README.md) in `docs/adr/`.
- Words the player sees are translated: add them to every language, because a
  test checks that all of them have the keys of the English file
  (`app/lib/core/l10n`).
