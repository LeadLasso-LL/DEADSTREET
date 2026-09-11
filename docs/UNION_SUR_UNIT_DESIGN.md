# Union del Sur Unit Design

Status: five regular outfit profiles and outfit/motion review assets complete. Live gameplay atlas integration and faction binding remain pending. Special units remain deferred until regular faction outfits are designed.

## Approved direction

All five units are Mexican / Mexican-American. Preserve the accepted normal body rig; clothing and equipment add only modest thickness. Check the standing left shoulder, both shoulder joins, and weapon proportions across directions and animation states.

- Pistol: short black brushed-back hair, thin mustache, black aviators with black lenses; faded terracotta short-sleeve button-up open over a white tank; dark charcoal jeans, brown leather ankle boots, gold chain and wristwatch.
- SMG: backward black baseball cap over a black ski mask; cream sleeveless T-shirt, tattoos on both arms; olive cargo pants, black high-top sneakers, compact black crossbody chest bag.
- Shotgun: short dark hair and thick black beard; faded tan canvas vest open over a black short-sleeve henley, tattooed forearms; faded blue straight jeans, brown square-toe work boots; shotgun shell loops on one side of the vest.
- Rifle: olive ski mask; faded woodland camouflage shirt rolled to the elbows, simple black chest rig with magazine pouches; black cargo pants, tan combat boots, black gloves, thin gold chain at the collar.
- Sniper: faded olive forward baseball cap over a black ski mask covering head and neck; lightweight brown-and-olive camouflage jacket with raised collar and sparse shoulder fabric strips; dark brown utility pants, worn tan hunting boots, olive gloves.

## Implementation and review

- Source: tools/faction_design/union_sur_outfits.py
- Shared runner: run_faction_review.py union_sur --godot <Godot console executable> --full
- Review artifacts: tools/faction_design/union_sur/
- 1,080 frames passed render/bounds and accepted-body-geometry checks.
- Includes eight-direction standing and aiming sheets, motion samples, a 108-frame animation review, and all 30 weapon models across eight aiming directions.
- Visually inspected main standing/aiming board, all eight standing and aiming directions, and motion sample board. Standing shoulder joins are connected; accepted body proportions retained.
- Visual details use the existing pixel rig and inherit garment transforms. Small jewelry and shell details are deliberately restrained at native sprite scale.
- Next faction in design order: L'Ordine di Lombardia.
