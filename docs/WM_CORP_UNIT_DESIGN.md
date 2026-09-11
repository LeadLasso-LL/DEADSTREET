# Whittaker-McAllister Corporation regular outfits

Owner direction, 2026-09-11: all white units. Rural Whittaker men and polished McAllister personnel serve together, retaining their original family wardrobes.

| Role | Original outfit reused |
|---|---|
| Pistol | McAllister: sandy side-part hair, black Wayfarer-style shades, rolled pale blue open-collar shirt, tan chinos/brown belt, brown loafers, silver watch. |
| SMG | Whittaker: backward faded red trucker cap, shaggy blonde hair, sleeveless charcoal tee, tattooed arms, faded blue jeans, scuffed brown work boots. |
| Shotgun | Whittaker: brown cowboy hat, collar-length brown hair/mustache, open brown canvas vest over dark green plaid, worn black jeans, heavy tan boots. |
| Rifle | McAllister: neat dark side-part hair, black aviators, navy quarter-zip over white collar, charcoal utility trousers, black boots, magazine belt, fitted black gloves. |
| Sniper | Whittaker: woodland hood and hunting jacket, mostly hidden sandy hair, olive lower-face cloth, reinforced dark olive trousers, muddy brown hunting boots. |

Implementation: tools/faction_design/wm_corp_outfits.py dispatches directly to the original family profile per role. Full source wardrobe details remain in WHITTAKER_UNIT_DESIGN.md and MCALLISTER_UNIT_DESIGN.md. No blended outfits or body changes.

Full review passed: 1,080 frames, zero bounds/render failures, accepted body geometry preserved. All eight standing/aiming views and motion samples visually reviewed, including standing left shoulders, both joins and weapon proportions.

Output: tools/faction_design/wm_corp/. Outfit and standard-motion review assets only; live gameplay atlas/faction integration remains pending. Specialists remain deferred. Local checkpoint; prior automatic push block remains. Next: La Union del Sur.
