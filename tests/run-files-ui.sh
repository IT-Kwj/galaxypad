#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
[[ $# == 1 ]] || { echo "usage: $0 ISOLATED_SIMULATOR_UUID" >&2; exit 2; }
# Only operate on the already booted, explicitly selected test device.
xcrun simctl list devices booted --json | python3 -c '
import json,sys
assert any(d["udid"] == sys.argv[1] and d["state"] == "Booted"
           for group in json.load(sys.stdin)["devices"].values() for d in group), "Boot the isolated test Simulator first"
' "$1"
mkdir -p "$root/generated/tests"
run=$(mktemp -d "$root/generated/tests/files-ui.XXXXXX")
cp "$root/tests/files-ui/"{project.yml,FilesUITests.swift} "$run/"
xcodegen generate --spec "$run/project.yml" --project "$run"
xcodebuild test -project "$run/GalaxyPadFilesTests.xcodeproj" \
  -scheme GalaxyPadFilesTests -parallel-testing-enabled NO -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath "$run/build" -resultBundlePath "$run/results.xcresult"
