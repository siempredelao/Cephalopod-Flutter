# 0007. Material widgets from `package:material_ui`

- **Status:** Accepted
- **Date:** 2026-10-20

## Context

Since Flutter 3.47 the Material and Cupertino libraries ship as standalone
packages, `material_ui` and `cupertino_ui`. The in-framework libraries
(`package:flutter/material.dart`) are frozen and scheduled for deprecation
([migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)).
This is a new project, so there is no code to migrate.

## Decision

Import Material from `package:material_ui/material_ui.dart` everywhere. Do not
import `package:flutter/material.dart`. Lower-level code imports
`package:flutter/widgets.dart` only.

## Consequences

- No migration later, and Material fixes arrive with package updates instead
  of SDK upgrades.
- `go_router` 18 already uses `material_ui`, so types line up.
- Cost: a few third-party packages still expose types from the old library;
  any such package needs the compatibility bridge or an update before use.
  Check this when adding a UI dependency.

## Alternatives considered

- **Keep `package:flutter/material.dart`.** Works today, but the code would
  start life on a deprecated path.
