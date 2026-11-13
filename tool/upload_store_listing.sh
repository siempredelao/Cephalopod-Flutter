#!/usr/bin/env bash
# Uploads the Play Store listing to Play Console: the texts in
# fastlane/metadata/android, the screenshots in art/play-store, and the app
# icon (art/play-store/icon.png) and feature graphic
# (art/play-store/feature-graphic.png, if it exists) for every language.
#
#   PLAY_JSON_KEY=~/keys/play.json tool/upload_store_listing.sh
#   PLAY_JSON_KEY=~/keys/play.json tool/upload_store_listing.sh --validate-only
#   tool/upload_store_listing.sh --stage-only /tmp/listing
#
# --validate-only  asks Play to check everything and changes nothing.
# --stage-only DIR builds the folder that would be uploaded in DIR, and stops.
#                  It needs no key, so you can look at what would go up.
#
# PLAY_JSON_KEY is the service account's key file; keep it outside the
# repository. It uploads with fastlane's `supply` (https://docs.fastlane.tools),
# which must be installed. See fastlane/README.md.
set -euo pipefail

cd "$(dirname "$0")/.."

package_name=gc.david.cephalopod
validate_only=false
stage_only=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --validate-only) validate_only=true ;;
    --stage-only)
      stage_only="${2:?--stage-only needs a folder}"
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
  shift
done

# The app's language folders in art/play-store, and the locale of each in
# Play Console (the folders in fastlane/metadata/android).
declare -A locale_of=(
  [en]=en-US [es]=es-ES [fr]=fr-FR [it]=it-IT [pt]=pt-BR [de]=de-DE
  [nl]=nl-NL [da]=da-DK [nb]=no-NO [sv]=sv-SE [pl]=pl-PL [tr]=tr-TR
)

# The texts, with each language's pictures added: supply wants them all under
# one folder, and the pictures are not copied into the repository twice.
stage_listing() {
  local stage="$1"
  mkdir -p "$stage"
  cp -R fastlane/metadata/android/. "$stage"/
  for language in "${!locale_of[@]}"; do
    local images="$stage/${locale_of[$language]}/images"
    mkdir -p "$images/phoneScreenshots"
    cp art/play-store/"$language"/*.png "$images/phoneScreenshots/"
    cp art/play-store/icon.png "$images/icon.png"
    if [[ -f art/play-store/feature-graphic.png ]]; then
      cp art/play-store/feature-graphic.png "$images/featureGraphic.png"
    fi
  done
}

if [[ -n "$stage_only" ]]; then
  stage_listing "$stage_only"
  echo "Staged in $stage_only"
  exit 0
fi

: "${PLAY_JSON_KEY:?Set PLAY_JSON_KEY to the service account key file.}"
command -v fastlane >/dev/null || {
  echo 'fastlane is not installed: see https://docs.fastlane.tools' >&2
  exit 1
}

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
stage_listing "$stage"

# No app bundle and no release notes: this only changes the listing. With
# sync_image_upload, pictures Play already has are not sent again.
fastlane supply \
  --package_name "$package_name" \
  --json_key "$PLAY_JSON_KEY" \
  --metadata_path "$stage" \
  --skip_upload_apk \
  --skip_upload_aab \
  --skip_upload_changelogs \
  --sync_image_upload \
  --validate_only "$validate_only"
