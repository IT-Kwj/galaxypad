#!/usr/bin/env bash
# PadMint's package step (padmint.json): the device app from
# build-ios-simulator-app.sh (GALAXYPAD_IOS_SDK=iphoneos) as an unsigned IPA for
# AltStore, SideStore or Sideloadly. It has the New engine and no Old engine
# module, game image, extracted files or saves. Never modifies the build.
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
if (( $# != 1 )); then
  echo "usage: $0 OUTPUT.ipa" >&2
  exit 2
fi
output="$1"
app="$root/generated/build/ios-device-app/GalaxyPad.app"
fail() { echo "package: $*" >&2; exit 1; }
[[ -f "$app/GalaxyPad" ]] || fail "no device app at $app; run build-ios-simulator-app.sh with GALAXYPAD_IOS_SDK=iphoneos"
[[ "$(xcrun lipo -archs "$app/GalaxyPad")" == arm64 ]] || fail "the app is not arm64"
xcrun vtool -show-build "$app/GalaxyPad" | grep -Eq '^[[:space:]]*platform IOS$' || fail "the app is not an iPhone/iPad build"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")" == org.galaxypad.GalaxyPad ]] || fail "unexpected bundle identifier"
[[ -s "$app/Assets.car" ]] || fail "missing compiled app icons"
[[ -f "$app/Frameworks/GalaxyPadEngine.framework/GalaxyPadEngine" ]] || fail "missing the New engine framework"
[[ -s "$app/pipeline-seeds.xz" ]] || fail "missing the New engine's shader seed pack"
[[ ! -e "$app/Frameworks/gRMGE01_recomp.dylib" ]] || fail "the app holds an Old engine module; PadMint builds leave it out"
private="$(find "$app" \( -iname '*.wbfs' -o -iname '*.iso' -o -iname '*.dol' -o -iname '*.rso' -o -iname '*.rel' \
  -o -iname 'GameData.bin' -o -iname '*.mobileprovision' -o -iname '*.p12' \) -print -quit)"
[[ -z "$private" ]] || fail "private file in the app: $private"
stage="$(mktemp -d)"
trap 'rm -r "$stage"' EXIT
mkdir "$stage/Payload"
ditto "$app" "$stage/Payload/GalaxyPad.app"
mkdir -p "$(dirname -- "$output")"
[[ ! -e "$output" ]] || fail "$output already exists"
(cd "$stage" && /usr/bin/zip -qry -X "$stage/GalaxyPad.ipa" Payload)
mv "$stage/GalaxyPad.ipa" "$output"
shasum -a 256 "$app/GalaxyPad" "$output"
echo "Unsigned IPA: $output"
