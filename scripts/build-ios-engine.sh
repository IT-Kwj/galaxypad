#!/usr/bin/env bash
# Build the New engine (ref/galaxypad-engine) as GalaxyPadEngine.framework
# (docs/ENGINE-SWITCH-PLAN.md). Devices use Dawn's prebuilt iOS package; the
# Simulator builds Dawn from its pinned source, which takes much longer.
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
case "${GALAXYPAD_IOS_SDK:-iphonesimulator}" in
  iphonesimulator) lane=ios-simulator ;;
  iphoneos) lane=ios-device ;;
  *) echo "GALAXYPAD_IOS_SDK must be iphonesimulator or iphoneos" >&2; exit 2 ;;
esac
build="$root/generated/build/$lane-engine"
python3 "$root/scripts/dependency-lock.py"
# The engine's build downloads Aurora at a pinned commit, and verifies the
# archives Aurora fetches without a hash (native/gx/verify_downloads.cmake).
# Host package lookups stay off so Homebrew's macOS libraries are never linked.
cmake -S "$root/ref/galaxypad-engine" -B "$build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$root/scripts/$lane-toolchain.cmake" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DPETARI_BUILD_GX_PROBE=ON \
  -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON -DCMAKE_DISABLE_FIND_PACKAGE_Freetype=ON \
  -DPETARI_PIPELINE_STAGE_SEEDS="$build/pipeline-seeds-source"
# -k 0: report every compile error in one run.
cmake --build "$build" --target GalaxyPadEngine --parallel "${GALAXYPAD_BUILD_JOBS:-4}" -- -k 0
# Building must not change the pinned engine checkout.
python3 "$root/scripts/dependency-lock.py"
framework="$build/native/app/GalaxyPadEngine.framework"
# The entry point and the functions GalaxyPad's controls and menu call
# (apple/ios/GalaxyPadNewEngineHost.mm); nothing else.
exported="$(nm -gU "$framework/GalaxyPadEngine" | awk '{print $3}' | sort | tr '\n' ' ')"
expected="_galaxypad_engine_image _galaxypad_engine_input _galaxypad_engine_main _galaxypad_engine_pause _galaxypad_engine_presented_frames _galaxypad_engine_quit _galaxypad_engine_set_volume _galaxypad_engine_smooth_motion _galaxypad_engine_started _galaxypad_engine_switch_to_original _galaxypad_engine_widescreen "
if [[ "$exported" != "$expected" ]]; then
  echo "GalaxyPadEngine must export only: $expected; found:" >&2
  echo "$exported" >&2
  exit 1
fi
echo "Built $framework"
