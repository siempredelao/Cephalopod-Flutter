# cephalopod_engine

The rules of [Cephalopod](https://www.marksteeregames.com/Cephalopod_rules.pdf)
as a pure-Dart package. It never imports Flutter, performs no I/O and reads no
clock, so every rule is unit-tested in milliseconds and the same code can run
in the app, in an AI opponent or on a game server. Its only dependencies are
the Dart-team packages `meta` and `collection`.

## Usage

```dart
import 'package:cephalopod_engine/cephalopod_engine.dart';

final rules = CephalopodRules();
var state = rules.newGame();

final move = rules.legalMoves(state).first;
switch (rules.apply(state, move)) {
  case Ok(:final value):
    state = value;
  case Err(:final error):
    // An IllegalMove: GameOver, OutsideBoard, SquareOccupied,
    // CaptureRequired or InvalidCapture.
    throw StateError('$error');
}

switch (state.status) {
  case InProgress(:final toMove):
    print('${toMove.name} to move');
  case Finished(:final winner):
    print('${winner.name} wins');
}
```

A `Move` is a square plus the set of squares it captures. The value of the new
die is never part of the move: the rules derive it from the captures.

## Design

Data types hold data only, like Kotlin data classes; the rules live in
stateless services ([ADR 0009](../../docs/adr/0009-plain-data-types.md)).
Services receive their collaborators through their constructors, and
`CephalopodRules()` wires a shared set by default
([ADR 0010](../../docs/adr/0010-constructor-injection-in-the-engine.md)).

| Data | Holds |
| --- | --- |
| `Player`, `Position`, `Die` | Basic values |
| `Board` | Board size and the die on each occupied square |
| `Move` | Target square and captured squares |
| `GameConfig` | Every rule constant; `GameConfig.standard` is the published game |
| `GameStatus` | Sealed: `InProgress(toMove)` or `Finished(winner, blackDice, whiteDice)` |
| `GameState` | Board, status and config |
| `GameRecord` | Config and the moves played: a game as it is saved ([ADR 0003](../../docs/adr/0003-move-log-persistence.md)) |
| `Result`, `IllegalMove`, `ReplayFailure` | Sealed outcomes ([ADR 0004](../../docs/adr/0004-result-for-domain-errors.md)) |

| Service | Rules | Does |
| --- | --- | --- |
| `BoardGeometry` | R3 | Squares of the board and their neighbours |
| `CaptureFinder` | R4, R6 | Capture options from a square, and pip sums |
| `Referee` | R8 | Whether the game is over, and who won |
| `MoveValidator` | R2, R4, R5 | `violationOf`: the first rule a move breaks, checked in order |
| `CephalopodRules` | R1, R7, R8 | `newGame`, `opponentOf`, `legalMoves`, `apply`, and `replay`, which rebuilds a `GameRecord` |

## Rules covered

Each rule has an ID. Tests are named after the rule they cover (`R5: …`), so a
failing test points straight at the rule sheet. Figures 2 to 5 of the rule
sheet are test fixtures.

| ID | Rule |
| --- | --- |
| R1 | 5×5 board, starts empty. Black and White alternate turns. |
| R2 | A turn is exactly one die placed on an empty square. No passing. |
| R3 | Adjacency is orthogonal only (2, 3 or 4 neighbours). |
| R4 | A placement captures when 2+ adjacent dice sum to 6 or less, any colour. |
| R5 | Where a capture is possible it is mandatory; the player picks the set. |
| R6 | A capturing die shows the sum of the removed dice. |
| R7 | A non-capturing die shows 1. |
| R8 | The game ends when all 25 squares are full; most dice wins. |

The property test plays 1,000 seeded random games to the end and checks after
every move that the pip total and dice count change as the rules say, that
turns alternate, and that every game ends within the proven bound of 300
moves with a majority winner.

## Test helpers

`package:cephalopod_engine/testing.dart` builds boards and states from text
grids, and `boardToAscii` prints a board in the same format:

```dart
final state = stateFromAscii('''
  .  w1 .  w1 .
  .  .  b5 .  .
  .  .  .  .  .
  .  .  .  .  .
  .  .  .  .  .
''', toMove: Player.black);
```

## Tests

```sh
dart test                                   # from this folder
dart run melos run test:engine              # from the repo root, with the 100% gate
```
