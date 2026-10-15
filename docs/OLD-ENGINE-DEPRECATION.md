# Old engine deprecation and release-gate compliance

Decided by the owner on 13 October 2026, when GalaxyPad 0.2.0 made the New engine
the default: "if we're not using the old engine then we just need to deprecate it
… make it so it's compliant … and document what you do."

## Why

PadMint checks every public file with its release gate (`padmint audit`) before
it lists a game. GalaxyPad's source failed it: 118 Wii routine names carrying
memory addresses (for example the generated chunk name for the THP decode
routine) in 59 of GalaxyPad's own files. All of them came from the Old engine's
performance research: scripts and tests that patched or measured specific routines
in the module generated from the player's disc, and the notes describing that work.
None is used to build the New engine.

## What changed

- **The New engine is the default** (apple/shared/GalaxyPadSettings.mm). A choice a
  player saved earlier is kept. PadMint builds (padmint.json) contain only the New
  engine; in them the menu shows Old Engine as "Not included in this build".
- **The Old engine stays in the source, deprecated.** Existing installs that chose
  it keep working, and the Mac development app still uses it. It gets no new
  features or performance work.
- **Its routine-specific research is retired from main**: 61 files, all of them
  experiments that edited, extracted or timed named routines in the generated
  module:
  - experiments/register-residency and experiments/chunk-boundaries (18 files);
  - two opt-in policies, patches/experiments/dcbz-loop-policy.inc and
    thp-kernel-policy.inc, with their entries in config/dependency-migration.json
    (copies remain in the pinned ModernGekko fork, which this change does not edit);
  - 14 scripts (THP and Huffman kernel extraction, caching and fusion, resident
    merges, FP-guard and normalization probes);
  - 27 tests and probes built on those scripts, and their lines in
    scripts/check-repository.sh (3) and scripts/check-private-evidence.sh (8).
- **Notes keep their findings with plain labels.** In nine docs the routine names
  became descriptions such as "the THP decode routine" or "the largest generated
  routine". Guest instruction addresses in prose are unchanged.
- **Synthetic test names stay.** Tests of the Old engine's tools use invented
  names such as `func_80001000` for fixtures they write themselves; they are not
  game routines.

Everything removed is in Git history: check out the parent of the commit that
added this file to recover it. Older docs still name some retired scripts; those
references are historical.

## Result

`python3 -m padmint audit` on a `git archive` of the release revision:
**PASS** (38 address-style names, all synthetic fixtures; the limit is 50).
Before: FAIL with 118.

## Not done

- The iPhone/iPad app still links the Old engine's runtime (libGalaxyPadCore from
  ModernGekko), so PadMint builds it. Removing the Old engine from the app entirely
  would shorten PadMint's build and drop that dependency; it is a larger change to
  the app's startup and import screens and is left for later.
- The ModernGekko, RecompCore and DolRecomp forks are unchanged. They are separate
  repositories and are not part of GalaxyPad's release archive.
