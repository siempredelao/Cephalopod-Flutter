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

Storage failures are reported, and the game goes on.
`BestEffortGameRepository` wraps the device's repository in the composition
root:

- A failed `save` or `clear` is reported, and the game on screen goes on.
- A failed `load` is reported, and reads as "no saved game", so a new game
  starts.

It catches only `Exception`s, which is how storage reports a failure. An
`Error` is a bug, so it goes on to the app-wide error reporting. The use
cases do not change.

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
- The rule lives in one class, chosen in `bootstrap`. Tests and the
  in-memory repository are unaffected.
- The settings follow the same rule.

## Alternatives considered

- **Stop the move and show an error.** The player could not go on with a
  game they are in the middle of, because of a problem they cannot fix.
- **`Result` values with `PersistenceFailure`, as ADR 0004 planned.** Every
  use case would unwrap a result whose only handling is "report it and go
  on", in four places instead of one.
- **Retry the save.** Storage failures are seldom brief, and a retry would
  delay every move.
