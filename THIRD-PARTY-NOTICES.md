# Third-party code and source

See [Credits and provenance](CREDITS.md) for linked upstream projects and their roles.

GalaxyPad integration files retain their per-file SPDX identifiers and attribution.
GPL-3.0-or-later integration code is distributed under the accompanying LICENSE.
Other upstream files retain their own licenses.

The runtime adapts ModernGekko, its Dolphin/RecompCore and GXRuntime dependencies,
and Apple integration patterns from SunPad. DolRecomp generates ahead-of-time
modules. Current runtime/compiler integration changes are recorded as commits in
the maintained forks, selected through pinned submodules. Exact references are in
`config/dependencies.lock.json` and the [dependency guide](docs/DEPENDENCIES.md).
Original project names, author histories, licenses and per-file notices remain
attached to that work. Optional experiments do not change the normal source graph.

The New engine (`ref/galaxypad-engine`, from MacioGalaxy and the Petari
decompilation, both CC0) is pinned the same way. The app embeds it as
`GalaxyPadEngine.framework`, which links Aurora (MIT), Dawn (BSD-3-Clause), abseil
(Apache-2.0), SDL (zlib), Dear ImGui (MIT), fmt (MIT), FreeType (FreeType License),
libpng (libpng license), Tracy (BSD-3-Clause), xxHash (BSD-2-Clause) and zstd
(BSD-3-Clause), plus the system's SQLite, zlib and bzip2. The license text of each
ships inside the app, in `GalaxyPadEngine.framework/Licenses`; the engine's build
copies them from the fetched sources and stops if one is missing. Portions of this
software are copyright © The FreeType Project (www.freetype.org). All rights reserved.

The historical Preview 1 packages include PreviewNotices with original license texts from the runtime
and its bundled third-party dependencies. The release source supplement contains
runtime source and frozen audio inputs; the matching GalaxyPad integration source
is available at the release tag. Consult its corresponding-source instructions for
build inputs and known reproduction limits. Migrating the current source checkout
to forks does not rebuild those historical binaries or resolve missing build inputs.
New releases must record complete build-input provenance as described in
[CONTRIBUTING](CONTRIBUTING.md).

Game images, extracted game assets, and saves are not included. The binary packages
do include an AOT game-code module. The project does not grant rights in the original
game. Rebuilding that module requires the supported user-supplied input.
