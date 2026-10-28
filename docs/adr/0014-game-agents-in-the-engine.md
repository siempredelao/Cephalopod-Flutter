# 0014. Computer opponents as engine agents

- **Status:** Accepted
- **Date:** 2026-10-28

## Context

M4 adds a computer opponent with three difficulty levels. The app must be
able to swap one level for another without touching the game screen, tests
must replay an opponent's choices exactly, and the screen must stay
responsive while the computer thinks. The engine performs no I/O and reads no
clock, and randomness is injected
([ADR 0001](0001-pure-dart-engine-package.md)).

## Decision

Each difficulty level is a class in the engine that implements one
interface, `GameAgent`, with a single method: `Move chooseMove(GameState)`.

- **Narrow dependency.** Agents receive the rules as a `MoveGenerator`, an
  interface with only `legalMoves` and `apply`, which `CephalopodRules`
  implements. They cannot start or replay games.
- **Injected randomness.** Agents that choose at random take a
  `dart:math` `Random`. Tests pass a seeded one; the app passes an unseeded
  one so games vary.
- **Bounded by work, not time.** A searching agent stops after a fixed number
  of positions, not after a number of milliseconds. Its move then depends only
  on the position and the seed.
- **Synchronous.** `chooseMove` returns a `Move`, not a `Future`. The app
  runs it off the UI isolate, so the engine stays free of async code.
- **One contract.** Every agent runs the same test suite: only legal moves,
  for both players, to the end of a game; the same moves for the same seed;
  the only legal move when there is one; an `ArgumentError` for a finished
  game.

The levels, delivered one per pull request:

| Level | Agent | Strategy |
| --- | --- | --- |
| Easy | `RandomAgent` | Any legal move, uniformly at random |
| Medium | `GreedyAgent` | The move with the best position after it, ties at random |
| Hard | `SearchAgent` | Alpha-beta search a few moves deep, within a node budget |

## Consequences

- A new opponent is a new class; the bloc and the use cases do not change
  (open/closed).
- Tests can check an agent's exact moves, and a seeded tournament can show
  that each level beats the one below it.
- The Hard level's strength does not depend on the device: a slow phone
  thinks longer instead of playing worse.
- Cost: on a slow device the Hard level may take noticeably longer, so its
  budget must be tuned for the slowest device that matters.
- Cost: the app must move each computer turn to another isolate, which is the
  app's job (M4, 5/6).

## Alternatives considered

- **Time-limited search (iterative deepening until a deadline).** Uses the
  time it has best, but needs a clock, which the engine does not read, and
  gives different moves on different devices, so tests cannot pin them.
- **Monte Carlo tree search.** Needs no evaluation function and handles wide
  boards well, but its strength grows with the number of playouts, so it is
  either slow or weak on a phone, and seeded results are harder to reason
  about than a fixed-depth search.
- **One configurable agent (search depth plus noise) for every level.**
  Fewer classes, but Easy would be "search with depth 0 and full noise",
  which hides what it does, and a change for one level risks the others.
- **`Future<Move> chooseMove`.** Would let an agent run remotely, but the
  engine has no I/O, and the app can wrap a synchronous call in an isolate.
- **Agents in the app.** Simpler wiring, but they could not be tested
  without Flutter, and a future server could not reuse them.
