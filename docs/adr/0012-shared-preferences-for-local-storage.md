# 0012. Local storage with shared_preferences

- **Status:** Accepted
- **Date:** 2026-10-21

## Context

M3 saves the game in progress (one move log, ADR 0003) and a few settings.
The app ships to Android and iOS, and M6 publishes a web build, so the store
must work on all three. The data is small: one JSON string and a handful of
values.

## Decision

Use `shared_preferences` through `SharedPreferencesAsync`. The game is one
JSON string under one key; each setting is its own key. Repositories wrap the
store behind domain interfaces (`GameRepository`), so nothing outside the data
layer knows it exists.

## Consequences

- One implementation covers Android, iOS and the web.
- Tests run on `InMemorySharedPreferencesAsync`, with no platform channels,
  and the same contract suite as the in-memory repository.
- Cost: no queries or transactions. A game history or replay library would
  need a database; swapping it in means a new `GameRepository`
  implementation, not changes to the domain.
- Cost: plugin code means the lockfile changes and the smoke builds pull in
  platform code.

## Alternatives considered

- **A JSON file (`path_provider` + `dart:io`).** Simple, but `dart:io` does
  not run on the web, so the web build would need a second implementation.
- **A database (drift, Isar).** Typed queries and room to grow, but far more
  than one saved game and a few settings need.
