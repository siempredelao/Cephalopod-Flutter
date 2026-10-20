# 0005. Use cases only where they earn their place

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

Clean-architecture templates often add a use case class for every call, even
when it only forwards to a repository. Flutter's architecture guide treats the
domain layer as optional and suggests adding use cases when logic combines
several repositories, is complex, or is shared by several view models.

## Decision

Add an app-level use case only when it combines the engine with a repository
or holds logic reused by more than one bloc. The planned set is
`StartNewGame`, `PlayMove`, `UndoMove`, `ResumeGame` and `RequestAgentMove`.
Blocs may read simple data, such as settings, from a repository directly.

## Consequences

- Each use case has a reason to exist that a reviewer can see.
- Less boilerplate and fewer mocks in tests.
- Cost: a judgement call per feature; reviewers check that a new use case is
  not a pass-through.

## Alternatives considered

- **A use case for every operation.** Uniform, but adds classes that do
  nothing, which is its own maintenance cost.
- **No domain layer.** Game logic would leak into blocs, the very thing the
  engine package exists to prevent.
