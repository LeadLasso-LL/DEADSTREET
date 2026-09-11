# Majmu'at al-Saffar Unit Design

Status: five regular outfit profiles and motion review assets. Live gameplay atlas integration and faction binding remain pending; specialized units remain deferred.

## Approved direction
All five units are Arab / Middle Eastern. Preserve the accepted normal human proportions, continuous shoulder joins and consistent weapon scale. Clothing, vests, scarves and equipment add only modest thickness.

- Pistol: thick swept-back black hair, short neatly trimmed beard, black aviators with black lenses; open-collar cream linen shirt rolled to elbows; dark brown trousers, brown leather loafers, gold wristwatch.
- SMG: short curly black hair with closely trimmed sides and dark stubble; burgundy track jacket with thin cream sleeve stripes, open over black T-shirt; charcoal cargo pants, black-and-white running shoes; loosely folded tan-and-black patterned neck scarf; compact black shoulder bag high against ribs.
- Shotgun: bald with thick black beard and gray at chin; dark brown leather vest over faded slate-blue collarless shirt rolled to forearms; olive work trousers, heavy brown lace-up boots; weathered tan belt with shell loops.
- Rifle: short black hair and closely trimmed beard, black wraparound sunglasses with black lenses; olive field jacket open over sand shirt; compact brown chest rig with magazine pouches; charcoal utility trousers, tan combat boots, fitted black gloves.
- Sniper: tan-and-black patterned scarf wrapped over head and lower face, dark hair mostly concealed, one short tail over shoulder; faded brown hooded field jacket with hood down over muted olive shirt; dark brown cargo pants with reinforced knees, dusty brown lace-up boots, thin olive gloves.

## Implementation
Source: tools/faction_design/saffar_outfits.py
Review assets: tools/faction_design/saffar/
Command: run_faction_review.py saffar --godot <Godot console executable> --full

All details use the existing pixel-art rig and garment transforms. The shoulder bag is placed at the ribs; the scarf tail is kept close and short. Sleeve stripes, scarf pattern, shell loops and jewelry use restrained detail at native sprite scale.

## Validation

Full 1,080-frame render, bounds and accepted-body-geometry checks passed with no failures. Main board, all eight standing and aiming directions, and motion samples visually inspected. Standing left shoulder and opposite shoulder joins remain connected. Review includes a 108-frame motion GIF and all 30 weapon models across eight aiming directions.
