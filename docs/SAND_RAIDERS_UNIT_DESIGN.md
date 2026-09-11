# Raiders of the Sand - Regular Unit Design

Status: outfit and motion review assets; live gameplay atlas integration and faction binding remain pending. This pass does not implement Brute, Coyote, special units or melee behavior.

## Approved direction
Normal human proportions throughout. Filthy fabric with sandy dust and scattered dried reddish-brown bloodstains. No exaggerated bodies or bulky cloth silhouettes.

- Pistol: greasy black jaw-length hair, uneven stubble concealed by dirty ivory plastic smile mask with cheek crack; faded pink motel polo with crudely removed sleeves; sandy brown trousers held by knotted electrical cord; battered white tennis shoes; bloodstained bandage on one forearm.
- SMG: unevenly shaved dark hair; faded orange prison jumpsuit peeled down and tied at waist; dirty white ribbed tank with dried blood on lower front; sand neck cloth; one black fingerless glove; scuffed black institutional shoes; faded prison numbers on folded rear jumpsuit.
- Shotgun: dirty off-white head sack with uneven eyeholes, loose neck gathering, crooked temple repair; faded blue work shirt with uneven rolled sleeves; stained sand canvas butcher apron above knees with dried bloody hand smears; dark brown trousers and battered black work boots.
- Rifle: thinning reddish comb-over and scraggly mustache; black rectangular sunglasses with dirty tape repair; filthy dark brown suit jacket on bare chest, crooked faded beige tie directly around neck; mismatched woodland trousers; worn tan military boots; scavenged canvas belt pouches; dried blood on cuffs and lapel.
- Sniper: ragged sandy curtain over head and shoulders, faint faded floral pattern; dirty lower-face gauze, long tangled gray hair; holed charcoal sweater; dusty brown trousers and mismatched burlap knee patches; battered leather boots with fraying cloth wraps; short stained shoulder strips.

## Implementation
Source: tools/faction_design/sand_raiders_outfits.py
Review assets: tools/faction_design/sand_raiders/
Command: run_faction_review.py sand_raiders --godot <Godot console executable> --full

Garment details inherit the existing rig transforms. The apron is an above-knee cloth extension, not altered anatomy. Prison numbers remain on the folded jumpsuit rather than the tank. Blood is muted dried brown; dust and small repairs use restrained marks at native sprite scale.

## Validation

Final full 1,080-frame geometry/render review passed with zero failures. Main review, eight-direction standing/aiming and motion samples visually inspected, with the final sniper eye detail corrected and rechecked. Standing shoulder joins remain connected and normal proportions are preserved. Includes 108-frame motion review GIF and all 30 weapon models across eight aiming directions.
