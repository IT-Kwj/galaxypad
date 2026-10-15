# GalaxyPad icon artwork

Original raster artwork generated on 2026-09-09 with the built-in image-generation
tool, using no reference images or game assets. This is project branding, not
Nintendo artwork. Retained source: `galaxypad-icon-source.png` (1254 × 1254).
The mobile AppIcon is a 1024 × 1024 opaque derivative resized with `sips`.

Prompt:

> Use case: logo-brand. Create an original polished GalaxyPad iOS/iPadOS app icon,
> square 1024x1024 opaque full bleed with no pre-rounded corners. One bold luminous
> orbital spiral forming a subtle G, evoking a galaxy and playful movement, on a
> deep midnight space background. Smooth sculptural cyan-to-violet light,
> restrained warm starlight accent, strong simple silhouette legible at tiny
> home-screen size. Premium native app aesthetic, not a detailed space painting.
> No words, letters printed as text, controller buttons, characters, faces,
> Nintendo imagery, existing game logos, border, watermark, or device mockup.
> Center emblem with safe inset; background extends to every edge.

`scripts/compile-ios-icons.py` compiles the catalog for both iPhone and iPad and
merges Apple's generated icon metadata before app signing. It does not change
the bundle identifier or other app settings. Keep the source and catalog together.

The mobile icon ships in GalaxyPad 0.2.1. The Mac development build has its own
ICNS generation path (see [provenance](PROVENANCE.md)). Masked/small-size visual
acceptance and editable layered/vector artwork remain separate checks; the PNG
is not a layered design source.

The gameplay screenshots in the root README were supplied by the project owner
and are retained unchanged under `docs/images/`; they are not generated icon art.
A visible FPS counter in a screenshot is not sustained-performance evidence.
