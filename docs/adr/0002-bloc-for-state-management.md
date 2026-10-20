# 0002. Bloc for state management

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

The game screen moves through clear phases: waiting for a placement, choosing
which dice to capture, waiting for the AI, game over. User actions arrive one
at a time and each produces a new, immutable state. The state logic must be
testable without widgets, and the choice should be familiar to Flutter
reviewers.

## Decision

Use `flutter_bloc`: a `GameBloc` per game screen, with sealed event and state
classes, and Cubits for simple screens such as settings. The bloc plays the
view-model role from Flutter's architecture guide. Widgets only render state
and add events; `BlocSelector` limits rebuilds to the cells that changed.

## Consequences

- Events make every user intent explicit, and a `BlocObserver` can log every
  event of a game.
- `bloc_test` expresses flows as "given events, expect states", which reads
  like the rule sheet.
- Sealed classes plus `switch` make missing cases compile errors.
- Cost: more types (events, states) than a plain `ChangeNotifier`.

## Alternatives considered

- **Riverpod.** Strong for many small async data sources and caching. This app
  has one central state machine, where explicit events read better.
- **`ChangeNotifier` view models (the guide's default).** Least boilerplate,
  but no event log and weaker testing conventions.
- **Signals or MobX.** Fine-grained reactivity is not needed for a 25-cell
  board.
