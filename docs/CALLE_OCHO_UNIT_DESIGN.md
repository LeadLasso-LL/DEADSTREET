# Calle Ocho regular unit outfits

Owner direction, 2026-09-11. All five units are Mexican-American. Resume the
official sheet order after the approved one-time Whittaker pass. Ventresca Family
follows Calle Ocho. New faction-specific special units remain deferred.

| Class | Head, hair and face | Upper body | Lower body and footwear |
|---|---|---|---|
| Pistol | Black forehead bandana; short slicked-back black hair; thin mustache | White ribbed tank top; shoulder and arm tattoos; thin gold chain | Charcoal work pants; white low-top sneakers |
| SMG | Backward black baseball cap; short dark hair visible underneath | Open mustard-gold short-sleeve shirt over white T-shirt | Faded black jeans; black-and-white skate shoes |
| Shotgun | Shaved head; thick dark goatee; black sunglasses | Brown plaid overshirt buttoned only at top, over black T-shirt | Loose tan work pants; heavy black work boots |
| Rifle | Short black hair with close fade; black lower-face bandana | Charcoal short-sleeve work shirt; simple black belt and spare magazine pouches | Olive cargo pants; black boots |
| Sniper | Faded black hood up; dark hair concealed; dark gray lower-face cloth | Faded black hoodie; black gloves | Charcoal work pants; black boots |

Clothing uses the accepted ordinary anatomy, gait and shoulder joints. Loose
trousers retain the normal proportions. The white tank, mustard shirt panels,
plaid opening, cargo pockets and headwear are material details on the same rig.

## Review evidence

- Full review: 1,080 frames, zero geometry or frame-edge failures; eight facings,
  standard action samples and all 30 armory models. Build time was 40.222 seconds,
  excluding remote transfer and visual inspection.
- Visually inspected each standing left shoulder and both shoulder connections,
  all eight standing/aiming facings, SE walking/reload/cover/wounded/falling samples,
  and all 30 models in SE aiming. The shoulders remain connected.
- Ordinary motion review GIF includes walk, fire, reload, cover pop/tuck and
  wounded walking. These are outfit review assets, not a full runtime atlas or
  new faction binding. No combat stats or special-unit behavior were changed.
- The owner approved Whittaker's clothing, then noted sniper stocks sitting too
  high. That feedback prompted the bounded comparison below. Calle Ocho outfit
  approval remains pending owner review.

## Conservative sniper stock fit

The Calle Ocho review adapter moves the SE sniper carry origin by +6 horizontally
and +3 vertically in rig coordinates; SW follows as the existing mirrored view.
Both grip targets follow the same weapon origin. Rifle drawings, scale, angles,
grip anchors, muzzle anchors, torso geometry and lower-body geometry are preserved.
The other six facings are byte-identical with the adjustment on or off.

The focused comparison checked 96 before/after pose pairs across six sniper models
and eight facings, plus rendered 24 SE carry/aim comparison frames without clipping.
The aiming stock-center distance to the existing near shoulder fell from roughly
7.1-9.6 to 0.8-2.9 local rig units, depending on model. The comparison was visually
inspected for all six rifles; it improves the original over-shoulder placement.
This is deliberately limited to Calle Ocho's SE/SW review poses. Older faction
review assets and live atlases have not been rebuilt with the new position.

## Reproduction and outputs

`python tools/faction_design/run_faction_review.py calle_ocho --godot <Godot-console-path> --full`

`python tools/faction_design/review_calle_stock_fit.py <Godot-console-path>`

Use the shared runner's `--roles` option for revisions after the first complete
build; final review must use `--full` without a role filter.

- [Outfit review](../tools/faction_design/calle_ocho/calle_ocho_outfit_review.png)
- [Standing directions](../tools/faction_design/calle_ocho/calle_ocho_idle_directions.png)
- [Aiming directions](../tools/faction_design/calle_ocho/calle_ocho_aim_directions.png)
- [Motion GIF](../tools/faction_design/calle_ocho/calle_ocho_motion_review.gif)
- [Motion samples](../tools/faction_design/calle_ocho/calle_ocho_motion_samples.png)
- [Armory fit](../tools/faction_design/calle_ocho/calle_ocho_armory_fit.png)
- [Stock comparison](../tools/faction_design/calle_ocho/stock_fit/sniper_stock_comparison.png)
- [Stock validation](../tools/faction_design/calle_ocho/stock_fit/stock_fit_validation.json)
