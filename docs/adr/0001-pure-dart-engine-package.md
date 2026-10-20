# 0001. Rules engine as a pure-Dart package in a pub workspace

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

The game rules are the most valuable and most error-prone part of the app.
They are used by the UI, will be used by an AI opponent (M4), and could be
used by a server that validates online moves. Rules mixed into widgets or
view models are slow to test and impossible to reuse outside Flutter.

## Decision

Put the rules in `packages/cephalopod_engine`, a package with no Flutter
dependency, and make it and the app members of one pub workspace. The engine
exposes a single barrel file; everything under `lib/src` is internal. It does
no I/O and reads no clock; randomness, where an AI needs it, is injected.

## Consequences

- The compiler, not code review, keeps Flutter out of the rules: the package
  cannot import it.
- Engine tests run with `dart test` in milliseconds, with no widget binding.
- The AI and a future server reuse the exact same rules.
- One lockfile and one `flutter pub get` for the whole repository.
- Cost: a second pubspec and the workspace setup, paid once.

## Alternatives considered

- **A `domain/` folder inside the app.** Simpler to start, but nothing stops a
  Flutter import from creeping in, and reuse outside the app needs a later
  extraction.
- **Separate repositories.** Real isolation, but versioning two repos for one
  game adds friction with no benefit at this size.
- **Melos without pub workspaces.** Melos 7+ builds on workspaces, which give a
  single resolution and lockfile; Melos is kept only for scripts.
