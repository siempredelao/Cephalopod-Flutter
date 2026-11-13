#!/usr/bin/env bash
# Takes the Play Store screenshots on the connected Android emulator or phone,
# once per language, and saves them in art/play-store/<language>/.
#
#   tool/take_store_screenshots.sh            every language
#   tool/take_store_screenshots.sh es fr      only these languages
#
# Make the pictures again after any change to how the screens look. See
# art/README.md.
#
# Google Play rejects a screenshot whose long side is more than twice its short
# side, and many phones are taller than that (the Pixel 4a is 1080 x 2340). So
# the screen is set to 1080 x 1920, the size Play recommends, for the run, and
# set back to its own size at the end.
set -euo pipefail

cd "$(dirname "$0")/../app"

# One language for each .arb file in app/lib/core/l10n.
all_languages=(en es fr it pt de nl da nb sv pl tr)
languages=("${@:-${all_languages[@]}}")

adb shell wm size 1080x1920
trap 'adb shell wm size reset' EXIT

for language in "${languages[@]}"; do
  echo "== $language"
  flutter drive \
    --driver=test_driver/screenshots.dart \
    --target=integration_test/store_screenshots_test.dart \
    --dart-define=LANGUAGE="$language"
done
