# 0022. The review prompt asks with in_app_review

- **Status:** Accepted
- **Date:** 2026-11-13

## Context

Reviews help a new app on Google Play, and the best time to ask for one is
just after a person finishes a game they enjoyed. Google provides a review
sheet that opens over the app, so the person never leaves it, and it only
works for an app installed from Play. Showing it is a platform call, which
Dart alone cannot make.

[ADR 0019](0019-package-info-plus-for-the-app-version.md),
[ADR 0020](0020-url-launcher-for-the-rule-sheet-link.md) and
[ADR 0021](0021-audioplayers-for-the-game-sounds.md) set how such plugins
are kept apart from the rest of the app.

## Decision

Add `in_app_review`, a plugin that wraps Google's Play review library on
Android and Apple's rating prompt on iOS, and ask for the review sheet with
it.

As with the earlier plugins, it is used in one place, the review feature's
data layer, and sits behind a type that the domain owns: `ReviewRequester`,
a function that asks the store to show its review sheet. Nothing else in the
app knows the plugin exists.

How it asks:

- **Only when the phone can show the sheet** (`isAvailable`): an app that
  was not installed from Play, or a phone without Play, asks for nothing.
- **It says nothing about the outcome.** The store decides whether the sheet
  shows and limits how often it can, and it does not say what the person
  did. So the type returns nothing, and the app cannot depend on a review
  happening.

It fails quietly ([ADR 0016](0016-storage-failures-do-not-stop-the-game.md)):
a plugin that throws an `Exception` is reported and nothing happens. An
`Error` is a bug, so it goes on to the app-wide error reporting.

When to ask is not decided here: a later change counts finished games in
the review feature and asks after the third, and at most once more after the
tenth. Until then nothing calls `ReviewRequester`.

## Consequences

- Tests replace `ReviewRequester` with a plain function, so nothing needs a
  phone or the store. The wrapper is tested against a fake
  `InAppReviewPlatform`, the plugin's own seam for tests. That needs one
  test-only package, `in_app_review_platform_interface`, besides
  `plugin_platform_interface`, which the About page's tests already use.
- Cost: one more package to keep up to date, with its platform interface in
  the lock file, and Google's Play review library in every Android build.
- Cost: that the sheet shows is only checked by hand, from a build installed
  from Play (internal testing is enough). Google also limits how often the
  sheet shows, so it can fail to appear on a phone that already reviewed.
- The "Rate the app" link planned for About can use the same plugin
  (`openStoreListing`), behind its own type, in its own ADR or an update
  to this one.

## Alternatives considered

- **Only a "Rate the app" link to the store page.** No dependency, but
  people leave the app to write a review, and far fewer do.
- **Write the platform call ourselves, with a method channel.** No
  dependency, but it is Kotlin and Swift to write, test and keep, for
  something this plugin already does.
- **Ask with our own dialog first** ("Are you enjoying Cephalopod?"). It
  filters out unhappy people, but Google's guidelines discourage gating the
  review sheet that way, and it is one more screen to translate in twelve
  languages.
