# Bìtiān regular unit design

Owner direction: all five units are Chinese. Regular outfit review candidates, 2026-09-11.

## Approved wardrobe specification

| Class | Outfit |
| --- | --- |
| Pistol | Black curtain hair, center-parted to cheekbones; thin black frames and black lenses; loose cream short-sleeve shirt with muted brown geometric print, open over white ribbed tank; black pleated trousers; black leather loafers; gold chain. |
| SMG | Short black messy fringe; teal-and-charcoal nylon windbreaker, open over white T-shirt; faded blue straight-leg jeans; white retro running shoes; silver wristwatch. |
| Shotgun | Short black flat-top; thick black rectangular sunglasses with black lenses; worn black leather jacket with broad collar, open over burgundy polo; charcoal straight-leg jeans; black leather work boots; gold ring. |
| Rifle | Black combed-back hair, longer at neck; waist-length dark brown suede jacket; tucked beige fine-knit polo; dark charcoal pleated trousers; black leather shoes; black belt with simple magazine pouches. |
| Sniper | Faded black forward baseball cap; straight black collar-length hair; charcoal lower-face cloth; raised-collar dark olive field jacket over black crewneck sweater; dark gray straight-leg utility pants; black lace-up boots; thin black gloves. |

## Implementation and verification

Source: tools/faction_design/bitian_outfits.py. Shared review runner now accepts bitian. Reuses the existing normal body rig, authored directions, weapon fitting and animation clips. Loose fabric is expressed through clothing details without changing anatomy.

Full review: 1,080 frames, zero reported geometry/render-bound failures; recorded pipeline runtime 33.897 seconds. Includes eight standing and aiming facings, SE action animation and all 30 armory weapons across eight aiming directions. Motion review GIF contains 108 frames.

Visual inspection covered the main outfit sheet, all eight idle/aim facings and SE motion samples. Standing left shoulders and both shoulder joins are connected; body proportions and weapon scale remain consistent. Pattern, layered clothing, hair and black eyewear were reviewed. The armory matrix is generated and automatically checked; this pass does not claim manual inspection of every armory combination.

Outputs: tools/faction_design/bitian/ (six PNG review sheets, motion GIF and three validation/report JSON files). Reproduce with tools/faction_design/run_faction_review.py bitian --godot <Godot executable> --full.

Owner visual acceptance and full runtime atlas/faction binding remain subsequent work. These assets are outfit and motion reviews, not a newly integrated playable faction. New special units remain deferred. Stateline Raiders MC is next.

Commit locally. GitHub push remains blocked by the earlier automatic approval review; no push retry is part of this pass.
