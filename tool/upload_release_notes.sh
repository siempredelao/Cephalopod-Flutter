#!/usr/bin/env bash
# Uploads the release notes of one version to Play Console, for every language.
# They are in fastlane/metadata/android/<locale>/changelogs/<versionCode>.txt.
#
#   PLAY_JSON_KEY=~/keys/play.json tool/upload_release_notes.sh
#   PLAY_JSON_KEY=~/keys/play.json tool/upload_release_notes.sh --track production
#   PLAY_JSON_KEY=~/keys/play.json tool/upload_release_notes.sh --validate-only
#   tool/upload_release_notes.sh --stage-only /tmp/notes
#
# --track TRACK         the track that holds the version (default: internal).
# --version-code N      the version to write notes for (default: the number
#                       after the "+" in the version of app/pubspec.yaml).
# --validate-only       asks Play to check everything and changes nothing.
# --stage-only DIR      builds the folder that would be uploaded in DIR, and
#                       stops. It needs no key.
#
# Play keeps release notes inside a release, so the version must already be on
# the track: upload its app bundle first. This script does not upload one.
# PLAY_JSON_KEY is the service account's key file; keep it outside the
# repository. It uploads with fastlane's `supply` (https://docs.fastlane.tools),
# which must be installed. See fastlane/README.md.
set -euo pipefail

cd "$(dirname "$0")/.."

package_name=gc.david.cephalopod
notes_folder=fastlane/metadata/android
max_characters=500 # Play's limit for the notes of one language.
track=internal
version_code=''
validate_only=false
stage_only=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --track)
      track="${2:?--track needs a track name}"
      shift
      ;;
    --version-code)
      version_code="${2:?--version-code needs a number}"
      shift
      ;;
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

# The version code is the number after the "+" in `version: 1.0.0+1`.
if [[ -z "$version_code" ]]; then
  version_code=$(sed -n 's/^version: .*+\([0-9][0-9]*\)$/\1/p' app/pubspec.yaml)
  : "${version_code:?Could not read the version code from app/pubspec.yaml.}"
fi

# Stops if a language has no notes for this version, or if they are too long.
check_notes() {
  local notes="$1"
  [[ -f "$notes" ]] || {
    echo "Missing release notes: $notes" >&2
    return 1
  }
  # `wc -m` counts the final line break too.
  local characters=$(($(LC_ALL=C.UTF-8 wc -m <"$notes") - 1))
  if ((characters > max_characters)); then
    echo "Too long ($characters of $max_characters characters): $notes" >&2
    return 1
  fi
}

# Only the notes of this version, so nothing else of the listing is touched.
stage_notes() {
  local stage="$1"
  mkdir -p "$stage"
  local language_folder
  for language_folder in "$notes_folder"/*/; do
    local locale
    locale=$(basename "$language_folder")
    local notes="${language_folder%/}/changelogs/$version_code.txt"
    check_notes "$notes"
    mkdir -p "$stage/$locale/changelogs"
    cp "$notes" "$stage/$locale/changelogs/"
  done
}

if [[ -n "$stage_only" ]]; then
  stage_notes "$stage_only"
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
stage_notes "$stage"

# No app bundle: with --version_code, supply finds that version's release on
# the track and changes only its notes. It stops with an error if there is none.
fastlane supply \
  --package_name "$package_name" \
  --json_key "$PLAY_JSON_KEY" \
  --metadata_path "$stage" \
  --track "$track" \
  --version_code "$version_code" \
  --skip_upload_apk \
  --skip_upload_aab \
  --skip_upload_metadata \
  --skip_upload_images \
  --skip_upload_screenshots \
  --validate_only "$validate_only"
