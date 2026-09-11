# Texas Recovery Coalition regular outfit design

Owner direction: black and the TRC emblem green throughout clothing/equipment, including matching green ski masks. Normal anatomy; armor adds modest thickness only.

| Class | Outfit |
| --- | --- |
| Pistol | Forward black tactical cap; short brown hair, clean-shaven; black wraparound sunglasses/lenses; fitted short-sleeve black tactical shirt; lightweight green ballistic vest with TRC chest patch; green tactical pants; black duty belt/holster, boots and gloves. |
| SMG | Black high-cut helmet/headset; green ski mask; black combat shirt rolled to forearms; compact black carrier; green pants, black knee pads; helmet-side TRC patch; black boots/gloves. |
| Shotgun | Black full-coverage helmet and ski mask; green long-sleeve combat shirt; heavier black vest and close-fitting shoulder protection; front shell loops; TRC upper-sleeve patch; black tactical pants/knee pads; black heavy boots/gloves. |
| Rifle | Black full-coverage helmet and black ski mask, exactly matching shotgun headwear; black long-sleeve combat shirt; green carrier/black magazine pouches; TRC chest patch; black pants/green knees; black boots/gloves. |
| Sniper | Green hood over black ski mask; lightweight green jacket with short shoulder fabric strips; slim black chest rig; upper-sleeve TRC patch; black pants/black reinforced knees; black boots/gloves. |

## Implementation

tools/faction_design/trc_outfits.py extends the accepted normal rig; runner accepts trc. A shared forest-green ramp (#344c36, highlight #526c4c, shade #203425) is a visual approximation of the supplied emblem, not a claimed sampled source swatch. Mask, armor, helmet, hood and trousers use the same ramp. Small star-and-eye insignia are simplified for native pixel scale.

Armor surfaces preserve torso/limb anatomy. Headgear changes silhouettes without changing body scale. The standard weapon armory is preserved; this wardrobe pass does not recolor guns.

## Validation and scope

Full 1,080-frame geometry/render-bound pass succeeds with zero failures; recorded pipeline runtime 103.532 seconds. Includes eight idle/aim facings, SE clips and all 30 armory weapons in eight aiming directions. Motion GIF: 108 frames.

Visual inspection covered standing left shoulders, both joins, all eight idle/aim facings and SE motion samples. Helmet differences, mask visibility, hood and armor proportions were reviewed. The armory matrix is generated and automatically checked, not exhaustively inspected by eye.

Six PNG boards, motion GIF and three validation/report JSON files are in tools/faction_design/trc/. Reproduce with tools/faction_design/run_faction_review.py trc --godot <Godot executable> --full.

Owner visual acceptance and full runtime atlas/faction binding remain subsequent work. These are outfit/motion review candidates. New special units remain deferred. NBPD is next.

Local checkpoint only: the earlier automatic approval review still blocks GitHub push; no retry is part of this pass.

## Owner revision

Sniper trousers are black. Rifle headwear delegates to the exact shotgun headwear drawing: black full-coverage helmet and black ski mask. Other wardrobe and anatomy remain unchanged.

Revision verification: full 1,080-frame pass succeeded; eight standing facings visually checked for black sniper trousers, identical rifle/shotgun headwear and connected shoulders.

## Shared back marking

All five regular units now carry centered muted-gold TRC lettering above the established star-and-eye motif, then TEXAS RECOVERY / COALITION on two smaller lines. Condensed block glyphs and subtle worn ink follow the animated outer torso. NW print is counter-mirrored so lettering stays readable. Existing clothing and body geometry preserved. Small full-name lettering reads as fine print at native gameplay scale. Full 1,080-frame validation passed; rear idle/aim, walk, reload and wounded views visually checked. Review assets only; live gameplay integration remains pending.
