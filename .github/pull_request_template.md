## What

<!-- One or two sentences on what this change does. -->

## Why

<!-- The problem or milestone task it addresses. Link the rule ID (R1–R8) for rule changes. -->

## How to test

<!-- Commands or steps a reviewer can run. -->

## Screenshots

<!-- For UI changes: before and after, light and dark. Delete for non-UI changes. -->

## Checklist

- [ ] Title follows Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, `ci:`)
- [ ] Tests added or updated; `dart run melos run verify` passes locally
- [ ] No new imports that break the dependency rule (`docs/architecture.md`)
- [ ] ADR added or updated if a decision changed
