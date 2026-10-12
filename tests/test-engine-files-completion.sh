#!/usr/bin/env bash
# Private evidence (scripts/check-private-evidence.sh): New-engine file completion
# against the real image. Needs the Simulator core (scripts/build-ios-simulator-core.sh),
# a booted Simulator, the image and a full extracted reference tree.
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
image="${GALAXYPAD_PRIVATE_IMAGE:-$root/generated/private-evidence/RMGE01.wbfs}"
reference="${GALAXYPAD_PRIVATE_EXTRACTED:-$root/generated/extracted/run1}"
build="$root/generated/build/ios-simulator-core"
core="$build/vendor/dolphin/Source/Core"
# Provisioned by scripts/provision-ios-simulator-core.sh, as the Simulator app links it.
library="$root/generated/ios/iphonesimulator/libs/libGalaxyPadCore.a"
# The real disc identity, generated from config/galaxypad-disc.json by the app configure.
identity="$root/generated/build/ios-device-app"
for input in "$image" "$reference/sys/main.dol" "$library" "$identity/GalaxyPadDiscIdentity.h"; do
  [[ -e "$input" ]] || { echo "Missing private evidence input: $input" >&2; exit 1; }
done
device="$(xcrun simctl list devices booted | sed -nE 's/.*\(([0-9A-F-]{36})\) \(Booted\).*/\1/p' | head -1)"
[[ -n "$device" ]] || { echo "Boot a Simulator first." >&2; exit 1; }
mkdir -p "$root/generated/tests"
binary="$root/generated/tests/engine-files-completion"
xcrun --sdk iphonesimulator clang++ -target arm64-apple-ios16.0-simulator -std=c++23 -O1 \
  -fobjc-arc -fblocks -Wall -Wextra -Werror -Wno-unused-parameter \
  -I "$root/ref/ModernGekko/vendor/dolphin/Source/Core" \
  -I "$root/ref/ModernGekko/vendor/dolphin/Externals/fmt/fmt/include" \
  -I "$core" -I "$root/apple/ios" -I "$identity" \
  "$root/tests/test-engine-files-completion.mm" "$root/apple/ios/GalaxyPadDiscExtractor.mm" \
  "$library" -lz -lbz2 -liconv -lresolv -lcompression \
  $(printf -- '-framework %s ' UIKit Foundation Metal MetalKit GameController CoreGraphics \
    QuartzCore CoreText Security AudioToolbox SystemConfiguration CoreMedia CoreVideo \
    CoreMotion CoreHaptics UniformTypeIdentifiers AVFAudio) \
  -o "$binary"
# The test writes a 3.2 GB copy of private game data; removed afterwards.
scratch_root="$(mktemp -d "${TMPDIR:-/tmp}/galaxypad-engine-files.XXXXXX")"
trap 'rm -r "$scratch_root"' EXIT
xcrun simctl spawn "$device" "$binary" "$image" "$reference" "$scratch_root/work"
