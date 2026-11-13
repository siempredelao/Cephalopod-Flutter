#!/usr/bin/env bash
# Takes the Play Store screenshots on the connected Android emulator or phone,
# once per language, and saves them in art/play-store/<language>/.
#
#   tool/take_store_screenshots.sh            every language
#   tool/take_store_screenshots.sh es fr      only these languages
#
# Use an emulator with a phone-sized screen, and make the pictures again after
# any change to how the screens look. See art/README.md.
set -euo pipefail

cd "$(dirname "$0")/../app"

# One language for each .arb file in app/lib/core/l10n.
all_languages=(en es fr it pt de nl da nb sv pl tr)
languages=("${@:-${all_languages[@]}}")

for language in "${languages[@]}"; do
  echo "== $language"
  flutter drive \
    --driver=test_driver/screenshots.dart \
    --target=integration_test/store_screenshots_test.dart \
    --dart-define=LANGUAGE="$language"
done
