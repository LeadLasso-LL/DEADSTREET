# Stateline Raiders MC regular unit design

Owner wardrobe specification, 2026-09-11. All five regular outfits are built for review on the existing normal rig.

| Class | Outfit |
| --- | --- |
| Pistol | Faded black backward trucker cap; shaggy brown hair curling beneath cap; horseshoe mustache; black aviators with black lenses; worn black leather club vest over white T-shirt; tattooed forearms; faded blue straight-leg jeans with wallet chain; scuffed brown motorcycle boots. |
| SMG | Shoulder-length dirty blonde hair, loose and swept back; black forehead bandana; sleeveless faded denim club vest over charcoal tank; tattoos on both arms; worn black jeans; black motorcycle boots; silver rings and chain bracelet. |
| Shotgun | Bald; long reddish-brown beard; black wraparound sunglasses with black lenses; heavy black leather motorcycle jacket open over faded gray T-shirt; dark blue straight-leg jeans; black square-toe harness boots; black fingerless gloves. Normal anatomy, modest clothing thickness only. |
| Rifle | Short dark brown hair; thick sideburns and trimmed beard; black leather club vest over muted red-and-black plaid shirt, sleeves rolled to forearms; charcoal work pants; black lace-up work boots; black belt and magazine pouches. |
| Sniper | Charcoal knit beanie; long gray hair behind ears to shoulders; black lower-face bandana; faded black denim club vest over dark olive hoodie, hood down; worn charcoal jeans; dark brown lace-up boots; fitted black gloves. |

## Club insignia

All club vests and the shotgun jacket carry a compact bison-skull-and-broken-chain back patch and small worn chest patches. The artwork follows torso transforms, with no separate image fitting. The fine insignia, rings and chains are simplified at native pixel scale.

## Implementation and validation

Source: tools/faction_design/stateline_outfits.py. The shared runner accepts stateline. The existing rig supplies normal anatomy, weapon transforms, connected shoulder construction and animation clips. No body scaling or gameplay balance changes were introduced.

Final full build: 1,080 frames, zero geometry/render-bound failures, 36.607 seconds recorded pipeline time. Includes all eight standing/aiming directions, SE animation clips and 30 armory weapons across eight aiming facings. Motion GIF: 108 frames.

Visual inspection covered all eight standing/aiming facings, shoulders, back patches and SE motion samples. Standing left shoulder and both joins are connected. Body and weapon proportions remain consistent. A corrective pass extended plaid onto the rifle sleeves and SMG tattoos onto exposed upper arms; the final main and motion sheets were re-inspected. The armory matrix was generated and automatically checked, not exhaustively inspected by eye.

Outputs: tools/faction_design/stateline/ contains six PNG boards, motion GIF, geometry/render validation and pipeline report. Reproduce with tools/faction_design/run_faction_review.py stateline --godot <Godot executable> --full.

Owner visual acceptance and full runtime atlas/faction binding remain subsequent work. These are outfit/motion review assets. New faction specials remain deferred. Cartel de Sierra Roja is next.

This pass is committed locally. The earlier automatic approval review still blocks GitHub push; this pass makes no push retry.
