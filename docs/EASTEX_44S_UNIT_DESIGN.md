# Eastex 44's regular unit outfits

Owner direction, 2026-09-11. All five units are African American. These are the
regular pistol, SMG, shotgun, rifle and sniper outfits. New faction-specific
special units remain deferred until the regular faction roster design pass ends.

| Class | Head and face | Upper body | Pants | Footwear |
|---|---|---|---|---|
| Pistol | Blue durag | White T-shirt; tattoo sleeves on both arms | Black | White shoes |
| SMG | White ski mask | White T-shirt undershirt with a blue basketball jersey over it | Gray | White shoes |
| Shotgun | Black ski mask; hoodie hood down | Black hoodie | Woodland camouflage | Timberland-style wheat/tan work boots |
| Rifle | Backward black hat; blue bandana over lower face | Black T-shirt | Black | Black shoes |
| Sniper | Black hoodie hood up over head; white ski mask | Black hoodie | Black | Black boots |

Use the established normal anatomy and animation rig. Clothing changes do not
authorize body changes. Preserve the standing left-shoulder join and both shoulder
connections; inspect the hip/hem overlap and body/weapon scale across facings and
stances. See [UNIT_ART_STANDARD.md](UNIT_ART_STANDARD.md).

Blue appears where specified; do not add blue to the shotgun or sniper outfit to
force a uniform color scheme. The SMG undershirt must remain visibly separate from
the jersey. The shotgun hood stays down and the sniper hood stays up. Camo patches
follow the existing leg segments; boot details retain the existing limb geometry.

The owner approved the five generated outfit designs after the review checkpoint
and authorized the one-time Whittaker pass. Full runtime atlas production and
faction binding remain subsequent work. Review weapons are examples from
the existing armory and do not establish faction weapon restrictions or new stats.

## Reproduction

Run with the existing project Python and Godot installations:

1. `python tools/faction_design/review_eastex.py`
2. `Godot --headless --path . --script res://tools/faction_design/render_eastex.gd`
3. `python tools/faction_design/review_eastex.py --board`

Use `--extended` in step 1 to add standard motion/stance samples and compatible
armory model reviews. Source SVGs and individual review frames are reproducible
intermediates under `tools/faction_design/eastex/frames/`. No live faction binding
or combat tuning is changed by this review generator.

## Outfit review checkpoint — 2026-09-11

- 1,080 review frames rendered with zero frame-edge failures; each torso matches
  the accepted ordinary-unit geometry. No per-unit preview fitting or body scaling.
- Technical visual inspection covered the standing left shoulder and both shoulder
  joins on all five units; all eight standing/aiming facings; SE walk, reload, cover,
  wounded and falling samples; and the SE aiming fit of all 30 armory models.
- Corrected the camouflage drawing order so broad trouser highlights no longer
  obscure the woodland patches. Short sleeves connect into the existing shoulder.
- The motion GIF reuses the standard walk, fire, reload, cover and wounded clips.
  These are outfit review samples, not a complete runtime atlas release. Full
  production binding remains a later step after outfit acceptance.
- The owner subsequently approved the outfit designs. Automated checks alone do
  not assert product acceptance. No special-unit design or combat-stat change is
  included.

Review outputs: [outfit sheet](../tools/faction_design/eastex/eastex_outfit_review.png),
[all standing directions](../tools/faction_design/eastex/eastex_idle_directions.png),
[all aiming directions](../tools/faction_design/eastex/eastex_aim_directions.png),
[motion GIF](../tools/faction_design/eastex/eastex_motion_review.gif),
[motion samples](../tools/faction_design/eastex/eastex_motion_samples.png), and
[armory fit](../tools/faction_design/eastex/eastex_armory_fit.png).
Generate the last two inspection boards with `python tools/faction_design/review_eastex.py --audit`
after the extended render and board commands.
