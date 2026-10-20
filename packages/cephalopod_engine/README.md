# cephalopod_engine

The rules of [Cephalopod](https://www.marksteeregames.com/Cephalopod_rules.pdf)
as a pure-Dart package. It never imports Flutter, performs no I/O and reads no
clock, so every rule is unit-tested in milliseconds and the same code can run
in the app, in an AI opponent or on a game server.

## Rules covered

Each rule has an ID. Tests are named after the rule they cover (`R5: …`), so a
failing test points straight at the rule sheet.

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

## Status

| Milestone | Engine content |
| --- | --- |
| M0 | Package, lints, coverage gate, `Player` |
| M1 | `Position`, `Die`, `Board`, `Move`, `GameState`, `CaptureFinder`, `CephalopodRules` |
| M4 | `GameAgent` with random, greedy and minimax strategies |

## Tests

```sh
dart test                                   # from this folder
dart run melos run test:engine              # from the repo root, with the 100% gate
```
