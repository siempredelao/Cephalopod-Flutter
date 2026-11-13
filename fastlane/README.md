# Store listing

The texts of the Google Play listing, one folder per language, in the layout
that [fastlane `supply`](https://docs.fastlane.tools/actions/upload_to_play_store/)
reads, so a later script can upload them:

```text
fastlane/metadata/android/<locale>/
  title.txt              up to 30 characters
  short_description.txt  up to 80 characters
  full_description.txt   up to 4000 characters
```

The folder names are the locale codes Play Console uses, which differ from the
app's own language codes:

| App (`app/lib/core/l10n`, `art/play-store`) | Play listing |
| --- | --- |
| `en` | `en-US` |
| `es` | `es-ES` |
| `fr` | `fr-FR` |
| `it` | `it-IT` |
| `pt` | `pt-BR` |
| `de` | `de-DE` |
| `nl` | `nl-NL` |
| `da` | `da-DK` |
| `nb` | `no-NO` |
| `sv` | `sv-SE` |
| `pl` | `pl-PL` |
| `tr` | `tr-TR` |

The screenshots are in `art/play-store/<language>/` (see `art/README.md`).

## Notes

- Every full description says the game was invented by Mark Steere and that the
  app keeps its name and rules unchanged, as he asks, with a link to his site.
- The texts say "no ads, no account and no internet needed". If that stops
  being true, change them, and the Data safety form in Play Console too.
- Claude drafted every language except English. Native readers should look at
  them before the first release, and mistakes are fixed from user reports, as
  with the app's own translations.
- The English text is the source: when it changes, change the others with it.
