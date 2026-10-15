# GalaxyPad 0.2.0 — the New engine

GalaxyPad 0.2.0 for iPhone and iPad plays Super Mario Galaxy with the **New
engine**: the game's own code built natively for Apple devices (from the
[MacioGalaxy](https://github.com/classicrob/MacioGalaxy) port of the
[Petari](https://github.com/SMGCommunity/Petari) project), with GalaxyPad's touch
controls, controller support and three-dot menu over it. PadMint builds it on your
own Mac; there is no prebuilt download. See [Get GalaxyPad](../README.md#get-galaxypad).

## What's new

- **60 FPS, and 120 FPS on ProMotion screens.** Smooth Motion draws an extra frame
  between the game's 60 steps on 120 Hz iPads. It starts on there and can be turned
  off under Display.
- **GalaxyPad's controls and menu**, as before: touch layout editing, gyro cursor,
  controller mapping, Audio, Display, Game Data & Saves, Report a Problem and About.
  The stick steers the Star Ball and Ray by itself, so there's no Stick Mode to set.
- **Saves carry over.** On its first start the New engine copies the save from
  earlier GalaxyPad versions; switching engines copies it back.
- **First start prepares shaders** for a few minutes. Tap to start sooner; the rest
  finishes in the background.

The Old engine, used by earlier previews, is deprecated
([why and what changed](OLD-ENGINE-DEPRECATION.md)). PadMint's builds don't include
it. Installs that chose it keep it until they're replaced with a 0.2.0 build.

## Install

1. Install Xcode 26 or newer with its iOS platform.
2. In PadMint, choose GalaxyPad and iPhone / iPad. It needs about 20 GB free.
3. Install the IPA with AltStore, SideStore or Sideloadly. To keep your saves,
   install over your current GalaxyPad with the same tool and Apple ID; don't
   uninstall first.
4. In GalaxyPad: three-dot menu → Game Data & Saves → Import or Reimport Game Data,
   then choose your own USA RMGE01 revision 0 WBFS image. If you already imported
   it in an earlier version, GalaxyPad adds the files the New engine needs by itself
   and asks you to reopen it.

## What was tested

- **iPad Pro 12.9-inch (6th generation), iPadOS 27.0.1**, private builds 7214 and
  7215 (the same New engine and controls): the owner played it — 120 FPS with
  Smooth Motion, right stick and controls working — and switched engines both ways.
  Saves were byte-identical across every install.
- **iPhone 14, iOS 26.6.2**, build 7215: the New engine ran at a steady 59.9 FPS
  for over six minutes (its own log, without a player).
- **Simulators (iPhone 18 Pro, iPad Air 11-inch M4, iOS 27.0)**: a build without
  the Old engine, as PadMint makes it, starting from an older import: it added the
  missing files, asked to reopen, copied the save and started the New engine. Full
  menu, title start, pointer and engine switching were tapped through earlier.
- **Checks:** GalaxyPad's repository checks; the engine's 92 Mac tests; PadMint's
  335 tests; `padmint audit` PASS on the release source.
- **Player-style PadMint build** (PadMint 0.5.1 with Apple's Python 3.9, an empty
  PadMint folder, a fresh clone, Homebrew off the PATH, Xcode 27.0, iOS 27.0 SDK,
  8 jobs on an M3 Max shared with other builds): completed in 13 minutes
  (sources 5, runtime 5, engine 3); the IPA passed PadMint's structure check
  (minimum iOS 16.0). This run found and fixed a build that picked up a Mac's
  Homebrew library.
- **That PadMint-built IPA on an iPhone 14, iOS 26.6.2**, signed and installed over
  build 7215: 0.2.0 (7216) started the New engine with GalaxyPad's controls and held
  59.9 FPS; saves were byte-identical before and after.

## Known limits

- Completing the whole game has not been verified.
- Only the USA RMGE01 revision 0 WBFS image is accepted.
- The engine's own Home menu (controller Home button) still says "Original
  engine..." for switching back.

## Provenance

- Release revision: the `v0.2.0` tag.
- New engine: `chrissotraidis/galaxypad-engine` `580b80c06dea5622d0b8e0835a0c70cc5e2d5379`
  (MacioGalaxy `4bbf2af23d694a835652f7ac218034cb3cebade4` plus GalaxyPad's commits).
- Runtime: ModernGekko `34c628eff7c064991503ea5bf61dc05c7617d339`, RecompCore
  `8b5cc3dfea61f1ca35c156d7581fe46a0bc03e71`, DolRecomp
  `acb8e7b472f9a000ee98fbc52033f536c5e4bf4c` (config/dependencies.lock.json).
- Build: `padmint.json` (Release; device SDK iphoneos; minimum iOS 16.0). Each
  player's IPA is a personal build and is never published.
