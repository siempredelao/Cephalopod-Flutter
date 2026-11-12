# 0021. The game's sounds play with audioplayers

- **Status:** Accepted
- **Date:** 2026-11-12

## Context

The game is to play a short pop when dice are captured and a chime when
the player wins, unless Settings' Sound switch is off. The two sounds are
already in the app, in `app/assets/sounds/`, made by `tool/make_sounds.dart`.
Playing a sound is a platform call, which Dart alone cannot make.

[ADR 0019](0019-package-info-plus-for-the-app-version.md) and
[ADR 0020](0020-url-launcher-for-the-rule-sheet-link.md) set how such
plugins are kept apart from the rest of the app.

## Decision

Add `audioplayers`, a widely used plugin published by Blue Fire, the team
behind the Flame game engine, and play both sounds with it.

As with the About page's plugins, the plugin is used in one place, the game
feature's data layer, and sits behind a type that the domain owns:
`SoundEffects`, with `playCapture()` and `playWin()`. Nothing else in the
app knows the plugin exists.

How the sounds play:

- **Each sound has its own player**, made the first time that sound plays,
  so a win never cuts off a capture.
- **Low-latency mode** (`PlayerMode.lowLatency`, Android's `SoundPool`),
  which is meant for short sounds that must start at once. `SoundPool` never
  says when a sound has ended, so audioplayers takes the player to be still
  playing and ignores the next play. Each play therefore stops the player
  first, and the player keeps its sound loaded when stopped
  (`ReleaseMode.stop`).
- **They leave other audio alone.** On Android they use the media volume,
  as games do (`AndroidUsageType.game`), and do not take the audio focus, so
  the player's music or podcast goes on. On iOS they use the `ambient`
  category, which mixes with other audio and keeps quiet when the Silent
  switch is on. Android has no such switch for media: turning the media
  volume down silences them.

It fails quietly ([ADR 0016](0016-storage-failures-do-not-stop-the-game.md)):
a plugin that throws an `Exception` is reported and nothing is heard. An
`Error` is a bug, so it goes on to the app-wide error reporting.

## Consequences

- Tests replace `SoundEffects` with a fake, so the game runs without a
  device or a speaker. The wrapper is tested with a fake `AudioPlayer`,
  passed in through its constructor. Unlike ADR 0020, this needs no
  test-only package: faking audioplayers' platform side would mean faking
  its file cache and its "prepared" events as well.
- Cost: one more package to keep up to date, with its platform packages and
  `path_provider` (which it uses to copy a sound to a file before playing
  it) in the lock file, and more platform code in every build.
- Cost: that a phone really plays the sounds, at the right volume, is only
  checked by hand. The tests show the app asks for the right file, in the
  right mode, and copes with a player that fails.

## Alternatives considered

- **`just_audio`.** Well made, but built for music and playlists, with
  far more than two short sounds need.
- **`soundpool`.** Wraps exactly Android's `SoundPool`, but far fewer apps
  use it (about 2,000 downloads against audioplayers' 1.7 million), so
  problems are found and fixed more slowly.
- **`flame_audio`.** A thin layer over audioplayers for the Flame engine,
  which this app does not use.
- **Write the platform call ourselves, with a method channel.** No
  dependency, but it is native code for Android and iOS to write, test and
  keep, for something this plugin already does.
- **`SystemSound.play` from Flutter.** No dependency, but it plays only the
  phone's own click and alert, not the app's sounds.
