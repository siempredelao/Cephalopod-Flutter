# 0020. The rule sheet link opens with url_launcher

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The About page shows the address of Mark Steere's official rule sheet. Until
now it was text that a person had to copy into a browser. Opening a browser
is a platform call, which Dart alone cannot make.

[ADR 0019](0019-package-info-plus-for-the-app-version.md) added the first
plugin of this kind, for the app's version, and set how such plugins are
kept apart from the rest of the app.

## Decision

Add `url_launcher`, a plugin published by the Flutter team, and open the rule
sheet with it in the phone's browser, outside the app
(`LaunchMode.externalApplication`).

As with the version, the plugin is used in one place, the data layer, and
sits behind a type that the domain owns: `LinkOpener`, a function that opens
an address and says whether it did. Nothing else in the app knows the plugin
exists.

It fails quietly ([ADR 0016](0016-storage-failures-do-not-stop-the-game.md)):
a plugin that throws an `Exception` is reported and counts as "did not
open". The page then says the link could not be opened, and shows the
address as text to copy. An `Error` is a bug, so it goes on to the app-wide
error reporting.

## Consequences

- Tests replace `LinkOpener` with a plain function, so the About page runs
  without a device or a browser. The wrapper is tested against a fake
  `UrlLauncherPlatform`, the plugin's own seam for tests. That needs two
  test-only packages: `url_launcher_platform_interface` and
  `plugin_platform_interface`.
- No `<queries>` entry is added to `AndroidManifest.xml`. url_launcher asks
  for one only for `canLaunchUrl`, which this does not use: `launchUrl`
  tells whether it worked.
- Cost: one more package to keep up to date, with its platform packages in
  the lock file (one per platform the plugin supports, only Android's and
  iOS's are built), and more platform code in every build.
- Cost: that Android opens the browser is only checked by hand. The tests
  show the app asks for it and copes with a refusal.

## Alternatives considered

- **Keep the address as text only.** No dependency, but the address must be
  copied into a browser by hand.
- **Write the platform call ourselves, with a method channel.** No
  dependency, but it is native code for Android and iOS to write, test and
  keep, for something this plugin already does.
- **Show the rule sheet inside the app, in a web view.** Keeps the player in
  the app, but needs a heavier plugin, and a PDF reads better in the phone's
  own viewer.
