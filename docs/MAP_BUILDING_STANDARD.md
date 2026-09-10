# Map building standard — approved Harold baseline

Approved by Brandon on 2026-09-10 after the arrival-car correction at commit `139d10c`: "im obsessed ... we will use this and everything we established to streamline further map building. lock it all in."
This is the accepted visual and construction baseline for future tactical maps. Preserve its quality and reuse its components while authoring distinct locations. Later explicit product decisions can revise this standard.

## Visual reference
Versioned captures in [references/harold_approved](references/harold_approved/) preserve this checkpoint:
- [Street overview](references/harold_approved/battle_02.png)
- [Frontage, plaque and solid stoops](references/harold_approved/frontage_detail.png)
- [Alley fire escape](references/harold_approved/alley_detail.png)
- [North sidewalk cans](references/harold_approved/north_bins_detail.png)
- [South sidewalk furnishing](references/harold_approved/south_bins_detail.png)
- [Arrival sedan and open doors](references/harold_approved/arrival_car_detail.png)

## Standing art rules
- Use the accepted drawn, gritty pixel-art treatment and elevated tactical perspective, with consistent scale against the approved standing units.
- Proactively correct anything resembling flat "South Park paper art." Forms need thickness, recesses, material shading, restrained texture, wear and ground contact. The garbage bags are the dimensionality benchmark.
- Windows, doors and crates need visible construction: inset glazing/jambs, sills, panels, distinct planes and believable edges. Stairs need shaded treads/risers and continuous masonry caps.
- Signs belong to their buildings and should read at street/inspection zoom. Preserve the small green/brass Harold plaque, plain bold readable lettering and address beneath. Mini-Mart uses a restrained storefront fascia. Avoid oversized facade text and decorative type that becomes illegible.
- Graffiti follows the wall surface with moderate fading and broken pigment; brick shows through the M. Keep the mark recognizable.
- Fire escapes use coherent side-plane projection, connected landings, treads, rails, supports and wall attachments. Harold's fire escape is on its alley return.
- Use a few contextual rubbish clusters with varied bags, cans, detached lids and small spills. Furnish both sidewalks while preserving walking space; the south side must not be empty by default.
- Cans receive the same visual scrutiny as bags: curved rims, open mouths where appropriate, handles, restrained ribs/dents, directional shading and contact shadows. Harold uses six cans across four spaced locations, with one upright/fallen pair on each sidewalk.
- Lamp posts sit slightly inside the sidewalk, with their light pools following the same anchors. Harold's setback is 0.6 world units from the previous positions. No street-name pole sign on this block.

## Vehicles and physical behavior
- Parked and arriving versions of a vehicle share source artwork, body proportions, paint treatment, opacity and ground-shadow construction. Arrival doors derive their palette from the body texture, with smaller foreshortened panels, raked glazing, thin frames and visible edge thickness.
- Harold sedan footprint is 5.15 x 2.1 world units. The 10 percent visual height increase stays anchored at wheel contact. Treat these as the sedan reference, not universal dimensions for every vehicle class.
- Cover must agree with the visible object, support hover/click selection, and provide reachable threat-relative positions. Curbside cans are genuine movement-blocking low cover. Spilled litter remains scenery.
- Harold's stoop sides are full-height solid walls from the building to the last step. They block movement, sight and fire. Units obtain firing angles around the ends; cover positions belong at usable corners.
- Keep visible entrances and walkways reachable. Foreground building cutaways retain physical obstacles. Boundaries and playable alley extent must agree with the authored location.
- Open arrival doors and the elevated fire escape are currently presentation only. This acceptance does not imply animated disembarking, climbable stairs, door collision or new combat rules.

## Reuse and build workflow
1. Read this standard and the next location's brief. Reuse the approved camera, scale, materials and prop construction; author a new layout and contextual variation.
2. Start with the shared geometry catalog and footprints. Place buildings, route boundaries, entrances, traffic, arrival space, lamps and a few useful cover clusters.
3. Build with the existing art routines and textures. Keep environmental state, dynamic vehicles/units and depth-sorted objects separate from static scenery.
4. Give every visible structure a material/depth pass, then inspect both normal battle zoom and close views. Compare against the saved reference captures, including south-side furnishing and arrival cars.
5. Rebuild affected static caches from retained source and shared bounds, then import. Avoid per-frame regeneration of static detail.
6. Validate the risks introduced by the map: geometry, reachable cover/entrances, visible-body selection, directional protection and intended sight/fire blocking. Use real firing angles; solid-wall midpoint slots previously caused repeated failed AI searches.
7. Measure a representative combat run after material geometry or cover-layout changes. Compare with a recorded baseline; visual acceptance and performance evidence remain separate.
8. Save source, cache changes, useful captures and implementation notes in a scoped commit. Brandon owns visual acceptance; record it when given.

## Existing implementation entry points
- `battle/geometry/harold_street_catalog.gd`: authored props, cover and lamp anchors.
- `gameplay/harold_street_art.gd`, `gameplay/dusk_street_art.gd`: reusable construction and sedan rendering.
- `assets/art/street_detail/`: shared textures and paint shader.
- `assets/art/harold_frontage/`: static scenery/prop caches.
- `tools/dusk_review/bake_harold_frontage.gd`: regenerate caches from source.
- `tools/dusk_review/harold_review.gd`: layout, cover and combat review.
- `tools/dusk_review/frontage_preview.gd`: paused interactive inspection; wheel zoom, middle-drag pan, Home fit.

## Acceptance and remaining work
The complete map-art pass through `139d10c` is visually accepted, including the corrected arrival car. Earlier "candidate" and "awaiting verdict" notes in the chronological implementation history are superseded for this checkpoint.
Existing technical evidence: 66 can checks, 40 wall checks, all 100 cover positions and both entrances reachable; valid geometry. Latest measured full street run was approximately 54–55 FPS, below the earlier approximately 59 FPS wall-only review, with remaining spikes in the combat step. The final car correction was visually inspected and passed existing checks; it did not establish a new FPS result.
Font portability, exact source-emblem matching, broader combat AI review and campaign-to-layout selection remain recorded follow-ups. The current map approval does not resolve these separate tasks.
The next feature backlog remains in [HAROLD_AVE_PRODUCTION_BRIEF.md](HAROLD_AVE_PRODUCTION_BRIEF.md): arrival choices, deployment previews/information, ready orders, drag selection and arrival/victory staging. Wait for Brandon's next instructions before selecting new scope.
