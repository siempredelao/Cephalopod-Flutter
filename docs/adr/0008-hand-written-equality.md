# 0008. Hand-written value equality in the engine

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

The engine's models (`Position`, `Die`, `Board`, `Move`, `GameConfig`,
`GameStatus`, `GameState`) are values: two boards with the same dice are the
same board. Tests, the AI and the app's state management all compare them.

The original plan used `equatable`. Its 3.0 release changed what equality
means (it no longer checks the runtime type) and dropped its `toString`.
Code generation (`freezed`) would add a build step to a package that has
none. The engine is meant to depend on as little as possible.

## Decision

Each value type implements `==` and `hashCode` by hand and is annotated
`@immutable` from `package:meta`. Collections inside values are compared with
`ListEquality` and `SetEquality` from `package:collection`. The engine's only
dependencies are these two Dart-team packages.

## Consequences

- What makes two values equal is written next to the fields, with no hidden
  semantics and no generated code.
- Every value type has a test for equality and hash codes, which also guards
  against a field being left out when one is added.
- Cost: about six lines of boilerplate per type.

## Alternatives considered

- **`equatable`.** Less code, but a third-party dependency whose semantics
  changed in a major release.
- **`freezed`.** Also generates `copyWith` and JSON, but brings `build_runner`
  into the engine. It stays an option for the app's UI states.
- **Records.** Structural equality for free, but no methods, no per-field
  documentation and no named type in error messages.
