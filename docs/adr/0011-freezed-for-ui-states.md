# 0011. freezed for the app's UI states

- **Status:** Accepted
- **Date:** 2026-10-21

## Context

`GameBloc` (M2) emits immutable states, and those states need:

- value equality, because Bloc skips a state equal to the current one and
  `bloc_test` compares the states a bloc emits;
- `copyWith`, because most events change one field and keep the rest;
- a readable `toString`, for test failures;
- a sealed union for the turn phase, so a `switch` must handle every phase.

The engine writes `==` and `hashCode` by hand (ADR 0008) to stay free of
code generation, and left `freezed` open for the app. `freezed` is the most
common way Flutter teams write such classes, so it is worth showing here.

## Decision

Presentation states are `freezed` classes: `@freezed abstract class` for a
plain data class (`GameViewState`) and `@freezed sealed class` for a union
(`TurnPhase`). Code reads unions with Dart's `switch` and patterns, not the
legacy `when` and `map` helpers. States stay plain data: no methods, no
getters with logic. The bloc computes what the screen shows.

- Events stay plain sealed classes, because nothing compares or copies them.
- The engine keeps hand-written equality (ADR 0008).
- Generated files (`*.freezed.dart`) are not committed.
  `dart run melos run generate` runs `build_runner`, and CI runs it before
  analysis, tests and builds. The files mark themselves
  `// dart format off` and `// coverage:ignore-file`, and analysis excludes
  them, so no check needs a special case.

## Consequences

Pros:

- `==`, `hashCode`, `toString` and `copyWith` are generated, so a new field
  can't be left out of any of them. In Kotlin terms, a `data class`.
- Collections are compared by content (lists in order, sets in any order)
  and made unmodifiable.
- Unions are real sealed classes, so a missing case is a compile error.
- `copyWith` can set a nullable field back to `null`, which a hand-written
  `copyWith` usually gets wrong.
- Reviewers know it, and it pairs with `json_serializable` if the M3 storage
  DTOs need JSON.

Cons:

- A build step. Forgetting to regenerate gives errors about a missing
  `_$GameViewState` until `generate` runs again; `generate:watch` helps.
- Not committing generated code keeps diffs small and avoids merge conflicts
  and stale output. The price: every clone and every CI job generates first,
  and GitHub can't show the generated code.
- Unfamiliar syntax: `const factory ... = _GameViewState`, the `_$` mixin,
  and a `part` file. Go-to-definition can land in generated code.
- It is tied to analyzer versions, in both directions. On Flutter 3.47 the
  app gets `freezed` 4.0.1, not the latest: 4.0.2 needs analyzer 14, while
  the `test` version that `flutter_test` allows caps analyzer below 14.
- Deep equality walks collections on every comparison, which is negligible
  for a 25-square board.

`freezed` 4 supports primary constructors, which removes one reason ADR 0006
gives for staying on very_good_analysis 10. Revisit that ADR when the other
generators planned here support them too.

## Alternatives considered

- **Hand-written classes, as in the engine.** No build step, but about six
  lines of equality per type plus a hand-written `copyWith`.
- **`equatable`.** Equality only, no `copyWith`, and its semantics changed in
  3.0 (ADR 0008).
- **Records.** Structural equality for free, but no names in error messages,
  no documentation per field and no `copyWith`.
- **`dart_mappable`.** Similar generated features, less common.
- **Committing generated files.** Readers need no build step, but every model
  change adds hundreds of generated lines to the diff (the 600-line pull
  request limit), causes merge conflicts, and can drift when someone forgets
  to regenerate.
- **Waiting for macros.** Dart stopped work on macros in January 2025, so
  code generation remains the way to get these features.
