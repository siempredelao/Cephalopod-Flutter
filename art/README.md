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

Once the platform folders exist, [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)
can generate every Android, iOS and web size from these files. Add to `app/pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  image_path: ../art/app-icon-1024.png
  android: true
  ios: true
  remove_alpha_ios: true
  adaptive_icon_background: ../art/app-icon-background-1024.png
  adaptive_icon_foreground: ../art/app-icon-foreground-1024.png
  adaptive_icon_monochrome: ../art/app-icon-monochrome-1024.png
  web:
    generate: true
    image_path: ../art/app-icon-1024.png
    background_color: "#03201C"
    theme_color: "#00897B"
```

Then run `dart run flutter_launcher_icons` from `app/`.

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
