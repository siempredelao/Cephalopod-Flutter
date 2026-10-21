# 0010. Constructor injection in the engine

- **Status:** Accepted
- **Date:** 2026-10-21

## Context

The engine's services created their own collaborators in private fields,
such as `final BoardGeometry _geometry = BoardGeometry();`. Their
dependencies were hidden from callers, every service built its own copies,
and the engine broke the rule the app follows: dependencies arrive through
constructors and are wired in one place.

## Decision

Every engine service takes its collaborators as required, named constructor
parameters: `CaptureFinder(geometry:)` and
`MoveValidator(geometry:, captureFinder:)`. `BoardGeometry` and `Referee`
need none. The parameters are private named initializing formals
(`required this._geometry`, Dart 3.12+): the field stays private and callers
still write `geometry:`, with no initializer list to keep in sync.

`CephalopodRules` is the engine's composition root. Its factory constructor
creates the services, sharing one `BoardGeometry` and one `CaptureFinder`,
and accepts any of them as an optional argument. Callers still write
`CephalopodRules()`.

## Consequences

- A service's dependencies are visible in its constructor, as with Kotlin
  constructor injection.
- One instance of each service per `CephalopodRules`, shared by the parts
  that need it.
- Tests that build an inner service on its own pass its dependencies
  explicitly.
- No interfaces or mocks: the services are pure and deterministic, so tests
  use the real collaborators. They stay `final class`; if a test double is
  ever needed, that class drops `final`, since `final` forbids implementing
  it outside its library.

## Alternatives considered

- **Collaborators created in private fields (before).** Hidden dependencies
  and duplicate instances.
- **Optional parameters with defaults on every service.** Wiring spread over
  many classes, and defaults that create unshared instances.
- **A DI container (`get_it`, `injectable`).** Useful in the app if wiring
  grows; overkill for a small pure package.
