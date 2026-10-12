#!/usr/bin/env bash
# Build the New engine (ref/galaxypad-engine) as GalaxyPadEngine.framework for iOS
# devices (docs/ENGINE-SWITCH-PLAN.md). The engine's prebuilt Dawn has no Simulator
# package, so Simulator builds of GalaxyPad leave the New engine out.
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
if [[ "${GALAXYPAD_IOS_SDK:-iphonesimulator}" != iphoneos ]]; then
  echo "The New engine builds for iOS devices only (GALAXYPAD_IOS_SDK=iphoneos); skipped."
  exit 0
fi
build="$root/generated/build/ios-device-engine"
python3 "$root/scripts/dependency-lock.py"
# The engine's build downloads Aurora at a pinned commit, and verifies the
# archives Aurora fetches without a hash (native/gx/verify_downloads.cmake).
# Host package lookups stay off so Homebrew's macOS libraries are never linked.
cmake -S "$root/ref/galaxypad-engine" -B "$build" -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$root/scripts/ios-device-toolchain.cmake" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DPETARI_BUILD_GX_PROBE=ON \
  -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON -DCMAKE_DISABLE_FIND_PACKAGE_Freetype=ON \
  -DPETARI_PIPELINE_STAGE_SEEDS="$build/pipeline-seeds-source"
# -k 0: report every compile error in one run.
cmake --build "$build" --target GalaxyPadEngine --parallel "${GALAXYPAD_BUILD_JOBS:-4}" -- -k 0
# Building must not change the pinned engine checkout.
python3 "$root/scripts/dependency-lock.py"
framework="$build/native/app/GalaxyPadEngine.framework"
exported="$(nm -gU "$framework/GalaxyPadEngine" | awk '{print $3}')"
if [[ "$exported" != "_galaxypad_engine_main" ]]; then
  echo "GalaxyPadEngine must export only _galaxypad_engine_main; found:" >&2
  echo "$exported" >&2
  exit 1
fi
echo "Built $framework"
