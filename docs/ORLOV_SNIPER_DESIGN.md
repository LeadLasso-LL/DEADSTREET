# Orlov Bratva sniper outfit review

Owner direction: Russian ushanka hat; tight black lower-face covering; heavy black work jacket zipped centrally with a visible zipper; dark green pants; black boots; dark green gloves. Hat color was unspecified: charcoal with gray fur and lowered ear flaps is the review candidate.

Only the sniper outfit is new. Preserve Orlov's existing pistol, SMG, shotgun and rifle outfits. Faction-specific specials remain deferred.

## Implementation and verification

The existing ordinary anatomy, connected shoulder rig and standard motion clips are reused. Jacket weight comes from seams and folds, not body enlargement. A narrow face covering follows the jaw. The zipper has a metal highlight and pull. Gloves are recolored dark green after the existing hand drawing. Sniper projection and SE/SW stock fit reuse the established corrections.

Full sniper-class review: 216 frames, zero geometry/bounds failures; 108-frame motion GIF; 7.773 seconds pipeline execution. Includes eight idle/aim facings, standard action samples across directions, complete SE walk/fire/reload/cover-transition/wounded clips and all six sniper weapons across eight aiming directions. Visually inspected the standing left shoulder and both joins, all eight idle/aim directions, SE action samples and all six rifle fits.

These are outfit/motion review assets pending owner visual acceptance. Full runtime atlas production and faction binding remain subsequent work. Existing Orlov units and gameplay stats are unchanged.

## Reproduction

From repository root:

    python tools/faction_design/review_orlov_sniper.py --godot <godot-console-executable>

Sources: tools/faction_design/orlov_sniper_outfits.py and review_orlov_sniper.py. The dedicated runner reuses the existing geometry validator, renderer, palette conversion and motion states, while producing compact single-class sheets.

Outputs in tools/faction_design/orlov_sniper/: outfit review, idle/aim directions, motion samples, six-rifle fit, motion GIF and geometry/render/pipeline reports. Intermediate frames and jobs are ignored.

Next regular faction: Zangyaku.
