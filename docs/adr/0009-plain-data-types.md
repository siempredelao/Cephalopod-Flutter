# 0009. Engine data types hold no behaviour

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

The first draft of the engine used rich models: `Position.neighbours`,
`Board.place`, a `GameState` that worked out its own status. Game rules were
spread across the data types and the rules class.

Common Kotlin practice, and Flutter's architecture guide, keep models as
plain immutable data and put behaviour in separate classes. For a rules
engine made of pure functions over values, that split also puts every rule in
one place.

## Decision

Data types (`Player`, `Position`, `Die`, `Board`, `Move`, `GameConfig`,
`GameStatus`, `GameState`) hold fields, value equality and `toString` only:
the equivalent of Kotlin data classes. They do no validation and compute
nothing.

Behaviour lives in stateless services under `lib/src/rules`, one concern
each:

| Service | Rule | Answers |
| --- | --- | --- |
| `BoardGeometry` | R3 | Which squares exist, which touch |
| `CaptureFinder` | R4, R6 | Which captures a square offers, and their pip sum |
| `Referee` | R8 | Whether the game is over, and who won |
| `CephalopodRules` | R1, R2, R5, R7 | New game, legal moves, playing a move |

## Consequences

- Each rule has one home, and the services can be read and tested alone.
- Data serialises as is, for the move log, isolates or the network.
- The engine's models look like the app's data classes.
- A `GameState` built by hand can be inconsistent, such as a full board
  marked in progress. Only `CephalopodRules` and the test helper
  `stateFromAscii` build states, and both take the status from `Referee`.
- `GameConfig` is validated when a game starts (`newGame`), not when it is
  built.
- Call sites name the service: `geometry.neighbours(square, size)` instead
  of `square.neighbours(size)`.

## Alternatives considered

- **Rich models (the first draft).** Invalid states are harder to build, but
  rules end up spread over many types.
- **Extension methods on the models.** Keeps the data classes plain and the
  call sites short, but reads as if the model owned the rule and hides which
  part of the rules a call belongs to.
