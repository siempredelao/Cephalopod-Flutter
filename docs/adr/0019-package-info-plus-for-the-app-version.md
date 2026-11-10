# 0019. The app's version from package_info_plus

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The About page should say which version of the app is running, so that a bug
report can name it. The version is written in one place, `app/pubspec.yaml`,
and the platform builds it into the installed app. Reading it back means
asking the platform, which Dart alone cannot do.

Until now the app has had no packages beyond Flutter's own, the ones that
shape the code (bloc, go_router, freezed) and storage
([ADR 0012](0012-shared-preferences-for-local-storage.md)).

## Decision

Add `package_info_plus`, a plugin published by the Flutter team, and read
the version and build number from the app's own package. There is no second
copy of them in the code to keep up to date.

The plugin is used in one place, the data layer, and sits behind a type that
the domain owns, as storage does: `AppVersionSource`, a function that gives
the version, or `null` when it cannot be known. Nothing else in the app
knows the plugin exists.

It fails quietly ([ADR 0016](0016-storage-failures-do-not-stop-the-game.md)):
a plugin that throws an `Exception` is reported, and the About page shows no
version. An `Error` is a bug, so it goes on to the app-wide error reporting.

## Consequences

- Tests replace `AppVersionSource` with a plain function, so the About page
  runs without a device. The wrapper itself is tested against the plugin's
  own test hook, `PackageInfo.setMockInitialValues`, and with a plugin that
  throws.
- The version shown comes from the build, so it cannot go out of date.
- Cost: one more package to keep up to date, and more platform code in every
  build.
- Cost: that the version matches `pubspec.yaml` on a real phone is only
  checked by hand.

## Alternatives considered

- **Write the version in the code, or in a constant the build fills.** No
  plugin, but it is a second place to update with each release, and it can be
  forgotten.
- **Write the platform call ourselves, with a method channel.** No
  dependency, but it is native code for Android and iOS to write, test and
  keep, for something this plugin already does.
- **Show no version.** Nothing to add, but a bug report could not say which
  build it came from.
