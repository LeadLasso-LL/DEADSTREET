# Ventresca Family regular unit designs

Status: built for owner outfit review. All five units are Italian-American. Full runtime atlas production and faction binding remain subsequent work; no combat stats or special units are changed.

## Owner wardrobe

| Class | Head and face | Clothing and footwear | Accessories |
|---|---|---|---|
| Pistol | Short dark brown hair, neat side part, clean-shaven | Unzipped black tracksuit jacket over white T-shirt; matching black track pants; white sneakers | Gold chain and gold wristwatch |
| SMG | Slicked-back black hair with some length at the neck | Open lightweight black suit jacket; burgundy knit polo; black tailored trousers; black leather loafers | Thin gold chain at collar |
| Shotgun | Receding dark hair combed back; thick mustache | Dark brown leather jacket over cream turtleneck; charcoal dress trousers; sturdy brown leather ankle boots | None specified |
| Rifle | Short black hair neatly combed back; clean-shaven | Dark gray suit jacket and trousers; pale blue dress shirt; narrow black tie; black leather dress shoes | Black leather gloves |
| Sniper | Low charcoal flat cap; short salt-and-pepper hair at sides; dark gray lower-face scarf | Black wool coat ending at mid-thigh over charcoal turtleneck; black tailored trousers; black leather ankle boots | Black gloves |

## Implementation and verification

tools/faction_design/ventresca_outfits.py extends the existing ordinary rig with garment layers, hair, jewelry and footwear details. The coat hem extends the clothing below the unchanged torso, with a front split and rear vent. Body proportions, shoulder attachment geometry and standard motion clips are preserved.

The full review generated and checked 1,080 frames with no geometry or frame-bound failures, in 31.394 seconds of pipeline execution. Technical visual inspection covered the standing left shoulder and both shoulder joins for every unit, all eight standing/aiming facings, SE motion samples and all 30 weapon fits in SE aiming. Weapon checks render all 30 models across eight aiming directions. The motion GIF contains 108 frames.

The sniper reuses the Calle Ocho SE/SW carry-position refinement and accepted front/rear projection. This changes neither body size nor weapon drawing. Existing faction atlases are untouched.

Automated success does not constitute owner visual acceptance. The review sheets and sampled motion are not a complete runtime atlas or a live battle integration test.

## Reproduction and outputs

Run from the repository with the installed Python and Godot executables:

    python tools/faction_design/run_faction_review.py ventresca --godot <godot-console-executable> --full

The runner also supports scoped role revisions, followed by a full final pass. Outputs are in tools/faction_design/ventresca/: outfit and lineup sheets, idle/aim direction sheets, motion samples, armory fit, motion GIF and three validation/pipeline reports. Intermediate frames and jobs are ignored.

Continue with Ravicci Family in the canonical sheet order. New faction-specific specials remain deferred until the regular faction roster pass is complete.
