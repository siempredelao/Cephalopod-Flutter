# Art

The app icon and store graphics. The SVG files are the sources; the PNG files are
exports, ready to upload or to feed to a generator.

## App icon

A coral die showing 5, with four arrows sliding into it: the moment a placed die
captures its neighbours and takes their sum. Colours match the app's teal seed
(`#00897B`) and the two player colours.

| File | What it is |
| --- | --- |
| `app-icon.svg` | Full icon on the 108 × 108 adaptive-icon grid (background + foreground). |
| `app-icon-square.svg` | The same icon cropped to the visible 72 × 72 area. Source for every square export. |
| `app-icon-background.svg` | Adaptive-icon background layer: teal glow and the board squares. |
| `app-icon-foreground.svg` | Adaptive-icon foreground layer: die, highlight and arrows, inside the 66-unit safe zone. |
| `app-icon-monochrome.svg` | Single-colour glyph for Android 13+ themed icons. |
| `app-icon-1024.png` | 1024 × 1024 master, no alpha channel (iOS App Store, web, launcher-icon generators). |
| `app-icon-{background,foreground,monochrome}-1024.png` | The adaptive layers at 1024 × 1024 on the full 108 grid. |
| `play-store/icon.png` | Google Play listing icon. |

### Google Play

Upload `play-store/icon.png` as the **App icon** of the main store listing in Play
Console. It already meets the spec: 512 × 512, 32-bit PNG,
sRGB, full square with no rounded corners or drop shadow (Play adds both).

### Launcher icons

The Android launcher icons in `app/android/app/src/main/res/` are made from
these files by [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons),
with the settings in `app/flutter_launcher_icons.yaml`: the legacy square icons
for every density, the adaptive icon (background and foreground) and the
monochrome layer Android 13 uses for themed icons. The generated files are
committed, so building the app needs nothing from the tool.

To make them again, after changing the art or the settings, from `app/`:

```sh
dart pub global activate flutter_launcher_icons
dart pub global run flutter_launcher_icons
```

The tool is run on its own and is not a dependency of the app: its newest
version needs `cli_util` 0.4, and the engine's coverage tool needs 0.6, so the
two cannot be solved together. Its default inset for the adaptive layers is
turned off (`adaptive_icon_foreground_inset: 0`), because the art's layers
already keep their content inside the adaptive icon's safe zone.

iOS icons are not made yet, as the first release is on Google Play. Set
`ios: true` (and `remove_alpha_ios: true`, so the iOS master has no alpha
channel) when an iOS release is planned.

### Re-exporting

Edit the SVG, then render it at the size you need with any SVG renderer (a
browser, Inkscape, `rsvg-convert`). Square exports come from `app-icon-square.svg`;
adaptive layers come from their own SVG at the full 108 grid. Keep the Play icon
opaque and remove the alpha channel from the iOS master.

### Palette

| Role | Colour |
| --- | --- |
| Background | `#03201C` → `#0A4A42` |
| Board squares | `#0C443C` |
| Highlight and arrows | `#5EEAD4` |
| Die face / edge / pips | `#FF7A5C` / `#C24A30` / `#3A1208` |

## Social preview

`social-preview.png` (1280 × 640) is the repository's social preview and the banner
at the top of the main README. To use it as the preview, upload it under the
repository's **Settings → General → Social preview**.

## Play Store screenshots

`play-store/<language>/` holds the phone screenshots for each language of the
listing, numbered in the order the store should show them:

| File | The screen |
| --- | --- |
| `1-how-to-play.png` | How to play, as a first launch shows it |
| `2-home.png` | Home, with the demo board |
| `3-new-game.png` | The new-game dialog, with the computer chosen |
| `4-game.png` | A game with a capture to choose, three dice selected |
| `5-game-dark.png` | The same game in the dark theme |

A test makes them: it runs the real app on an emulator or phone, tells the app
to use each language, plays the same moves and saves what the screen shows, so
the text is drawn in the real font. To make them again, after a change to how
the screens look, connect an emulator with a phone-sized screen and run, from
the repository root:

```sh
tool/take_store_screenshots.sh        # every language
tool/take_store_screenshots.sh es fr  # only these
```

The test is `app/integration_test/store_screenshots_test.dart`, and
`app/test_driver/screenshots.dart` saves the images. Each language takes about
a minute once the app is built.
