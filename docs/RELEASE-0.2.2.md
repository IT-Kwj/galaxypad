# GalaxyPad 0.2.2 — Files folder and easier importing

Some new installations did not show a GalaxyPad folder in Files, while the
folder-import screen told players to copy their WBFS there. Version **0.2.2
(build 7218)** prepares that folder on launch with a short import guide. Both
engines and the initial import screen use the same setup; existing files are
preserved. If the guide is removed, a later launch restores it.

The folder-import screen now offers **Choose Image** directly, including when
its folder is empty or unavailable. The instructions explain that you can select
a WBFS directly from Downloads, iCloud Drive or another Files location. Download
cloud files locally first. Copying a WBFS into GalaxyPad's folder alone does not
import it; choose **Import from GalaxyPad Folder** afterwards.

## Install or update

Build with [PadMint 0.5.2 or newer](https://github.com/chrissotraidis/padmint/releases/latest)
on an Apple silicon Mac. PadMint selects the latest public release. Install the
personal IPA over your existing GalaxyPad with the same sideloading tool and
Apple ID; do not uninstall first. See [installation](INSTALL_IPAD.md).

Import your own **USA RMGE01 revision 0, single-file WBFS** using
**⋯ → Game Data & Saves → Import or Reimport Game Data → Choose Image**.
Keep at least **9 GiB free** on the device. Game data and saves stay in private
storage, separate from the public folder.

The public assets are the build recipe and checksums. Personal IPAs, game images,
extracted data, keys and saves are not release assets.

## Validation

- Fresh iPhone 17 Simulator, iOS 27.0: Files shows GalaxyPad and its import guide;
  both import choices open the system document picker. The old 0.2.1 build left
  Documents empty and did not appear in Files.
- Fresh iPad (A16) Simulator, iPadOS 26.5: the same Files and import-navigation
  checks pass.
- In-place Simulator update from 0.2.1 to 0.2.2: four synthetic document/game/save
  fixtures remain byte-identical and existing preferences are unchanged; the
  guide is added. These are isolated fixtures, not a physical-device save test.
- Filesystem regressions cover a new directory, repeated launches, preservation
  of user files and an edited guide, deleted-guide/folder recovery, and an
  unavailable destination. They run in the default repository suite.
- The local full repository suite still stops at the pre-existing host-pressure
  probe failure on this Mac. Publication requires the complete hosted CI suite
  and iOS build to pass; this local failure is not counted as a pass.

The [GitHub release](https://github.com/chrissotraidis/galaxypad/releases/tag/v0.2.2)
records the exact commit, CI, both publication audits, and PadMint's player checks
before tagging and after publishing (current PadMint main, Apple's Python 3.9,
empty PadMint folders). Run the UI regression with `tests/run-files-ui.sh` as
[documented](../tests/files-ui/README.md).

Tests of Files and import navigation do not establish physical-device gameplay,
audio quality or full-game completion. No new performance claim is made.

## Reproduction

The app input is the `v0.2.2` tag (build 7218). Resolve its exact commit with
`git rev-parse v0.2.2^{commit}`. Dependencies and build steps are pinned in
[the dependency lock](../config/dependencies.lock.json) and [PadMint recipe](../padmint.json).
The New engine remains `2817f5fd4859088cb3e9817f1ebb4c0213f664bd`; this release
changes app setup and instructions, not the game engine. Retain compiler/SDK
versions and hashes from PadMint's personal build record alongside your IPA.
[Credits](../CREDITS.md) and [third-party notices](../THIRD-PARTY-NOTICES.md) cover
the source inputs. The supported game image must be supplied privately in-app.
