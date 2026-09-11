# Mercer Saints unit design

Owner-approved design brief. Artwork is a review candidate until seen and accepted.
The specialist values below are an approved starting playtest specification, not
validated final balance or a claim that dual-pistol combat is implemented.

## Faction clothing direction

- Preserve the existing four Mercer standard-class outfits.
- Mercer personnel are African American, with hip-hop/streetwear-inspired clothing.
- Use believable everyday clothing and selective red accents or garments.
- Avoid dressing every member head to toe in faction colors.
- This principle applies across factions. Whittaker personnel are Caucasian with
  Southern workwear, redneck/cowboy styling; their individual outfits remain open.

## Standard sniper

- Black hoodie with the hood up over his head.
- Black bandana covering the lower face.
- Black pants and black boots.
- One red rag sticking out of a pocket; the exact pocket is an art-review choice.
- Preserve normal sniper equipment selection and existing sniper combat behavior.
- The review uses the existing Remington 700 as an illustrative loadout, not a
  faction-exclusive weapon restriction.

## Dual-pistol specialist

- Pistol-class faction specialist carrying two matching Glock 17s.
- Baggier long-sleeve red shirt, black pants, white shoes, black ski mask.
- Keep normal body proportions. The shirt hangs loosely through its hem and folds;
  baggier clothing must not create an inflated or rounded body.
- Shoulders and sleeves form a continuous garment, with no heavy black line
  separating an arm from the torso.
- Separate pistol in each hand; alternating shots, visibly separate arm recoil.
- Faction-exclusive special units should generally offer a modest advantage over
  comparable standard units while preserving reasons to recruit ordinary units.

Compared with a regular Glock-equipped unit of the same unit tier:

| Attribute | Approved starting playtest value |
| --- | --- |
| Total firing rate | 3.5 shots/second versus 2.5 |
| Per-bullet trauma | Normal Glock damage |
| Accuracy | Hit chance multiplied by 0.90; not minus 10 percentage points |
| Maximum range | 20 tactical units versus 24 |
| Rounds before reload | 24 combined versus 12 |
| Reload | 3 seconds versus 1.5 |
| Movement | 0.95 times the corresponding regular Glock unit |
| Health | Normal for the unit tier |
| Recruitment cost | Approximately 1.5 times the comparable regular pistol unit |

Weapon tiers and unit tiers remain distinct. Further matching-pair upgrades and
their allowed models have not been decided. Specialist stats require runtime
implementation and comparison tests before a gameplay acceptance claim.

## Special-unit limits

Special units are subject to faction-wide caps, as are snipers. Count units across
forces and garrisons rather than granting a fresh cap per battle or location.
Exact limits, a shared pool versus individual specialist-type caps, and cap scaling
remain undecided. Caps control rarity; they do not substitute for combat balance.

## Related concepts, not final unit specifications

- Whittaker revolver specialist and lever-action rifleman.
- Russian/Orlov LMG gunner.
- The Raiders' chainsaw Brute has its own established design in the merger and
  invasion handoff and must retain its agreed identity.

## Current production scope

`tools/faction_design/mercer_preview.py` and `render_mercer.gd` reproduce isolated
standing design candidates using the accepted native SVG rig, skin palette,
outfit drawing functions and weapon source drawings. Live outfits and combat
bindings are unchanged. Full animation production, dual-wield runtime behavior,
costs and faction-wide cap enforcement are subsequent work.
