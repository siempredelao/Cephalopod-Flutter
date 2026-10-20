# 0003. Persist games as a move log

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

M3 adds save and resume, undo and redo; a replay viewer and online play may
follow. Each of these needs to reconstruct a position. Cephalopod has no
hidden information and no randomness, so a position is fully determined by the
starting configuration and the moves played.

## Decision

Store a game as its configuration plus the ordered list of moves, with a
`schemaVersion` field. Rebuild any position by replaying the moves through the
engine. Never store board snapshots.

```json
{
  "schemaVersion": 1,
  "config": { "boardSize": 5, "firstPlayer": "black" },
  "moves": [{ "row": 0, "col": 1, "captures": [[0, 0], [0, 2]] }]
}
```

## Consequences

- Save, resume, undo, redo and replay share one format and one code path.
- Replaying through the engine validates the save: a corrupt or tampered log
  is rejected and the app starts a fresh game instead of crashing.
- The same format can travel over the network for online play.
- Cost: resuming replays up to a few dozen moves, which is negligible.

## Alternatives considered

- **Board snapshot.** Faster to load, but undo needs a history anyway, and a
  snapshot cannot be validated.
- **Snapshot plus log.** Redundant data that can disagree.
