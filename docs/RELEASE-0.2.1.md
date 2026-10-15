# GalaxyPad 0.2.1 — a faster, simpler menu

A fix for the three-dot menu in 0.2.0, which could feel slow and was long on a
phone. Builds the same way: rebuild with PadMint and install over your current
GalaxyPad to keep your saves.

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

- iPhone 14 (iOS 26.6.2) and iPad Pro 12.9-inch (6th generation, iPadOS 27.0.1):
  0.2.1 (7217), built the way PadMint builds it, installed over 0.2.0; saves
  byte-identical before and after.
- iPhone Simulator: the game pauses while GalaxyPad is not in front and resumes
  after; the overlay UI tests pass on the iPhone Simulator (iOS 27.0), including
  the new menu layout and the no-rebuild-while-open check.
- Engine Mac tests; GalaxyPad's repository checks.

## Provenance

- New engine: `chrissotraidis/galaxypad-engine` `2817f5fd4859088cb3e9817f1ebb4c0213f664bd`.
- Runtime and recipe unchanged from 0.2.0 (config/dependencies.lock.json, `padmint.json`).
