# Files and import UI regression

Uses Xcode's UI testing to exercise the installed GalaxyPad app and Apple's
Files app. Requires Xcode with an iOS Simulator runtime and `xcodegen`.
Use a dedicated empty Simulator, never a personal game/save installation.

1. Build the Simulator app with `bash scripts/build-ios-simulator-app.sh`.
2. Create and boot an isolated Simulator and install
   `generated/build/ios-simulator-app/GalaxyPad.app` with `xcrun simctl install`.
3. Run `bash tests/run-files-ui.sh SIMULATOR_UUID`.

The runner does not install, erase, or uninstall GalaxyPad. For a fresh-install
check, its app container must be empty before the first launch. Separately test
an update over the old version with synthetic documents/save/settings fixtures
and compare their hashes. Never use real saves as fixtures.
