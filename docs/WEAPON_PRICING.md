# Firearm acquisition prices — 2026-09-15

Status: authored initial balance, implemented in game data and Arsenal; campaign economy playtesting remains the tuning authority. Prices are fictional gameplay values, not retail firearm estimates.

`assets/data/weapon_models.json` owns runtime prices. `BattleWeaponCatalog.purchase_price(model_id)` is the shared quote API; unknown IDs return -1 (invalid quote). Arsenal tiles and detail panel use that API. `tools/arsenal_production/weapon_pricing.py` preserves these authored values when rebuilding the catalog. Recruitment/training and ammunition are separate. This change does not add a shop or change combat statistics.

Accessible base pistols and pump shotguns provide early equipment choices. Rifle/SMG/sniper premiums buy role-specific reach, handling, cadence and sustained damage; higher tiers cost substantially more without making every weapon of a tier identical. Existing armor brackets ($300/$750/$1,500) and early vehicle costs ($1,400/$3,800/$4,200) anchor the scale: top guns compete with squad protection and transport budgets.

Within-role choices: CZ 75 accuracy/cadence commands a modest USP premium; Desert Eagle recoil/handling keeps it below Five-seveN. MP5K trades reach for price; P90 costs above Vector for mobile reach, while Vector specializes in close burst. Mini-14 is below AK-47; shorter-range G36C below M4A1; SCAR-H hard hits above AUG control. Mossberg is the affordable short-range pump; M2 mobility above SPAS-12; Saiga below M4 for recoil/reach tradeoffs. SKS is an accessible marksman option, AWM buys extreme reach and PSG1 sustained semiautomatic output.

| Class | Firearm | Price |
|---|---|---:|
| PISTOL | Colt M1911A1 | $350 |
| PISTOL | Glock 17 | $450 |
| PISTOL | HK USP | $850 |
| PISTOL | CZ 75 SP-01 | $950 |
| PISTOL | Desert Eagle | $1,550 |
| PISTOL | FN Five-seveN | $1,850 |
| SMG | MAC-10 | $900 |
| SMG | IMI Uzi | $1,150 |
| SMG | HK MP5K | $1,950 |
| SMG | HK MP5 | $2,250 |
| SMG | KRISS Vector | $3,450 |
| SMG | FN P90 | $3,950 |
| SHOTGUN | Mossberg 500 Cruiser | $550 |
| SHOTGUN | Remington 870 | $650 |
| SHOTGUN | Franchi SPAS-12 | $1,600 |
| SHOTGUN | Benelli M2 Tactical | $1,900 |
| SHOTGUN | Saiga-12 | $2,800 |
| SHOTGUN | Benelli M4 | $3,000 |
| RIFLE | Ruger Mini-14 | $1,400 |
| RIFLE | AK-47 | $1,600 |
| RIFLE | HK G36C | $2,700 |
| RIFLE | M4A1 | $3,100 |
| RIFLE | Steyr AUG A3 | $4,800 |
| RIFLE | FN SCAR-H | $5,200 |
| SNIPER | SKS with scope | $1,200 |
| SNIPER | Remington 700 | $1,700 |
| SNIPER | Dragunov SVD | $3,700 |
| SNIPER | Steyr SSG 69 | $4,200 |
| SNIPER | Accuracy International AWM | $6,800 |
| SNIPER | HK PSG1 | $7,600 |

Tune after observing acquisition timing, replacement costs and squad loadout diversity. Avoid a pure damage-per-second formula: reach, movement, reload exposure, recoil and protection budgets affect usefulness.
