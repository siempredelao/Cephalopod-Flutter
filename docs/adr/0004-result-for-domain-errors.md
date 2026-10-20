# 0004. `Result` values for expected domain errors

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

Illegal moves are normal events in a game: a tap on an occupied square, a
capture set that sums to more than 6. Storage can fail too. Callers must
handle these outcomes, and exceptions do not show up in a Dart function's
signature.

## Decision

Functions whose failure is part of normal operation return a sealed
`Result<T, E>` (`Ok` or `Err`), with a sealed failure type per area:
`IllegalMove` (`GameOver`, `SquareOccupied`, `CaptureRequired`,
`InvalidCapture`) and `PersistenceFailure`. `Result` lives in the engine
package, so the app reuses the same type. Exceptions remain for programmer
errors, such as constructing a die with 7 pips, and are not caught.

## Consequences

- Failures are visible in signatures, and `switch` over a sealed type forces
  every case to be handled.
- Tests assert on specific failures instead of exception types.
- The UI can explain why a move was refused.
- Cost: a small `Result` type to maintain, and some unwrapping at call sites.

## Alternatives considered

- **Exceptions everywhere.** Idiomatic in Dart, but easy to forget to catch
  and invisible to the compiler.
- **A functional library (`fpdart`).** Powerful, but a large dependency and
  vocabulary for one type.
- **Nullable returns.** Lose the reason for the failure.
