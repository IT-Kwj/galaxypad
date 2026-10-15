#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$root/generated/tests"
xcrun clang++ -std=c++20 -fobjc-arc -fblocks -fsanitize=address,undefined \
  -framework Foundation "$root/tests/test-documents.mm" \
  "$root/apple/ios/GalaxyPadDocuments.mm" -o "$root/generated/tests/documents"
"$root/generated/tests/documents"
