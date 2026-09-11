# Zangyaku regular outfit review

All five units are Japanese. Owner wardrobe:

| Class | Head and face | Wardrobe |
|---|---|---|
| Pistol | Black ponytail; narrow silver-framed dark sunglasses | Open-collar pale gray short-sleeve button-up; intricate forearm and collar tattoos; black tailored trousers and leather loafers; silver wristwatch |
| SMG | Big pronounced blonde spikes with dark roots; folded black bandana at hairline like a sweatband; small silver hoop earring | Open black satin bomber, sleeves pushed up; white tank; tattooed forearms; charcoal tapered pants; black-and-white low-top sneakers |
| Shotgun | Black crew cut; thick sideburns; square black sunglasses | Black tank; two full tattoo sleeves; red parachute streetwear pants with modest folds and gathered ankles, normal leg proportions; black leather boots |
| Rifle | Neatly parted black hair; clean-shaven; round black-framed glasses | Tucked white V-neck; sleek gray trousers; polished black dress shoes; fitted black gloves |
| Sniper | Low black beanie; long straight black hair past shoulders; charcoal face cloth | Matte black mid-thigh hooded raincoat with hood down; gray high-neck shirt; charcoal tapered cargo pants; black lace-up boots; thin black gloves |

## Review evidence

Existing normal body and connected shoulder rig preserved. Pants use decorative folds and cuffs rather than enlarged limbs. Initial sniper role-selection bug was corrected before final review; blonde spikes were refined. Final full review: 1,080 frames, no body-geometry or bounds failures, 35.303 seconds; 108-frame motion preview. Scope includes eight idle/aim facings, action samples across directions, full SE clips and all 30 weapon models across eight aiming directions.

Standing left shoulders and both joins, direction sheets and SE motion samples were visually inspected. Corrected sniper and blonde hair were rechecked in final outfit, aiming and motion sheets. Fine jewelry and fabric details are represented at sprite scale.

Outfit candidates await owner visual acceptance. Full runtime atlas production and faction binding remain subsequent work. New specials remain deferred. Next regular faction: Bìtiān.

## Reproduction

    python tools/faction_design/run_faction_review.py zangyaku --godot <godot-console-executable> --full

Source: tools/faction_design/zangyaku_outfits.py.
Outputs: tools/faction_design/zangyaku/ contains six PNG sheets, motion GIF and geometry/render/pipeline reports. Intermediate frames and jobs are ignored.

## Accessory revision

Rifle glasses now have black circular frames. SMG now wears a folded black bandana at the hairline, with a small rear knot and short ties. Updated outfit and all eight standing facings visually inspected, including shoulder joins. Full 1,080-frame geometry/bounds review passed (35.461 seconds). Push remains blocked by automatic approval review pending destination-specific authorization; changes are committed locally.
