# 0016. Storage failures do not stop the game

- **Status:** Accepted
- **Date:** 2026-11-09

## Context

Every move is saved before it shows: `PlayMove` saves the game, then
returns it. When storage failed, for example a full disk or a platform
error from shared_preferences, the exception left the use case. The move
never appeared, and the screen stayed where it was. The same happened to
starting, undoing and resuming a game.

A lost save costs the game in progress once the app closes. A stuck screen
costs it now, for something the player cannot fix.

[ADR 0004](0004-result-for-domain-errors.md) planned storage failures as
`Result` values, with a `PersistenceFailure` type. That type was never
built, and the repositories return plain futures.

## Decision

Storage failures are reported, and the game goes on. The repository that
talks to the device's storage, `SharedPreferencesGameRepository`, catches
its own failures and hands them to an `ErrorReporter`:

- A failed `save` or `clear` is reported, and the game on screen goes on.
- A failed `load` is reported, and reads as "no saved game", so a new game
  starts.

It catches only `Exception`s, which is how storage reports a failure. An
`Error` is a bug, so it goes on to the app-wide error reporting. The use
cases do not change.

The rule sits in the repository, next to turning the stored JSON into a
game, because the repository is the layer that knows about storage: the
plugin, `SharedPreferencesAsync`, only reads and writes strings.

This replaces the `PersistenceFailure` part of ADR 0004. The rest of ADR
0004 stands: illegal moves are still `Result` values.

## Consequences

- The game keeps going on a device whose storage fails. The player is not
  told, so they may find the game gone after closing the app. Telling them
  would be a later change to the screens.
- A failed load starts a new game, whose first save replaces the save that
  could not be read. If the failure was brief, the old game is lost. We
  accept that: shared_preferences rarely fails to read, and seldom recovers
  when it does.
- The rule lives in one class, the only one that talks to storage. The
  in-memory repository that tests use has nothing to fail, so it does not
  follow the rule.
- The settings follow the same rule, in their own shared_preferences
  repository.
- A second kind of storage, such as cloud sync, would have to catch its
  own failures too. If that happens, the rule can move into one class that
  coordinates both.

## Alternatives considered

- **Stop the move and show an error.** The player could not go on with a
  game they are in the middle of, because of a problem they cannot fix.
- **`Result` values with `PersistenceFailure`, as ADR 0004 planned.** Every
  use case would unwrap a result whose only handling is "report it and go
  on", in four places instead of one.
- **A wrapper repository that adds the rule around another one.** It could
  wrap any storage, but there is only one, so it added a class and a layer
  of nesting in `bootstrap` for no gain.
- **Retry the save.** Storage failures are seldom brief, and a retry would
  delay every move.
