# Engine switch plan

**Goal:** GalaxyPad gets a setting that chooses its game engine: **Original**
(the engine it ships today) or **New** (the game compiled natively from the
Petari decompilation). The New engine brings everything the Galaxy Native test
app has. This is the working plan for that change, done in milestones over
several sessions. Read it with the [native engine plan](NATIVE-ENGINE-PLAN.md),
which holds the research and the device measurements behind it.

**Status, 12 October 2026:** plan only. Nothing in the GalaxyPad app has changed.
The New engine runs today as a separate test app (`org.galaxypad.native-probe`)
on the iPhone 14 and iPad Pro; its code is 14 commits on a local branch,
`galaxypad/ios-native`, of a MacioGalaxy checkout.

## What the player gets

- **Settings → Engine: Original / New.** The choice applies the next time the
  app opens, because each engine runs the whole app while it plays. The New
  engine's Home menu has the same switch.
- **Original** stays exactly as it is, and stays the default until the owner
  has played the New engine and approves the change.
- **New** is everything from Galaxy Native: 60 FPS on the iPhone 14, Smooth
  Motion at 120 FPS on ProMotion iPads, lower input latency, the touch controls
  with an exact Star Pointer and two-finger camera, the native Home menu with Mods,
  and a one-time shader preparation screen.
- GalaxyPad's import flow, icon, About and report screens stay GalaxyPad's.

## How it fits together

| Part | Original | New |
| --- | --- | --- |
| Engine source | `ref/ModernGekko` (and its pinned compiler forks) | A fork of [MacioGalaxy](https://github.com/classicrob/MacioGalaxy) with our iOS commits, pinned the same way |
| Game code | PowerPC code translated ahead of time | Petari decompilation compiled natively (CC0) |
| Renderer | Dolphin-derived | Aurora (MIT) on Metal through Dawn |
| Disc data | GalaxyPad's import extracts the game partition into `files/` and `sys/` | The same extracted folder; the New engine reads that layout, so no second copy |
| Saves | Wii-format NAND | Native save format; converted from the Original save |
| Settings | `NSUserDefaults` (`GalaxyPadSettings`) | Its own files (`settings.txt`, `mods.txt`, `camera.txt`) in its own folder |

One app, one engine per launch. At start-up GalaxyPad reads the Engine setting
and hands the app to the chosen engine.

## Rules for this work

- One branch and pull request per milestone step, merged only with the required
  `source-checks` and `ios-build` statuses passing.
- Engine changes go to the engine fork as reviewable commits; GalaxyPad pins them
  by full commit ID ([CONTRIBUTING](../CONTRIBUTING.md)).
- Before any install over the real GalaxyPad on a device: back up the saves and
  settings, read the backup back, install over the existing app with the same
  signing identity, then compare the save hashes.
- Publishing (the public fork, a release, PadMint) needs the owner's approval.
- Record each result, with device, OS, build and scenario, in the progress log at
  the end of this file. A build or Simulator run is not gameplay acceptance.

## Milestone 1: the switch in a private build

**Result:** a GalaxyPad build on the owner's iPhone and iPad where the Engine
setting switches between Original and New, and both play.

1. **Engine fork.** Create the fork (owner approval), push the 14 commits, and pin
   it in GalaxyPad by full commit ID with the lock, `DEPENDENCIES.md` and
   `THIRD-PARTY-NOTICES.md` updated. CI has to fetch it before anything can
   merge to `main`. It contains source only, no game data.
2. **Both engines in one app.** Link the New engine into the iOS app target next
   to the Original. Find and fix symbol clashes (SDL, Dear ImGui, Wii SDK names)
   first; this is the main technical risk. CI `ios-build` must pass.
3. **Launch choice.** `main.mm` reads the `GalaxyPadEngine` setting. New starts
   the native app with the disc path set to GalaxyPad's extracted folder and its
   user folder inside GalaxyPad's container.
4. **Settings.** An Engine control in GalaxyPad's settings, and a matching entry
   in the New engine's Home menu, each saying the change applies on reopening.
5. **Disc.** Confirm the New engine reads GalaxyPad's extracted folder (the import
   already checks the disc and its `main.dol` hash).
6. **Save copy.** On the first New launch, back up the Original save, convert it
   with `wii_save_to_native.py`'s logic (ported to the app), check it with the
   native save checker, and keep the Original save untouched.
7. **First launch.** The New engine's shader preparation screen runs once.
8. **Devices.** Install over GalaxyPad on the iPhone 14 and iPad Pro with the
   backup rules above.

**Gate:** on both devices the switch works in both directions; the New engine
passes the galaxy route by touch; the Original engine passes its existing checks;
save hashes match before and after; the owner has tried both.

## Milestone 2: ready to release

- Saves both ways: converting the New engine's save back when switching to
  Original, with backups, so progress follows the player.
- App size, first-launch time and storage measured on both devices.
- GalaxyPad's look for the New engine's screens and controls
  ([touch design](GALAXY-TOUCH-DESIGN.md)); game controllers verified.
- Full stage run on both devices, the dome tour, and an owner playtest for feel,
  audio and rides (Star Ball, Ray, Pull Stars).
- Release evidence as `AGENTS.md` requires, PadMint's recipe and
  `scripts/player-check.sh`, then a release with owner approval.

**Gate:** release evidence complete and the owner approves the release.

## Later

New as the default engine; retire the separate test app; particle blending for
Smooth Motion; the Mac app.

## Decisions for the owner

| Decision | Recommendation |
| --- | --- |
| Create the public engine fork at the start of Milestone 1 | Yes. CI must fetch it to merge, and PadMint needs it to build for players. It holds only CC0 and MIT-licensed source. |
| Default engine | Original until the owner's playtest of New. |
| Saves in Milestone 1 | One-way copy into New; the Original save is never changed. Both ways in Milestone 2. |
| Installing Milestone 1 over the real GalaxyPad | Yes, after a verified backup. |

## Progress log

- **12 October 2026:** plan written and merged. Evidence for the New engine is in
  the [native engine plan](NATIVE-ENGINE-PLAN.md). Next: Milestone 1, step 1.
