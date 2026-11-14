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

## Uploading the listing

`tool/upload_store_listing.sh` sends the texts, the screenshots and the app
icon to Play Console for every language, with fastlane's
[`supply`](https://docs.fastlane.tools/actions/upload_to_play_store/). It does
not upload an app bundle or release notes. The screenshots stay in
`art/play-store/<language>/`: the script copies them next to the texts in a
temporary folder, which is what `supply` reads.

### Once, by hand

1. Create the app in Play Console and save its listing once (the API cannot
   create an app).
2. Create a service account in Google Cloud and give it access in Play Console
   (Users and permissions, then invite it, with the permission to manage the
   store listing). Download its JSON key. Play can take a few minutes, and
   sometimes longer, to accept a new service account. The steps are in
   [fastlane's guide](https://docs.fastlane.tools/getting-started/android/setup/).
3. Keep the key outside the repository.
4. Install fastlane (`gem install fastlane`, or Homebrew).

### Each time

```sh
# Ask Play to check everything, changing nothing:
PLAY_JSON_KEY=~/keys/play.json tool/upload_store_listing.sh --validate-only

# Upload:
PLAY_JSON_KEY=~/keys/play.json tool/upload_store_listing.sh

# See what would be uploaded, with no key:
tool/upload_store_listing.sh --stage-only /tmp/listing
```

Pictures Play already has are not sent again. The 1024 × 500 feature graphic,
`art/play-store/feature-graphic.png`, is sent with the rest, the same one for every
language. Play wants one before the listing can be published. The graphic is made
by `tool/make_feature_graphic.py`; see [art/README.md](../art/README.md).
