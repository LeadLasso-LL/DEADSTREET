# Whittaker regular unit outfits

Owner direction, 2026-09-11. All five units are white. The owner approved Eastex's
outfits, then authorized Whittaker as a one-time exception to sheet order. Return
to Calle Ocho afterward. Faction-specific special units remain in the later pass.

| Class | Head, hair and face | Upper body | Lower body and footwear |
|---|---|---|---|
| Pistol | Tan cowboy hat; short brown hair visible beneath it | Faded cream western shirt, sleeves rolled to elbows | Blue jeans, brown leather belt and silver buckle; brown cowboy boots |
| SMG | Backward faded red trucker cap; shaggy blonde hair flowing from sides and back | Sleeveless charcoal T-shirt; tattooed exposed arms | Faded blue jeans; scuffed brown work boots |
| Shotgun | Dark brown cowboy hat; collar-length dark brown hair; thick brown mustache | Open brown canvas work vest over dark green plaid shirt | Worn black jeans; heavy tan work boots |
| Rifle | Olive baseball cap; short dark brown hair; neatly trimmed beard | Tucked-in khaki work shirt, sleeves rolled to forearms | Dark brown utility pants; black work boots; simple black belt and spare magazine pouches |
| Sniper | Faded woodland camo hood; mostly concealed short sandy brown hair; muted olive lower-face cloth | Lightweight woodland camo hunting jacket | Dark olive pants with reinforced knees; muddy brown hunting boots |

Keep ordinary body proportions, established joints and consistent weapon scale.
Inspect the standing left shoulder and both shoulder joins, eight facings, motion
and armory combinations. Hats and clothing detail must not resize the body.
See [UNIT_ART_STANDARD.md](UNIT_ART_STANDARD.md).

## Review production

The clothing adapter reuses the accepted rig, connected arm roots, lower-body
geometry, boots, tattoo pattern and standard animation clips. The shared review
runner creates frames, performs geometry checks, renders, checks frame bounds,
applies the palette and assembles the review sheets in one invocation.

`python tools/faction_design/run_faction_review.py whittaker --godot <Godot-console-path> --full`

Use `--roles shotgun` (or another regular class) for a targeted revision after an
initial complete build. Run `--full` without `--roles` before the final checkpoint.
Targeted reports explicitly identify their subset; they do not count as the full
review. The complete review retains Eastex's 1,080-frame scope and all 30 weapons.

These are outfit and motion review candidates. Full runtime atlas production and
faction binding follow outfit acceptance. The weapons are review examples, not a
new restriction on Whittaker equipment, and no combat stats change in this pass.

## Technical review checkpoint - 2026-09-11

- All 1,080 review frames retain accepted ordinary torso and lower-body geometry
  and pass frame-edge checks. No per-outfit body fitting or anatomy changes.
- Visually inspected the standing left shoulder and both shoulder joins for all
  five outfits; all eight standing/aiming facings; SE walking, reload, cover,
  wounded and falling samples; and SE aiming with all 30 armory models.
- Corrected the long hair's front silhouette so the SMG unit's blonde side hair
  does not create an unintended beard. Rechecked the corrected standing/aiming
  sheet and eight standing facings after the full rebuild.
- The shared runner reproduced all six Eastex PNG review sheets and its motion
  GIF byte-for-byte. Its separate 1,080-frame regression build also passed.
  See `shared_pipeline_regression.json` and `pipeline_report.json` for evidence
  and measured build time; these timings exclude review and remote transfer.
- The owner approved the clothing review. Subsequent sniper stock feedback is
  tested in [Calle Ocho's review](CALLE_OCHO_UNIT_DESIGN.md). Full runtime atlas production and
  faction binding remain subsequent work; the motion GIF uses standard clips.

Review outputs: [outfit sheet](../tools/faction_design/whittaker/whittaker_outfit_review.png),
[standing directions](../tools/faction_design/whittaker/whittaker_idle_directions.png),
[aiming directions](../tools/faction_design/whittaker/whittaker_aim_directions.png),
[motion GIF](../tools/faction_design/whittaker/whittaker_motion_review.gif),
[motion samples](../tools/faction_design/whittaker/whittaker_motion_samples.png), and
[armory fit](../tools/faction_design/whittaker/whittaker_armory_fit.png).
