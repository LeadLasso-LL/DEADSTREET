# Cartel de Sierra Roja regular unit design

Owner specification, 2026-09-11: all Mexican units. Five regular outfit review candidates.

| Class | Outfit |
| --- | --- |
| Pistol | Black hair brushed back to collar, neat mustache; black aviators with black lenses; cream silk short-sleeve shirt, muted gold chain print, top buttons undone; dark blue fitted jeans; brown pointed-toe leather boots; gold chain and watch. |
| SMG | Forward black baseball cap, short dark hair and faded sides; open-collar burgundy polo; light blue straight-leg jeans; white leather sneakers; small black crossbody bag high on chest; forearm tattoos. |
| Shotgun | Tan cowboy hat, dark brown band; short black hair, thick mustache; brown leather vest over charcoal button-up with sleeves rolled to elbows; faded black jeans, silver buckle; scuffed brown square-toe boots. |
| Rifle | Black buzz cut, dark stubble; black wraparound sunglasses and lenses; olive combat shirt rolled to forearms; fitted black tactical vest and magazine pouches; tan cargo pants; brown combat boots; black gloves. |
| Sniper | Faded woodland boonie; dark brown neck hair; olive lower-face cloth; woodland field shirt; loose muted olive camouflage strips at shoulders; dark olive cargo pants; worn brown lace-up boots; olive gloves. |

## Implementation

tools/faction_design/sierra_roja_outfits.py extends the accepted ordinary-unit rig and shared review runner. Clothing details preserve body proportions. The tactical vest fits within the torso and the sniper tabs add light fabric detail. Hat silhouettes, black eyewear, shirt pattern, high bag and layered vest distinguish the five roles. Fine jewelry, boot styling and fabric patterns are simplified at native pixel scale.

## Verification

Full pipeline: 1,080 frames; zero geometry/render-bound failures; recorded generation time 35.351 seconds. Eight idle/aim facings, SE action clips and all 30 armory weapons across eight aiming facings are generated. Motion GIF contains 108 frames.

Visual inspection covered the main outfit sheet, eight standing/aiming facings and SE motion samples. Standing left shoulders and both joins are connected; body/weapon proportions remain consistent across poses. Hat shapes, camo strips and crossbody bag were reviewed. The armory matrix was automatically checked but not exhaustively inspected by eye.

Six PNG review boards, motion GIF and three validation/report JSON files are in tools/faction_design/sierra_roja/. Reproduce with tools/faction_design/run_faction_review.py sierra_roja --godot <Godot executable> --full.

Owner visual acceptance and full runtime atlas/faction binding remain subsequent work. New specials remain deferred. Whittaker was completed early as the approved exception, so McAllister Holdings is next.

Local checkpoint only: the earlier automatic approval review still blocks GitHub push; this pass makes no retry.
