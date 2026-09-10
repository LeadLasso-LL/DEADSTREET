# Harold Ave. / Mercer Heights — accepted product brief
2026-09-10. These are product decisions, not claims of implemented features.

**Map-art acceptance:** Brandon approved the complete Harold street pass through `139d10c`, including the final arrival-car correction, as the baseline for future maps. [MAP_BUILDING_STANDARD.md](MAP_BUILDING_STANDARD.md) consolidates the accepted visual rules, reuse workflow and reference captures. Deployment/arrival milestones below retain their separate implementation status.

## Purpose and style
First repeatable production street, establishing reusable buildings, props, scale, projection, cover/collision, contextual placement and lighting for future city blocks. Match the first detailed gritty pixel street study. Inspect at normal/close battle zoom. Avoid ambiguous shapes, stretched props, excessive pixel chunks, bright pasted-on units, or pristine streets.
Dense, poor, grimy, inhabited, older brick neighborhood. Maintained poorly, not abandoned. Patched asphalt, dirt, graffiti, rubbish collected at curbs/bins/service areas. Many parked cars on both sides, correctly facing traffic with realistic spacing and unblocked access. Combat width slightly exaggerated from a narrow neighborhood road.
Nighttime and dry. Actual street lamps, storefront/entrance lighting, scattered lit apartment windows. Future campaign turn weather must drive tactical rainfall and wet surfaces; keep environmental state separate from base location assets.

## Geography
Campaign neighborhood Mercer Heights; street Harold Ave.; objective Harold Apartments; Mercer Mini-Mart immediately left; north alley immediately right. Road continues offscreen left/right, no intersection required. No street-name pole sign on this block. Tactical street identity still comes from the campaign location.
Tall apartments continue beyond top of frame. Foreground buildings use low opaque cutaways; physical footprints remain blocking. Battles outdoors for now, special interior scenarios later. Alley visually continues but only a short entrance with dumpster/bin cover is playable on THIS map. Other maps must support full wrapping alley flanks.
Stoops have stairs and solid cover-bearing masonry sides. Cars are the main cover, supplemented by contextually placed dumpsters, walls, etc. Cover objects remain clickable: selected unit + hover highlights object; click chooses legal reachable protection relative to enemies. Never deploy opposing sides on same cover object.
Local street gang defends; Russian mafia attacks.

## Deployment system (following milestone)
Defenders left-central, anchored to objective entrance. Fixed broad approximately rectangular deployment zone extends across their sidewalk and road on their portion of map, excluding opposite sidewalk. More space away from attackers, less on near side. It does not change with arrival choice.
Attackers right/right-central. Three convoy arrival choices: close/medium/far from defender entrance. One choice positions ALL actual campaign arrival vehicles in a line, one behind another, straight or mildly angled as context warrants. One shared circular deployment region across the convoy. Far circle slightly larger than medium, medium larger than close; all compact with some cover. Cover options may overlap ACROSS arrival choices, never between opposing deployments. Always dead space between opposing zones. Close can start in shotgun range if defender placement/sightlines allow.
Faded vehicle/unit previews move immediately as player places starting positions. Units may start in valid cover or open space. Defenders know the committed attacking deployment; attackers do not know defender chosen positions while deploying. A player defending sees faded committed attackers/vehicles while selecting their own positions. Vehicle-versus-vehicle scenarios have separate rules to decide later.

## Arrival and ready sequence (following milestone)
Lock deployment, then convoy enters, stops, doors open, attackers disembark and move to selected positions.
The FIRST vehicle entering the battle frame makes EVERY defender briefly turn and look toward it. Then defenders prepare and move simultaneously with arriving attackers.
Casual defending gatherings begin visibly unarmed, standing, leaning or seated on stoops/objects. Long-gun users (shotgun/rifle/sniper) fetch assigned weapons from a crate near objective entrance. Pistol/SMG users draw their weapons and move directly. HQ/stronghold defenders may already be armed; per-scenario staging.
After everyone arrives, pause in ready state. Player may queue first instructions (move, cover, flank) before clicking Start Battle. Only Start Battle begins combat and queued-order execution. Skip permitted provisionally; normal playback default, skip resolves the SAME ready state, never starts combat.
Attacker victory: surviving units enter objective doorway. Defender victory: survivors quietly regroup at entrance, no celebration. Wounded movement stays wounded. No interior implementation required merely for doorway exit.

## Input request (queued separately)
Left-button hold/drag draws translucent rectangle. Select first eligible friendly unit inside it, single selection now; prepare for possible future grouping. Do not silently introduce multi-select. Define deterministic first-unit behavior during implementation.

## Implementation sequencing
1. Shared street catalog and reusable art; this map's physical layout, factions and visual acceptance.
2. Arrival choices, ghost deployment, defender information advantage, ready-state orders, drag selection.
3. Vehicle/door/disembark animation, defender reaction/weapon retrieval, optional skip, victory staging.
Preserve existing orders, cover ownership, pathing, approved unit rig/limp/mirrors, outline, blood toggle. Combat AI remains under review, particularly multi-threat cover decisions.

## Standing map-art correction — September 10 continuation
All map construction must be inspected for and corrected when it resembles flat South Park paper cutouts. Require believable thickness, recesses, directional shading, material texture, wear and contact shadows; use the accepted trash-bag treatment as a reference for dimensionality. This applies proactively to future blocks as well as doors, windows, delivery crates and stairs here.
Stair sides are constant-height solid masonry walls from the building through the final step, blocking sight/fire as well as movement. Units must obtain a sightline around the ends; no over-wall shooting. Stairs themselves remain traversable in the existing flat navigation model.
Signs belong to the street: restrained Mercer Mini-Mart fascia; discreet rectangle left of the apartment entrance reading Harold Apartments with 1455 Mercer Ave. beneath. Address text follows the latest explicit request; it does not rename the campaign street from Harold Ave.
Retain the red blackletter M identity, with modest fading/chipping that reveals brick rather than a pristine pasted-on mark. Final faction-emblem matching still needs the approved source image. Visual acceptance remains the user's decision.


## Plaque, alley fire escape and street sign — follow-up correction
Keep the green/brass apartment plaque beside the door, but make its words readable at street/inspection zoom. The name may stack within the small rectangle; retain 1455 Mercer Ave. underneath. Do not return to large facade lettering.
The apartment fire escape belongs on the alley side, with coherent landings, treads, railings, supports and wall attachment. Remove front-elevation fire escapes.
The green Harold Ave. pole sign must be a small realistic rectangular street-name blade with a curbside ground anchor, clear of the sidewalk's walking strip.


## Sidewalk furnishing and vehicle finish — latest follow-up
This supersedes the earlier request for a green street-name pole sign: remove it entirely. Nudge the streetlight poles and their light pools slightly inward from both curbs.
Trash cans must receive the same material/depth/contact-shadow scrutiny as the approved bags. Use a few well-spaced locations on both sidewalks; one or two locations can pair an upright can with a fallen can and spilled rubbish. Cans, particularly at the curbs, are real selectable cover objects. Keep walking routes open and avoid repetitive clutter.
Retain the accepted plaque layout and frame, but replace the hard-to-read decorative lettering with clear type.
Arrival cars must have the same body scale and visual finish as parked cars, with visibly open doors. Give the cars only a slight increase in vertical presence against standing units. Animated arrival/door opening and door-specific collision/cover remain part of later staging work.
