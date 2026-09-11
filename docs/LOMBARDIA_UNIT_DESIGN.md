# L'Ordine di Lombardia Unit Design

Status: regular outfit and motion review assets. Live gameplay atlas integration and faction binding remain pending; specialized units are deferred.

## Approved direction
All units are Italian-American. Use the accepted normal body proportions; jackets and coats add modest clothing thickness. Always inspect standing left shoulder attachment and consistent weapon scale across poses and directions.

- Pistol: collar-length swept-back dark brown hair, clean-shaven; black aviators/black lenses; black short-sleeve knit polo with subtle cream collar piping; light gray tailored trousers; black loafers; gold chain and wristwatch.
- SMG: short black sharp fade and neat goatee; dark brown leather bomber unzipped over a white ribbed tank; black tailored trousers and Chelsea boots; gold chain against the tank and gold bracelet.
- Shotgun: receding brushed-back black hair, thick salt-and-pepper mustache; black rectangular sunglasses/black lenses; charcoal wool car coat open over burgundy turtleneck; dark gray checked dress trousers; sturdy black leather ankle boots and black gloves.
- Rifle: short dark brown precise side part, clean-shaven; dark chocolate double-breasted suit; pale cream shirt, narrow black tie, small cream pocket square; matching brown trousers, polished black Oxfords, fitted black gloves.
- Sniper: low dark brown flat cap; wavy salt-and-pepper collar-length hair; black lower-face scarf; dark olive tailored mid-thigh overcoat with raised collar over black fine-knit sweater; charcoal dress trousers; dark brown lace-up boots; fitted black gloves.

## Implementation
Source: tools/faction_design/lombardia_outfits.py
Review: tools/faction_design/lombardia/
Command: run_faction_review.py lombardia --godot <Godot console executable> --full

Coat skirts and trouser checks are garment decorations; accepted anatomy is unchanged. Tailoring details, jewelry, and piping stay restrained at native pixel scale. All five profiles inherit existing weapon and animation behavior.

## Validation

Full 1,080-frame geometry/render review passed with no failures. Main board, all eight standing and aiming directions, and motion samples visually inspected. Standing left shoulder and opposite shoulder remain attached; coat hems preserve normal anatomy. Includes 108-frame motion GIF and 30-model armory review.
