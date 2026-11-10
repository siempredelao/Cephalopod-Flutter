# 0019. Two plugins for the About page: url_launcher and package_info_plus

- **Status:** Accepted
- **Date:** 2026-11-10

## Context

Until now the app has had no packages beyond Flutter's own, the ones that
shape the code (bloc, go_router, freezed) and storage
([ADR 0012](0012-shared-preferences-for-local-storage.md)). The About page
needs two things only the phone can do:

- Open the official rule sheet in the browser. The address was only text
  that a person had to copy.
- Say which version of the app is running, so that a bug report can name it.

Neither can be written in Dart alone: opening a browser and reading the
app's own version are platform calls.

## Decision

Add two plugins, both published and maintained by the Flutter team:

- `url_launcher` opens the rule sheet in the phone's browser.
- `package_info_plus` reads the version and build number from the app's
  own package, so there is no second copy of them in the code to keep up to
  date.

Neither is used outside the data layer. As with storage, each sits behind a
small type that the domain owns, so nothing else in the app knows the plugin
exists:

- `LinkOpener`, a function that opens an address and says whether it did.
- `AppVersionSource`, a function that gives the version, or `null`.

Both fail quietly ([ADR 0016](0016-storage-failures-do-not-stop-the-game.md)):
a plugin that throws an `Exception` is reported and the app goes on. The About
page then shows no version, or says the link could not be opened and shows
the address to copy.

## Consequences

- Tests replace both seams with plain functions, so About runs without a
  device or a browser. The two wrappers are tested against the plugins' own
  test hooks (`PackageInfo.setMockInitialValues`, and a fake
  `UrlLauncherPlatform`).
- The version is shown from what the build says, so it cannot go out of
  date.
- Cost: two more packages to keep up to date, and more platform code in
  every build. The tests also depend on two test-only packages,
  `url_launcher_platform_interface` and `plugin_platform_interface`.
- Cost: the link opening is only proved on a real phone. The tests show the
  app asks for it and copes with a refusal, but not that Android opens the
  browser.

## Alternatives considered

- **Show the address as text only, as before.** No dependency, but the
  address must be copied by hand into a browser.
- **Write the version in the code, or in a constant that the build fills.**
  No plugin, but it is a second place to update with each release, and it
  can be forgotten.
- **Write the platform calls ourselves, with a method channel.** No
  dependency, but it is native code for Android and iOS to write, test and
  keep, for something these plugins already do.
