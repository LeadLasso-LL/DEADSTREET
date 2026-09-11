# Ravicci Family regular outfit review

All five units are Italian-American. Built for owner visual review; full runtime atlas production and faction binding remain subsequent work. Specials remain deferred.

## Owner specifications

| Class | Head and face | Wardrobe | Accessories |
|---|---|---|---|
| Pistol | Swept-back dark brown hair; clean-shaven | Open lightweight chocolate brown blazer; cream knit polo open at collar; tailored beige trousers; dark brown leather loafers | Gold-framed aviators with brown lenses; gold wristwatch |
| SMG | Slick black hair with sharp side part | Open navy suit jacket; black silk shirt with top two buttons undone; matching navy trousers; black leather Chelsea boots | Black rectangular sunglasses; thin gold chain; gold pinky ring |
| Shotgun | Receding salt-and-pepper hair brushed back; thick trimmed mustache | Open heavy camel overcoat; dark brown waistcoat; white dress shirt; dark patterned tie; dark brown tailored trousers and sturdy leather boots | Tortoiseshell glasses with lightly amber-tinted lenses; brown leather gloves |
| Rifle | Neatly parted short dark hair; clean-shaven | Charcoal pinstripe three-piece suit; crisp white dress shirt; silver-gray tie; polished black Oxford shoes | White pocket square; fitted black leather gloves |
| Sniper | Low black wool newsboy cap; short gray hair at temples; neat gray stubble | High-collared buttoned black overcoat; black fine-knit turtleneck; charcoal tailored trousers; black leather boots | Dark charcoal lower-face scarf; fitted black leather gloves |

## Implementation and review

Ravicci's profile reuses the accepted normal anatomy, connected shoulder rig, standard motion clips and Ventresca garment helpers. The camel coat has an open lower front; the sniper coat remains buttoned. Pinstripes follow the rifle trousers without changing leg geometry. Glasses use separate lens/frame treatments. Small jewelry and fabric details remain subordinate to sprite readability.

Final full review: 1,080 frames, zero geometry or frame-bound failures; 32.082 seconds pipeline execution. Includes all eight idle/aim facings, standard action samples, full SE action clips and all 30 weapon models across eight aiming directions. The motion preview contains 108 frames. Technical visual inspection covered standing left shoulders and both joins, eight standing/aiming directions and SE motion samples. The coat opening and trouser stripe revision was rechecked in the final outfit, aiming and motion sheets.

Body and weapon proportions remain unchanged; sniper fit inherits the accepted projection and conservative SE/SW stock-position adjustment. Automated checks do not establish owner visual acceptance. These are review assets, not a completed live faction integration.

Reproduce from repository root:

    python tools/faction_design/run_faction_review.py ravicci --godot <godot-console-executable> --full

Sources: tools/faction_design/ravicci_outfits.py.
Outputs: tools/faction_design/ravicci/ (six PNG sheets, motion GIF, geometry/render/pipeline reports). Intermediate frames and jobs are ignored.

Next regular faction: Orlov Bratva.
