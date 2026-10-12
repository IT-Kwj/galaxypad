# Engine switch plan

**Goal:** GalaxyPad gets a setting that chooses its game engine: **Original**
(the engine it ships today) or **New** (the game compiled natively from the
Petari decompilation). The New engine brings everything the Galaxy Native test
app has. This is the working plan for that change, done in milestones over
several sessions. Read it with the [native engine plan](NATIVE-ENGINE-PLAN.md),
which holds the research and the device measurements behind it.

**Status, 12 October 2026:** Milestone 1, step 2 built: device builds of GalaxyPad
embed the New engine, with the Engine setting and launch choice in place (steps 3
and 4 in code). Not yet run on a device. The engine source is
[chrissotraidis/galaxypad-engine](https://github.com/chrissotraidis/galaxypad-engine),
pinned at `ref/galaxypad-engine`. It also runs as a separate test app
(`org.galaxypad.native-probe`) on the iPhone 14 and iPad Pro.

## What the player gets

- **Settings → Engine: Original / New.** The choice applies the next time the
  app opens, because each engine runs the whole app while it plays. The New
  engine's Home menu has the same switch.
- **Original** stays exactly as it is, and stays the default until the owner
  has played the New engine and approves the change.
- **New** is the Galaxy Native engine: 60 FPS on the iPhone 14, Smooth Motion at
  120 FPS on ProMotion iPads, lower input latency, and a one-time shader
  preparation screen. It looks and plays like GalaxyPad: GalaxyPad's own touch
  controls (with their layout settings, gyro cursor and Touch Control Guide) and
  three-dot menu sit over the game, and the engine's own touch controls stay off.
  The menu lists what works with the New engine: Engine, Controls, Report a
  Problem and About.
- GalaxyPad's import flow, icon, About and report screens stay GalaxyPad's.

## How it fits together

| Part | Original | New |
| --- | --- | --- |
| Engine source | `ref/ModernGekko` (and its pinned compiler forks) | `ref/galaxypad-engine`: a standalone copy of [MacioGalaxy](https://github.com/classicrob/MacioGalaxy) with our iOS commits, pinned the same way |
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
- Engine changes go to `galaxypad-engine` as reviewable commits; GalaxyPad pins them
  by full commit ID ([CONTRIBUTING](../CONTRIBUTING.md)).
- Before any install over the real GalaxyPad on a device: back up the saves and
  settings, read the backup back, install over the existing app with the same
  signing identity, then compare the save hashes.
- A release (PadMint, a new public download) needs the owner's approval.
- Record each result, with device, OS, build and scenario, in the progress log at
  the end of this file. A build or Simulator run is not gameplay acceptance.

## Milestone 1: the switch in a private build

**Result:** a GalaxyPad build on the owner's iPhone and iPad where the Engine
setting switches between Original and New, and both play.

1. **Engine repository (done).** [chrissotraidis/galaxypad-engine](https://github.com/chrissotraidis/galaxypad-engine)
   is a standalone public copy of MacioGalaxy with our commits, not a GitHub fork;
   nothing is sent to MacioGalaxy. GalaxyPad pins it at `ref/galaxypad-engine`
   with the lock, bootstrap, lock check and credits updated. Source only, no game
   data.
2. **Both engines in one app.** Link the New engine into the iOS app target next
   to the Original. Find and fix symbol clashes (SDL, Dear ImGui, Wii SDK names)
   first; this is the main technical risk. Check that every download the engine's
   build makes (Aurora and what Aurora fetches) is pinned to a full commit or hash.
   CI `ios-build` must pass.
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
  Original, with backups, so progress follows the player. (Built 12 October.)
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

Approved by the owner on 12 October 2026 ("proceed with this plan"):

| Decision | Choice |
| --- | --- |
| Engine source | A standalone public repository, `chrissotraidis/galaxypad-engine`, not a GitHub fork. GalaxyPad uses MacioGalaxy's work and credits it; it does not contribute changes back. |
| Default engine | Original until the owner's playtest of New. |
| Saves in Milestone 1 | One-way copy into New; the Original save is never changed. Both ways in Milestone 2 (now built: see the progress log). |
| Testing (12 October) | iOS Simulator (iPad and iPhone) in place of the owner's devices. |
| Installing Milestone 1 over the real GalaxyPad | Yes, after a verified backup. |

## Progress log

- **12 October 2026:** plan written and merged. Evidence for the New engine is in
  the [native engine plan](NATIVE-ENGINE-PLAN.md). Next: Milestone 1, step 1.
- **12 October 2026:** step 1 done. Created
  `chrissotraidis/galaxypad-engine` (`main` at
  `5a14bfc1fc08c44ca32bf440aae5137bfff42291`: MacioGalaxy
  `4bbf2af23d694a835652f7ac218034cb3cebade4` plus 15 GalaxyPad commits, the last a
  README header naming the source and credits). Pinned at `ref/galaxypad-engine`;
  `bootstrap-dependencies.sh` checks it out and `dependency-lock.py` verifies it.
  Next: step 2, both engines in one app.
- **12 October 2026:** step 2, both engines in one app (PR "Build the New engine
  into GalaxyPad"). The engine (`galaxypad-engine` `e018bebb`) builds
  `GalaxyPadEngine.framework`: one exported symbol, `galaxypad_engine_main`
  (later also the four functions GalaxyPad's controls call),
  which starts the game through `SDL_RunApp`. GalaxyPad's executable defines 15 SDL
  Objective-C classes of its own (the Original engine's SDL), and Objective-C class
  names are process-wide, so the engine's build renames all 40 classes SDL
  implements with a `GPE_` prefix; the app and framework now define no class in
  common (checked with `nm`). SDL, abseil and the prebuilt Dawn package, which
  Aurora fetches without a hash, are checked against recorded SHA-256 values.
  `scripts/build-ios-engine.sh` builds it (device only: the prebuilt Dawn has no
  Simulator package); a clean build took 195 s on an M3 Max (28 CPU minutes). The
  device app embeds the framework in `Frameworks/` and the 400 MB of shader
  manifests in `pipeline-seeds/` (app 459 MB; size is a Milestone 2 item), and
  loads it only from `@executable_path/Frameworks`.
  Launch choice (step 3): `main()` hands the process to the engine when the setting
  is New and an imported game is installed, with `--disc GameData/RMGE01` and
  `--user GalaxyPad/NewEngine`; otherwise GalaxyPad starts as before. Setting
  (step 4): "Engine (Next Launch)" in GalaxyPad's menu, and "Original engine..." in
  the engine's Home menu (with confirmation; it saves the setting and closes the
  game like Quit). Local checks: device build of core, engine and app passes; the
  repository suite passes except the host-pressure probe, which cannot read host
  counters in this session and runs in CI.
  Found on the way: this Mac's Homebrew minizip-ng was picked up by the core's
  `USE_SYSTEM_LIBS=AUTO` (a local rebuild used an empty pkg-config path), and
  Homebrew libpng by the engine's pkg-config lookup (the build script turns it off).
  The private build artifacts for the installed build 7202 (its game module) are
  no longer on this Mac, so Milestone 1 builds use a freshly generated
  Original-engine module. 7202's module experiments (loop promotion and a faster
  chunk lookup) measured no frame-rate change ([September 26
  handoff](IPHONE-PERFORMANCE-2026-09-26.md)), and its touch calibration is in
  source, so replacing it under the approved backup rules loses nothing measured.
- **12 October 2026:** steps 5 and 6, and the first iPhone install.
  Disc (step 5): the iPhone's GalaxyPad holds the game as `RMGE01.wbfs` plus an
  extracted folder with only `sys/` and the two files the import verifies; the
  Original engine reads the image. The New engine reads every file, and a missing
  movie stops it (`MoviePlayerSimple::startMovie` panics), so all 3.2 GB are
  needed. Choosing New in the Engine menu now adds the missing files from the
  installed image first (same checked export as the import; each file written
  under a temporary name, free space checked first), with progress and Cancel, and
  writes a marker; new imports write it too. The launch path requires the marker.
  Storage (Milestone 2): both engines' data is image plus folder, about 6.7 GB.
  Saves (step 6): GalaxyPad passes the Original Wii save to the engine
  (`--import-wii-save`, `galaxypad-engine` `e35d9ac3`), which copies it once into
  `GalaxyPad/NewEngine` when that has no save, keeps a checked backup and only
  reads the Wii file. Byte-identical to the research converter on the real
  121-star save.
  CI: `ios-build` now uses Xcode 26.3 (Xcode 16.4's libc++ has no
  `std::jthread`), and `galaxypad-engine` `38045bc4` uses the host `strtoul`
  declaration that the iOS 26.2 SDK requires. The engine's Home menu tests cover the
  "Original engine..." item (absent outside GalaxyPad, asks first, Cancel changes
  nothing, Switch saves once and closes like Quit).
  iPhone 14 (build 7212, `org.galaxypad.GalaxyPad`, same signing
  identity): 61 save, setting and preference files backed up and read back
  identically, then unchanged byte for byte after installing 7210, 7211 and 7212. To
  make room (2.5 GB free), the Galaxy Native test app's game copy (3.4 GB, the
  same 2,375 files as the research copy on the Mac) was removed; its save in
  `Library/Application Support/Petari` was kept. A Mac launching the app with
  `GALAXYPAD_TEST_SELECT_NEW_ENGINE=1` runs the Engine menu's New choice without
  touch, and `GALAXYPAD_TEST_ENGINE_ARGS=1` passes its launch arguments to the
  engine (a test `--user` and fixture), for device tests.
  Not done on 12 October so far: launch and play on the iPhone (it was locked), the
  iPad (unavailable).
  Not in Milestone 1: `CADisableMinimumFrameDurationOnPhone`, which iPhones with
  ProMotion need for 120 Hz; the Original engine's display link sets no rate, so
  adding it needs its own check.
- **12 October 2026:** PR #20 merged (`ab28e2d`; `source-checks` and `ios-build`
  pass). Game-file completion checked against the real image (copied from the
  iPhone; same size as installed) in the iOS Simulator:
  `tests/test-engine-files-completion.sh` (private evidence) builds an older
  install's folder, completes it, and finds all 2,371 files identical to the
  research copy. It also checks that Cancel stops without a marker, a complete
  folder needs no writes, a damaged file and a leftover temporary file are
  repaired, and a damaged `main.dol` is refused (2,384 checks). The engine's 91
  Mac tests pass.
- **12 October 2026:** testing moves to the iOS Simulator (owner: "just test on
  simulators. get all the work done for this next version"), and the work for the
  next version continues. Simulator builds of the app now include the New engine:
  the Simulator has no prebuilt Dawn, so the engine builds Dawn from its pinned
  source commit (Metal only), checked by SHA-256 (`galaxypad-engine` `46e1ed6c`).
  Two problems found and fixed on the way:
  - **The New engine never started.** UIKit reuses a saved scene session, which
    named GalaxyPad's scene delegate, so the Original engine took the window. The
    engine now always asks for GalaxyPad's scene configuration, and GalaxyPad's
    scene delegate hands the scene to SDL's when the New engine runs the app
    (`c790aee4`). This would have happened on devices too.
  - **The test switch ran too early.** Its progress alert, shown during the
    launch rotation, left the Original engine drawing in part of the screen. It
    now runs after the first frame, as a player would; the menu's note also
    fades after five seconds.
  Saves both ways (Milestone 2 item, done): `--wii-save` copies the Wii save in
  when the New engine starts and its own save out when the player chooses
  "Original engine..." (`3a7ae6cb`). A copy only replaces a save that is missing or
  unchanged since the last copy; when both changed, each engine keeps its own.
  Every replaced file is kept, byte-checked. Mac tests cover both directions,
  repeat runs, conflicts and a damaged save; the engine's 91 tests pass.
  iPad Air 11-inch (M4) Simulator, iPadOS 27.0, GalaxyPad at engine `c790aee4`, with
  the real image, an older install's partial folder and a copy of the iPhone's Wii
  save (`cd8d1fa9`):
  - Original engine: title screen at 59.9 FPS.
  - Engine menu, New: 3.2 GB of files added, marker written, setting saved.
  - New engine: save copied in, byte-identical to `wii_save_to_native.py`'s
    output; shader preparation on first launch (9,549 shaders); the galaxy route
    by touch passed (observatory, Terrace, Good Egg mission 1: idle, jump,
    opposite moves, pause and resume).
  - Home menu, Original engine..., Switch (real taps): setting back to Original,
    the game closes; nothing copied, because nothing was played. The Original
    engine starts and the Wii save is unchanged (`cd8d1fa9`).
  - Saves back: with a different save standing in for New progress, the switch
    copied it out (converted back by the script: identical), kept the replaced
    Wii save (`cd8d1fa9`), and the Original engine's file select shows it.
  - GalaxyPad's three-dot menu, Engine, New (real taps): selected, with the note.
  iPhone 18 Pro Simulator, iOS 27.0, same build and data:
  - Original engine: title screen at 59 FPS.
  - Engine menu, New (test switch, after the first frame): 3.2 GB of files
    added, the game kept the full screen, and the note faded.
  - New engine: save copied in (`7e394e41`, as on the iPad), shader preparation,
    and the galaxy route by touch passed unattended. A first run passed its
    checks but was marked ASSISTED: four presses of the Mac's Command key reached
    the Simulator during it.
  - Home menu, Original engine..., Switch (real taps): setting back to Original,
    the Original engine starts at 59 FPS, Wii save unchanged (`cd8d1fa9`).
  Licenses (Milestone 2 release requirement): `GalaxyPadEngine.framework` now ships
  the license text of everything it links in its `Licenses` folder (`galaxypad-engine`
  `404ada13`), copied from the fetched sources; both app builds carry all twelve.
  `THIRD-PARTY-NOTICES.md` lists them and points there.
  For the owner's playtest: the New engine's Home menu follows the Wii, where a
  tap points at an item and A chooses it; a tap does not choose it directly.
- **12 October 2026:** app size (Milestone 2 item). The engine's shader seeds were
  51 databases, about 400 MB of the 459 MB app. The app now carries the engine's
  tracked seed pack instead (272 KB, the same rows), and the engine expands it on
  its first launch into `Library/Caches/Petari/pipeline-seeds`, again if iOS
  clears that folder (`galaxypad-engine` `312efcce`). The app without the game module
  is 59 MB (was 459 MB); with the module about 166 MB (was 562 MB). Storage on
  the device after the first New launch is about the same, but in a folder iOS
  can reclaim. The engine's test checks every expanded database against
  `seedpack.py`, and that a cleared folder is refilled and a damaged pack refused;
  92 engine tests pass. iPad Air Simulator: with the cache cleared, the first New
  launch expanded all 51 databases and prepared the same 9,549 shaders.
  Original engine after the round trip (iPhone 18 Pro Simulator, Simulator input):
  title, file select showing the copied 121-star file, Play This File, the Comet
  Observatory, and the player runs forward; the Wii save is unchanged afterwards.
  iPad Air Simulator, after switching back with real taps: the Original engine
  loads the save that came back from the New engine (file 1, 0 stars) and plays
  its prologue.
- **12 October 2026:** first device run of the switch. iPad Pro 12.9-inch (6th
  generation), iPadOS 27.0.1, build 7213 (`main` `41b9c67`, engine `312efcce`,
  fresh unprofiled Original module), installed in place over Preview 4 (7168) with
  the same signing identity. The 41 save, setting and preference files were backed
  up and read back identically, then unchanged after the install.
  - Original engine: runs at about 59-60 FPS.
  - Engine menu, New (test switch): 3.2 GB of game files added to the older
    install's folder, marker written, setting saved.
  - New engine: seed pack expanded on first launch, save copied in
    (`7e394e41`, as in the Simulators; Wii save unchanged, `cd8d1fa9`), shader
    preparation at about 19 per second until "Tap to start now", then in the
    background; the galaxy route by touch passed unattended.
  - Still to do on the iPad: the switch back to Original and the save check
    after it. The iPhone 14 still has build 7212.
- **13 October 2026:** the New engine looks like GalaxyPad. The owner saw the
  engine's own controls and Home button instead of GalaxyPad's, so GalaxyPad now
  draws its own controls and three-dot menu over the New engine
  (`apple/ios/GalaxyPadNewEngineHost.mm`), in a window of its own above the
  engine's (the engine's root view is a Metal view, which draws over subviews,
  and menus need a view controller). The engine (`galaxypad-engine`
  `1cda557c`) turns its own touch controls off and exports four more functions:
  input (buttons, stick, pointer), the game image rectangle, "game started" (the
  controls appear after shader preparation, so its "Tap to start" still works),
  and switch to Original (the game closes like Quit, then the save is copied out
  and the setting saved). GalaxyPad's A presses the engine's Start, which is A
  and adds B while the title asks for both, so one tap starts the game. On iOS the
  engine shows tap hints, never keyboard ones. Checked with real taps in the iPad
  Air Simulator: A starts the game from the title, a tap puts the Star Pointer
  under the finger and picks file 1, the three-dot menu opens, and Engine →
  Original → Switch closes the game, saves the setting, and the Original engine
  opens next with its full menu. The iPhone 18 Pro Simulator shows the same
  controls and menu over the 16:9 New engine. The engine's 92 Mac tests pass. In
  the Simulator the Mac's mouse also reaches the engine as a mouse (Game
  Controller), which shows a second "P2" star; a device without a mouse has none.
