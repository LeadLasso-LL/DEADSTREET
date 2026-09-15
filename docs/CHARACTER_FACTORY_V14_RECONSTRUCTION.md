# V1.4 reconstruction evidence

2026-09-08. No style accepted. G_NEUTRAL_FORWARD50 was seen and approved by owner as a temporary test pose only. Camera remains provisional, catalog unbound.

First comparison: external run 20260908_v14_reconstruction_03. Standalone opt-in Godot tool: tools/character_factory/godot/reconstruction_v14.gd. Twelve outputs: A clean reduction, B tonal planes, C form edges, D heuristic material ramps, each at 96/80/64 seed-height previews. These are NOT gameplay sizes. Fixed source SHA256 fda0e2bdf33786cc05859c30e7bbc632002cde160ae39982e94e52d93fb3717b. Source G from 20260908_143910_contact_render.

Mask: largest 8-connected alpha128 component, 7405 pixels, bounds (220,204)-(361,353), plus 2 source pixels of alpha32 fringe. No universal segmentation claim. Float linear-light premultiplied-alpha reduction, final-resolution processing; no generative AI, random grit or geometry changes. All candidate alpha matches control; transparent output borders and PNG decoding pass. Independent run 20260908_v14_reconstruction_04_repeat now VERIFIED: zero PNG hash mismatches.

Technical assessment: B/C flatten arms and weaken rifle contrast; D restores rifle contrast but brightens clothing and remains too flat. No accepted style. RGB heuristics conflate dark cloth and metal. Current next experiment: auxiliary DAZ material-label guidance with all geometry retained for correct occlusion, same camera/pose. No animation, directions, runtime, simulation, commit or push.

The first label run (20260908_v14_material_labels_01) rendered beauty but exited before labels; NOT a pass. Discovered factory outer catch suppressed exceptions after any interim result write. Corrected to always record unhandled exceptions. Label readback corrected to serialize Color directly. Retry 02 pending.

Review images are delivered inline plus a direct open link, as preferred by owner. The first board is dead_street_v14_comparison.png.
## Material-guided follow-up - verified 2026-09-08

Auxiliary label run 20260908_v14_material_labels_04: PASS, full geometry retained with original cutout/opacity and camera. Base-color textures cleared, distinct role colors applied, reflective/translucent lobes suppressed for auxiliary guidance only. This is a shaded role-color pass, not an exact renderer ID canvas or beauty source. Numeric-property API reference: https://docs.daz3d.com/public/software/dazstudio/4/referenceguide/scripting/api_reference/object_index/numericproperty_dz (clearMap/getMapValue).
Retries 01/02 stopped on map readback; 02 explicitly recorded getMap not a function after the catch fix. Retry 03 exposed inherited enumerable properties in the scripting environment; required-role validation now uses an explicit six-role array. Only run 04 is the successful label source.

Label SHA256 7185376314b8c38967c3c903262f7ee3632c1aa5c0edeca64312ce9eaf8f5efb. Compared with original G: maximum logged joint-rotation delta 0; camera readback exactly equal. Source RGB is still the original frozen G PNG, not rerendered beauty. Core alpha128 pixel classification: skin 2234, shirt 981, trousers 1160, weapon 1152, hair 328, boots 732, unknown 820 (about 11%). Unknown pixels retain source RGB; material coverage is not a production-complete segmentation claim.

Processor now optionally takes a THIRD argument: label PNG. Two-argument A-D behavior remains byte-identical (verified run 20260908_v14_reconstruction_05_regression vs original 03, zero PNG hash mismatches). Label mode produces E material shading and F stronger contours. Same source bounds/alpha, nearest label sampling, same-material local luminance smoothing, fixed ramps calibrated once on this controlled source. No per-frame percentile fitting. Six previews at 96/80/64 seed heights, still NOT gameplay-size contracts.

Final follow-up output: 20260908_v14_material_reconstruction_02. Repeat 20260908_v14_material_reconstruction_03_repeat: zero PNG hash mismatches. All six PNGs decode, have transparent borders, and exactly preserve corresponding control alpha. First uncalibrated E/F development run 01 retained.

Visual assessment (technical, not owner acceptance): E/F correct the lifted-shirt/trouser problem and restore material distinction and some broad shading. Still not an earned reference match. Residual gap includes source projection, stance/readable torso-leg shapes, and lack of reference clothing forms, not just palette choice. Further filter tweaking alone should not be presumed sufficient. Next preflight should compare source composition against the reference and determine a bounded source-form experiment; any revised pose/camera remains a review candidate, never silently canonized. No 8-direction production, walk cycle, runtime binding, movement/simulation changes, commit or push.

Review board: dead_street_v14_material_comparison.png, inline image plus direct open link. Successful persistent save. HEAD remains 5a7d3bd.