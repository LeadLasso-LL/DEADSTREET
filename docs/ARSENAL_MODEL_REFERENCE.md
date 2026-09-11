# Arsenal model reference

Thirty models; five fixed unit classes; three weapon tiers; two models per tier. Values are provisional game balance, not manufacturer specifications. Maximum healthy vitality is 1.5. Range is measured in tactical units. Shot pace excludes aim, movement and existing class reload cycles. Movement is relative to existing unit base speed before the cover dash.

| Class | Tier | Model | Move | Range | Shots/s | Solid trauma | Critical trauma | Initial aim (s) |
|---|---:|---|---:|---:|---:|---:|---:|---:|
| pistol | 1 | Glock 17 | +24% | 24 | 2.5 | 0.28 | 0.70 | 0.22 |
| pistol | 1 | Colt M1911A1 | +18% | 23 | 1.8 | 0.37 | 0.85 | 0.28 |
| pistol | 2 | HK USP | +20% | 26 | 2.4 | 0.34 | 0.82 | 0.23 |
| pistol | 2 | CZ 75 SP-01 | +16% | 26 | 2.7 | 0.31 | 0.78 | 0.29 |
| pistol | 3 | Desert Eagle | +10% | 28 | 1.25 | 0.65 | 1.50 | 0.38 |
| pistol | 3 | FN Five-seveN | +25% | 30 | 2.8 | 0.30 | 0.86 | 0.18 |
| smg | 1 | IMI Uzi | +2% | 20 | 6 | 0.16 | 0.45 | 0.25 |
| smg | 1 | MAC-10 | +13% | 17 | 8 | 0.15 | 0.40 | 0.20 |
| smg | 2 | HK MP5 | +6% | 26 | 5.5 | 0.19 | 0.52 | 0.24 |
| smg | 2 | HK MP5K | +18% | 19 | 6.5 | 0.18 | 0.48 | 0.17 |
| smg | 3 | KRISS Vector | +4% | 23 | 9 | 0.18 | 0.54 | 0.20 |
| smg | 3 | FN P90 | +13% | 30 | 6.5 | 0.17 | 0.49 | 0.20 |
| rifle | 1 | AK-47 | -1% | 40 | 1.6 | 0.42 | 0.85 | 0.30 |
| rifle | 1 | Ruger Mini-14 | +8% | 38 | 1.45 | 0.37 | 0.80 | 0.28 |
| rifle | 2 | M4A1 | +7% | 44 | 1.9 | 0.43 | 0.92 | 0.25 |
| rifle | 2 | HK G36C | +9% | 35 | 2.2 | 0.40 | 0.86 | 0.18 |
| rifle | 3 | FN SCAR-H | -6% | 49 | 1.6 | 0.59 | 1.25 | 0.39 |
| rifle | 3 | Steyr AUG A3 | +1% | 46 | 2.05 | 0.45 | 1.02 | 0.25 |
| shotgun | 1 | Remington 870 | +2% | 12 | 1 | 0.70 | 1.20 | 0.28 |
| shotgun | 1 | Mossberg 500 Cruiser | +16% | 9.5 | 1.05 | 0.72 | 1.22 | 0.18 |
| shotgun | 2 | Franchi SPAS-12 | -11% | 14 | 1.35 | 0.74 | 1.35 | 0.36 |
| shotgun | 2 | Benelli M2 Tactical | +8% | 13 | 1.45 | 0.68 | 1.25 | 0.23 |
| shotgun | 3 | Benelli M4 | -2% | 15 | 1.55 | 0.80 | 1.55 | 0.29 |
| shotgun | 3 | Saiga-12 | -6% | 13.5 | 2 | 0.75 | 1.40 | 0.30 |
| sniper | 1 | Remington 700 | -3% | 64 | 0.42 | 0.86 | 1.60 | 1.35 |
| sniper | 1 | SKS with scope | -4% | 45 | 0.85 | 0.60 | 1.15 | 0.85 |
| sniper | 2 | Dragunov SVD | -7% | 64 | 0.7 | 0.86 | 1.65 | 1.12 |
| sniper | 2 | Steyr SSG 69 | -2% | 70 | 0.43 | 1.03 | 1.85 | 1.50 |
| sniper | 3 | Accuracy International AWM | -21% | 78 | 0.38 | 1.30 | 2.10 | 1.80 |
| sniper | 3 | HK PSG1 | -25% | 69 | 0.7 | 0.96 | 1.80 | 1.45 |

The JSON catalog also controls hit-quality probabilities, recoil accumulation/recovery, graze trauma and reacquisition time. Weapon weight is a gameplay burden index; it is not a kilogram estimate. Higher tiers are general power bands with model-specific tradeoffs.

No model-specific magazine capacity or finite tactical ammunition has been added. Existing reload presentation and cycling remain.

Sniper hits use hit quality → trauma → vitality. A critical hit can kill a healthy unit; a second wound is never an automatic kill. Movement interrupts settled aim. Visible close threats override distant target preference; explicit player focus orders remain authoritative.

All-black SCAR-H retained. Dedicated sniper outfits and campaign manufacturing/logistics are deferred.
