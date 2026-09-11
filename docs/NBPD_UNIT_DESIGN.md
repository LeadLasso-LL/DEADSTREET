# NBPD regular unit outfit design

Owner direction: 2026-09-11. Five regular outfits, including the ordinary sniper; faction specialists remain deferred.

## Shared uniform
Emblem-green trousers with thin gold outer-leg stripes; black boots; black police duty belt with holster, radio, handcuffs, baton and utility pouches. All hats green. Green ramp: #284c3b / #496b50 / #173528; gold: #b59a55. These are pixel-art interpretations of the visible emblem, not sampled source colors. Preserve accepted normal anatomy and weapon scale; armor and bomber jackets add modest clothing detail only.

| Class | Approved outfit direction |
|---|---|
| Pistol | Green peaked police cap, black visor and gold badge; short brown hair, clean-shaven; black aviators; white short-sleeve uniform with epaulettes and two chest pockets, left gold badge and right gold nameplate; both upper-sleeve NBPD patches. |
| SMG | Green police baseball cap with small emblem; short black hair; white shirt rolled to elbows; fitted black bulletproof vest with small front gold badge and white POLICE back lettering; shoulder patches; black gloves. |
| Shotgun | Green felt cowboy hat with black band and small gold badge; short graying hair and thick mustache; green old-school police bomber with broad collar, ribbed cuffs and waistband, partly unzipped over white uniform; gold chest badge and sleeve patches; black leather gloves. |
| Rifle | Neatly side-combed sandy blonde hair, black aviators; white long-sleeve uniform buttoned at wrists, tucked narrow black tie; gold badge/nameplate and sleeve patches; shoulder radio microphone and additional belt magazine pouches. |
| Sniper | Same green police baseball cap as SMG; short dark brown hair; green bomber zipped high with raised collar, white shirt at neck; sleeve patches and chest badge; black communications earpiece and fitted black gloves. |

## Implementation and review
Source: tools/faction_design/nbpd_outfits.py. Uses existing rig, animation clips and shared sniper shoulder-fit adjustment. Review outputs: tools/faction_design/nbpd/.
These are outfit and standard-motion review assets, not completed live gameplay atlases or faction binding. No new gameplay stats, special units or armor mechanics are introduced by the clothing.

Full review passed: 1,080 frames, zero render/bounds failures, accepted body geometry preserved. Visually inspected all eight standing and aiming directions plus motion samples, including standing left shoulders, both joins and weapon/body consistency. Details are simplified at the native pixel scale. Push remains subject to the previously reported automatic approval block; local work continues under standing user authorization.
