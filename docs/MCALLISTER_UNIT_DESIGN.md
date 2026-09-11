# McAllister Holdings regular unit design

Owner wardrobe specification: all white units. Five regular outfit review candidates, 2026-09-11.

| Class | Outfit |
| --- | --- |
| Pistol | Sandy blonde side-swept hair; black Wayfarer-style glasses and black lenses; open-collar pale blue button-up, sleeves rolled to elbows; tan chinos, brown leather belt; brown loafers; silver watch. |
| SMG | Backward navy baseball cap; wavy brown hair curling beneath; forest green polo; unzipped lightweight beige Harrington; dark blue straight jeans; clean white sneakers. |
| Shotgun | Brown leather-brimmed sporting cap; short graying hair, trimmed mustache; olive shooting vest with brown suede shoulder panels; cream/brown checked shirt rolled to forearms; dark brown corduroy trousers; brown leather field boots. Normal anatomy with modest clothing thickness. |
| Rifle | Short dark side-parted hair, clean-shaven; black aviators and lenses; navy quarter-zip over white collared shirt; charcoal utility trousers; polished black boots; black belt and magazine pouches; fitted black gloves. |
| Sniper | Narrow-brimmed dark olive boonie; short auburn hair and close-trimmed beard, largely concealed by brown lower-face cloth; brown waxed field jacket, raised olive corduroy collar; dark green sweater; woodland hunting pants; brown leather hunting boots; dark olive gloves. |

## Implementation and review

Source: tools/faction_design/mcallister_outfits.py. Runner accepts mcallister. Uses the existing normal rig, direction transforms and weapon fitting. Faction skin-palette binding is explicitly set before delegating to the reusable adapter. An initial binding mismatch was caught during generation and corrected before the successful full build.

The shooting vest, jackets and shirts preserve normal anatomy; texture, seams and paneling distinguish fabrics. Fine jewelry, corduroy and beard detail beneath face cloth are simplified at native pixel scale.

Full review passed: 1,080 frames, zero geometry/render-bound failures. Includes eight idle/aim facings, SE action clips and 30 armory weapons across eight aiming facings. Motion GIF: 108 frames. Recorded timings are in pipeline_report.json.

Visual inspection covered the main sheet, all eight standing/aiming facings and SE motion samples. Standing left shoulders and both joins are connected, and body/weapon proportions remain consistent. Reviewed collars, hats, checked sleeves, shooting panels and camo trousers. The armory matrix is generated and automatically checked, not exhaustively inspected by eye.

Six PNG sheets, motion GIF and three validation/report JSON files reside in tools/faction_design/mcallister/. Reproduce with tools/faction_design/run_faction_review.py mcallister --godot <Godot executable> --full.

Owner visual acceptance and full runtime atlas/faction binding remain subsequent work. New specials remain deferred. This completes the major-gang regular outfit review pass; Texas Recovery Coalition is next in the printed order.

Local checkpoint only. The earlier automatic approval review still blocks GitHub push; no retry is part of this pass.
