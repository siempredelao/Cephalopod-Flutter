# Architecture decision records

Each record captures one decision: the context, what was decided, and what it
costs. Records are never edited after they are accepted; a later record
supersedes an earlier one instead. Start new records from
[template.md](template.md).

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](0001-pure-dart-engine-package.md) | Rules engine as a pure-Dart package in a pub workspace | Accepted |
| [0002](0002-bloc-for-state-management.md) | Bloc for state management | Accepted |
| [0003](0003-move-log-persistence.md) | Persist games as a move log | Accepted |
| [0004](0004-result-for-domain-errors.md) | `Result` values for expected domain errors | Accepted |
| [0005](0005-use-cases-only-where-needed.md) | Use cases only where they earn their place | Accepted |
| [0006](0006-lint-baseline.md) | very_good_analysis 10.x; primary constructors deferred | Accepted |
| [0007](0007-material-ui-package.md) | Material widgets from `package:material_ui` | Accepted |
| [0008](0008-hand-written-equality.md) | Hand-written value equality in the engine | Accepted |
| [0009](0009-plain-data-types.md) | Engine data types hold no behaviour | Accepted |
| [0010](0010-constructor-injection-in-the-engine.md) | Constructor injection in the engine | Accepted |
| [0011](0011-freezed-for-ui-states.md) | `freezed` for the app's UI states; generated code not committed | Accepted |
| [0012](0012-shared-preferences-for-local-storage.md) | Local storage with `shared_preferences` | Accepted |
