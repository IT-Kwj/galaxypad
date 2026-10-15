# Working on GalaxyPad

## Current release and publication boundary

The owner authorized the GalaxyPad 0.2.2 Files-folder fix as a source/build-recipe
release. PadMint 0.5.2+ builds the New engine locally. Public release assets are
the recipe and checksums; personal IPAs and game binaries must stay private.
Do not restore historical binaries or infer authorization for a new binary release.
See [release evidence](docs/RELEASE-0.2.2.md) and [publication scope](docs/RIGHTS-STATUS.md).

Before any future public release, every artifact must pass both `python3 -m padmint audit <artifact>`
and `python3 ~/.codex/release-gate/release_gate.py <artifact>` on the maintainer's
machine. A failure is a stop, not a note. For PadMint-built releases, run
`scripts/player-check.sh` from PadMint's current main with the clean game checkout
before tagging and without it after publishing. Apple's Python and an empty
PadMint folder are required; warm-cache builds do not substitute for this check.

Keep changes simple, focused and consistent with the existing application design.
Recheck controls and navigation after changing their wiring. Do not suggest Figma.
Read [CONTRIBUTING.md](CONTRIBUTING.md) before implementation.

## Ownership and dependencies

- GalaxyPad owns its Apple app, controls, import flow and packaging. Runtime and
  compiler changes belong in the maintained galaxypad-engine, ModernGekko,
  RecompCore or DolRecomp fork, with reviewable commits. Update the app's pinned submodule reference to
  consume them; do not recreate a bootstrap patch stack.
- Preserve upstream names, author history, license texts and per-file attribution.
  Describe GalaxyPad's changes separately from upstream work. Follow an upstream
  project's contribution policy before preparing a submission to it.
- Pin dependencies and nested dependencies to full commit IDs. Keep the dependency
  lock, submodule references and documentation consistent. Never use a floating
  branch or tag as a release input or reset a dirty dependency checkout silently.

## Changes and validation

- Understand and explain each accepted change. Fix a concrete problem; avoid
  unrelated refactors, duplicate implementations and speculative optimizations.
- For a behavioral repair, reproduce the failure and add a focused regression
  where feasible. Keep experiments opt-in and outside normal build defaults.
  Moving an experiment into the default path requires separate review and evidence.
- Run focused checks and the complete default `scripts/check-repository.sh` suite
  with prepared dependencies. Report failures or unavailable checks directly;
  do not weaken a gate or substitute source-string checks for runtime behavior.
- Private game-derived checks use `--with-private-evidence` explicitly. A build,
  Simulator run or synthetic input test does not prove physical gameplay, audio
  quality or performance. Record device, OS, build and scenario for device claims.
- Preserve game data, saves, settings, signing identity, existing installations
  and concurrent work. Use isolated test data and checkouts. Never publish game
  images, extracted assets, saves, NAND, credentials or signing material.

## Release evidence

For each new release, record the app revision, recursive dependency commits,
compiler/SDK versions, build flags, generated-module identity, and hashes of all
compiled inputs and final artifacts. Retain redistributable source inputs and
third-party notices with reproduction instructions. Identify inputs users must
supply privately. Missing provenance is unfinished release work; an old binary
cannot acquire a complete source history by updating today's checkout.

Do not describe a change as merged, published or device-validated before it is.

## Current handoff

Start with [STATUS](docs/STATUS.md), [0.2.2 release evidence](docs/RELEASE-0.2.2.md)
and the [documentation index](docs/README.md). The New engine is the current
mobile path; the [engine switch plan](docs/ENGINE-SWITCH-PLAN.md) records its
integration and the [native engine plan](docs/NATIVE-ENGINE-PLAN.md) its research.
The Old engine is [deprecated](docs/OLD-ENGINE-DEPRECATION.md). September handoffs
and component benchmarks remain historical evidence, not current gameplay gains
or instructions to resume retired performance work.
