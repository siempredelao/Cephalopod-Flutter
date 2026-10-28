# 0013. Hand-written feature modules instead of a DI container

- **Status:** Accepted
- **Date:** 2026-10-28

## Context

`app/bootstrap.dart` built every object in the app and the router took one
factory parameter per screen. That was right for a handful of objects, but
both grow with every feature: dozens of features would mean one function
that knows every use case, and a router signature that names every bloc.

Flutter projects usually solve this with a service locator (`get_it`), with
generated registration on top of it (`injectable`, the closest thing to
Hilt), or with dependency injection through the widget tree (`provider`,
`RepositoryProvider`, Riverpod).

## Decision

Keep wiring by hand, split into feature modules. Each feature has a module
at `features/<f>/<f>_module.dart` that builds its own objects from the
dependencies the composition root hands it and exposes its routes through
`FeatureModule` in `core/navigation`. `bootstrap.dart` only picks the
concrete implementations and connects features to each other, and the
router nests every module's routes under Home.

## Consequences

- Adding a feature means writing its module and adding one entry to the
  list in `bootstrap.dart`. The router does not change.
- The router no longer imports pages or blocs.
- Wiring stays checked by the compiler: a missing dependency is a compile
  error, not a runtime lookup failure.
- Features still never import each other. When one needs another's
  behaviour, the composition root passes it as a plain function, as Home
  gets `hasGameToContinue` from the game module and the game gets
  `highlightLastMove` from the settings module.
- Each module's wiring is written by hand. If that becomes the dominant
  cost, the modules map directly onto `injectable` modules, so moving to it
  changes the wiring code and nothing else.

## Alternatives considered

- **One composition root for everything (before).** Simple, but it and the
  router grow with every feature.
- **`get_it` with `injectable`.** Less wiring code, but code generation,
  lookups that fail at run time, and the temptation to call the locator
  from inside widgets and blocs. Not worth it for a few features.
- **The widget tree (`RepositoryProvider`, Riverpod).** Ties dependencies
  to `BuildContext` and to where widgets sit in the tree; Riverpod would
  also overlap with Bloc ([ADR 0002](0002-bloc-for-state-management.md)).
