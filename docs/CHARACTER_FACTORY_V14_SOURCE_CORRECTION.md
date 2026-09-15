# V1.4 source composition and lighting correction — 2026-09-08

Status: experimental. No static style, camera, or production pose accepted. No runtime bind or commit.

## What was actually established
- Reference reviewed directly. Prior SE tests were a poor comparison for its front-facing bodies.
- Same Matt/Genesis 9, tank, trousers, boots, PMWS carbine and owner-authorized temporary G_NEUTRAL_FORWARD50 pose used. Root yaw/camera candidates are isolated studies, not catalog directions.
- Composition 01: yaw 0 at elevations 56/40/30, 320 mm after framing. 30 degrees clipped the core and is invalid. Composition 02 reran 30 at 280 mm, unclipped. The 40-degree/320 mm candidate remains experimental.
- Legacy light intensity requests 96/20 both clamp to 2 (controller range 0..2). Normalizing to .96/.20 barely changed the image: NOT a demonstrated visual fix.
- Legacy environment setters queried render-element objects that do not contain Environment Mode. The actual DzEnvironmentNode exposes Scene Only enum 3, Draw Dome, Draw Ground.
- Composition 03 explicitly set Scene Only/ground off and photometric light power; all beauty RGB remained black. Low-alpha contamination disappeared. Example 1500-lumen capture alpha16 bounds 105,13..415,477; alpha128 bounds 106,13..414,476. All occupied RGB exactly zero.
- Composition 04 live first-pass readback demonstrated BOTH SmokeKey and SmokeFill Color = [0,0,0] before correction, [255,255,255] afterward. Legacy buildLight uses setValue(Color); the tested correction uses setColorValue(Color). This was a concrete defect, not an art limitation.
- The corrected isolated path uses Scene Only, Draw Dome=0, Draw Ground=0, white lights, Photometric Mode=1, Intensity=1, key Flux 150000 / fill 30000 (also tested 15000 / 3000). Actual rendered cast shadows and folds visibly change.
- Legacy buildLight/default recipes are deliberately not migrated yet. The correction is opt-in via composition views with flux. Archived V1.3 outputs were not overwritten. Do not use the legacy path as evidence that requested lighting works.

## Exact corrected source
External root: C:/Users/brand/AppData/Local/DeadStreetCharacterFactory/runs/20260908_composition_04
- source/WHITE_150000_beauty.png SHA256 44817ff377aa3d29b8b99521cbe891b9f735dd07d79f49c327078a701ab0403b
- source/WHITE_150000_labels.png SHA256 52b7bea97cfdd8862d803a431ec21dbedee86987aa8048950dbb4df53e69b317
- Camera: yaw 0 subject, elevation 40, focal 320 after frame, headlamp mode 2/intensity 0.
- Core alpha128 AABB 106,13..414,476 (309x464), 59785 pixels. Core does not touch image borders.
- Label image is a shaded material-role pass with occluding geometry present; it is not a perfect object-ID or albedo pass. Ambiguous labels retain source RGB.

## Conversion study
Standalone Godot script reconstruction_v14.gd now accepts optional fourth user argument graphic after SOURCE OUTDIR LABELS.
- Previous 2/3-argument image algorithms remain available for controls.
- Graphic path: crop from core, linear-premultiplied Lanczos reduction, fixed material ramps and local same-role luminance grouping at target size.
- G: grouped ramps. H: selective interior contour reinforcement.
- I: H plus one-pixel outer contour, two-pixel canvas padding.
- J: softer interpolation of fixed ramps plus outer contour, avoiding the hardest posterized skin patches.
- G/H preserve control alpha exactly. I/J intentionally expand coverage by a one-pixel contour; original coverage is retained. These are shape/readability candidates, not accepted production rules.
- Preview BODY heights 96/80/64 are not gameplay heights. I/J canvases 70x102, 59x85, 48x69 include padding and contour.
- graphic_contour and graphic_repeat have zero PNG hash mismatches. Per-output repeated conversion and alpha checks pass.
- graphic_soft was invalid as a J comparison (dispatch initially selected H). Use graphic_soft_corrected, where J takes its distinct softer path. All 12 outputs pass repeat and alpha validation.
- Script rejects source cores touching image borders and unrecognized fourth arguments. Existing output directories are refused.

## Assessment and dependency
The corrected source supplies real broad shadows; front-facing composition exposes legs/torso; contours support small-size readability.
This does NOT earn the reference family. Remaining gaps include compact proportions, boots/leg silhouette, layered garment detail, and integrated shading/edge character. A flat black tank cannot supply the reference's vest construction through filtering.
Do not iterate arbitrary grit filters or expand to directions/animation. Next bounded source-art study must target those remaining form/garment gaps, under the verified lighting setup; any product change remains a review candidate. No purchases implied.
Static style acceptance still precedes 8-direction consistency, animation, temporary Godot bind and movement proof.

## Scope
Only factory tooling and reports changed. DAZ source assets and render runs stay external. No generative AI, runtime/catalog/spec/simulation changes, commit or push.

Final regression: legacy A-D PNGs in 20260908_v14_reconstruction_06_regression match 20260908_v14_reconstruction_03 exactly (zero hash mismatches). HEAD rechecked as 5a7d3bdbd532204e7516779c9dc8514ad59e7998. No commit/push.

## Reference analysis and owner correction — 2026-09-08

Primary acceptance gap: illustrated construction versus processed 3D realism. The owner specifically calls out this distinction; do not recast it as mostly wardrobe or body proportions.

Inspection used original roster image, enlarged shotgun/SMG/rifle/sniper/operative crops, full WHITE_150000 source, enlarged hand crop, and latest J comparison. Descriptions concern visible appearance, not an assertion about how the reference was created.

- Line hierarchy: dark outside contours AND selective internal separations at sleeves, vest panels, overlapping arms, weapon parts and knees. Line weight/value varies; the current fixed outer dilation cannot reproduce that hierarchy.
- Painted form planes: readable small highlights sit against broad dark masses. Highlights on sleeves, shoulders, gun top edges and boots explain shape; soft photographic gradients do not dominate. This is not simple global posterization.
- Tonal hierarchy: much of the outfit is dark; faces, exposed arms and a few edges carry the brighter accents. Our earlier ramps often lifted broad surfaces or made weapons uniformly gray, losing this hierarchy.
- Shape editing: boots, bent knees, layered torso and weapon silhouette are compact, assertive graphic shapes. The study preserves smooth anatomical/tapered shapes and long shiny boot gradients. These amplify the style gap but are not a complete explanation.
- Detail selection: a few contrasting seams, folds, panels and weapon highlights survive at the displayed size. Broad blank regions and uncontrolled render grain both miss that organization.
- Surface finish: broken, restrained color variation softens the drawing. Texture is subordinate to form and must not become generic grit or added random noise.
- Consistency: the vehicles share outlined panels, selective edge lights and dark painted surfaces, reinforcing that this is a whole visual language, not merely a character camera choice.

Support grip: visible support hand is crowded at the receiver/magazine area adjacent to the firing hand, with awkward wrist/finger arrangement. It does not read as a clear supporting hold beneath the forward handguard. Screenshot alone does not prove exact 3D mesh intersections; inspect source geometry before claiming them. The old wrist/knuckle target residuals only measured agreement with selected targets; those targets/orientations can be wrong. Verify palm orientation, finger closure, forearm approach and separation of hands as well as target distance.

Revised experiment requirements: bounded grip repair first, then keep corrected character/shot fixed while testing illustrated form treatment. Separate outer contour, internal overlap/crease boundaries, broad shadow grouping and selective highlights. Current shaded color-label pass is not reliable geometry/normal/depth evidence. Preflight export/derivation of such structural information before promising an unattended render-pass route. Use fixed scene/surface-consistent rules where possible; a one-frame hand-painted success alone does not establish animation-safe conversion. No new wardrobe shopping or body redesign as a substitute for earning the illustrated treatment. No claim of an accepted style.
