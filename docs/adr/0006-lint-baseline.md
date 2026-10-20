# 0006. very_good_analysis 10.x; primary constructors deferred

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

`very_good_analysis` is the strict lint set for every package. Version 11.0
requires Dart 3.13 and adds `use_declaring_parameters` and
`unnecessary_type_name_in_constructor`, which push code toward primary
constructors and `new`-named constructors, both new in Dart 3.13. Code
generators planned for later milestones (`freezed`, `json_serializable`) and
most published Flutter examples still use classic constructors.

## Decision

Pin `very_good_analysis` to `^10.3.0` and keep classic constructors for now.
Revisit when the code generators used here support primary constructors.

## Consequences

- Code reads like current Flutter documentation and examples, which helps
  reviewers.
- No churn when code generation is added.
- Cost: the codebase does not yet use the newest constructor syntax. Moving
  later is mostly automatic with `dart fix`.

## Alternatives considered

- **Adopt 11.x now.** Newest style, but mixes two constructor styles once
  generated code arrives.
- **Disable the two new rules under 11.x.** Possible, but hides the reason
  in a lint config instead of recording it here.
