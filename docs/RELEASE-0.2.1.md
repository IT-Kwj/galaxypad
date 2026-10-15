# GalaxyPad 0.2.1 — a faster, simpler menu

A fix for the three-dot menu in 0.2.0, which could feel slow and was long on a
phone. Builds the same way: rebuild with PadMint and install over your current
GalaxyPad to keep your saves.

The New engine is GalaxyPad's maintained fork of
[MacioGalaxy](https://github.com/classicrob/MacioGalaxy), based on the
[Petari decompilation](https://github.com/SMGCommunity/Petari).
It builds the game code natively for iPhone and iPad, with Metal rendering.

Build on an Apple silicon Mac with [PadMint 0.5.2 or newer](https://github.com/chrissotraidis/padmint/releases/latest).
This release contains the build recipe and checksums; there is no prebuilt IPA.
Supply your own USA RMGE01 revision 0 WBFS image in the app. No game image,
assets, saves or keys are included. Update in place with the same sideloading
tool and Apple ID; do not uninstall first.

## What's fixed

- **The menu responds right away.** The New engine runs the game on the same
  thread iOS uses to animate menus and track taps, so while the game kept running
  the menu waited between frames. The game now pauses while the menu or any
  GalaxyPad sheet is open and hands that time to iOS, then picks up where it was.
  (Audio pauses with it.)
- **A shorter, grouped menu.** Display, Controls and Audio come first; then Game
  Data & Saves and Engine; then Help & Feedback (Touch Control Guide, Report a
  Problem, Share Diagnostic Log, performance logging, About); then Stop Game.
  Controls is split into Touch and Controller. With the New engine, which steers
  the Star Ball and Ray from the stick by itself, the Ball & Ray items and the
  tilt stick are gone.
- The menu no longer rebuilds itself while it is open.

## What was tested

- PadMint's player check passed before tagging on this exact revision and again
  after publication from the public release: PadMint 0.5.2/current main, Apple's
  Python 3.9.6, an empty PadMint folder, and a fresh 0.2.1 build. The resulting
  personal package is 0.2.1 (7217); this package check is not a fresh device playtest.
- The public recipe and checksums passed both publication audits and were
  downloaded again anonymously after publication with matching SHA-256 hashes.

- iPhone 14 (iOS 26.6.2) and iPad Pro 12.9-inch (6th generation, iPadOS 27.0.1):
  0.2.1 (7217), built the way PadMint builds it, installed over 0.2.0; saves
  byte-identical before and after.
- iPhone Simulator: the game pauses while GalaxyPad is not in front and resumes
  after; the overlay UI tests pass on the iPhone Simulator (iOS 27.0), including
  the new menu layout and the no-rebuild-while-open check.
- Engine Mac tests from release preparation. GalaxyPad's full repository suite
  and iOS build passed in [CI on the exact release commit](https://github.com/chrissotraidis/galaxypad/actions/runs/38666602698).
- The publication-day local repository-suite rerun stops at the host-pressure
  probe, as it did during release preparation; this local run is not a pass.

## Remaining checks

- The iPad Simulator UI test reports an overlap between the stick and the hidden
  "1" button in the default layout; this release does not change their positions.
- The menu fix has automated coverage, but its responsiveness by hand has not
  been independently verified. Full-game completion is not yet verified.

## Provenance

- App: `597c382f8d0a22c02065189cbaad80d99627f188` (0.2.1, build 7217), merged through [PR #27](https://github.com/chrissotraidis/galaxypad/pull/27).
- New engine: `chrissotraidis/galaxypad-engine` `2817f5fd4859088cb3e9817f1ebb4c0213f664bd`.
- The Old engine runtime and PadMint recipe are unchanged from 0.2.0. The New engine revision above includes the pause-loop repair.
- [Pinned dependencies](https://github.com/chrissotraidis/galaxypad/blob/v0.2.1/config/dependencies.lock.json) and [credits](https://github.com/chrissotraidis/galaxypad/blob/v0.2.1/CREDITS.md).
