# Tactical HUD and player orders — 2026-09-13

Status: IMPLEMENTED and VALIDATED through the 2026-09-14 line-command revision; owner playtest acceptance pending. Source: Brandon's
HUD discussion and explicit approval in the receiving build chat. Whittaker Estate
is deferred until this control pass is reviewed. Dedicated optimization remains parked.

- Tactical pause retains camera, inspection, selection and order entry. Playback
  is Pause, 0.5×, 1×, 1.5×, grouped at bottom right beside audio.
- Entire friendly roster is visible, without paging. Neutral compact cards use
  the approved prominent warm-white weapon symbols at top left: handgun, three
  staggered bullets, assault rifle, pellet fan, circular crosshair. Small portraits,
  vitality, critical status and selection remain legible.
- Stable class/id roster order; living units precede eliminated units. Wounds do
  not change ordering. Wounded units remain selectable for inspection; established
  survival behavior takes priority and interrupted orders are explained.
- World/card click, Shift-click, drag selection, class buttons and Select All.
  Commands apply only to selected units. Focus Left/Right leave the player HUD.
- Ground move, cover occupation and enemy priority are contextual. Group ground
  destinations are spaced; cover reservations distribute available legal slots.
  Target priority coexists with positioning and never independently causes pursuit.
- Hold seeks nearby reachable cover protective against the relevant enemy, retaining
  an existing useful slot. Push/Fall Back place a vertical tactical line; recipients
  travel through cover where useful, keep firing logic, and complete individually.
- Push uses role-appropriate advance destinations before the line; completion releases
  positioning to normal AI. Fall Back reaches friendly-side cover and becomes Holding,
  retaining the defensive boundary. Individual point/cover orders retain their existing
  arrival rules. Clear Orders releases selected recipients. No order queue.
- Card bottom-right text replaces triangle/square badges: Pushing (muted green),
  Falling Back (muted red), Holding (gray). Replacement, release, wounds and death
  clear each recipient's ownership. Target priority can coexist with positioning.
- Selected units show routes and priority-target lines; these are hidden while placing
  a group line. Persistent ground selection, destination and target circles are removed.
  Hold has the specifically approved brief gray acknowledgement pulse.
  Unavailable cover, unreachable destinations, range and blocked shots are visible.
- Reload, aiming, firing and cover posture remain automatic. Formation choices,
  cover, timing, target priorities and retreats provide player influence.

Validation: 63 explicit order/runtime checks and 39 native UI/input checks passed
in official Godot 4.7.2 release, with zero script/engine errors. The 1440×1000
review rendered all 24 combatants and displayed all 12 friendly cards together.
Pause froze simulation/RNG/weapon state; GUI selection, pause/speed controls,
camera movement while paused and a projected world-ground click were exercised.
Group cover used exclusive slots; individual replacements and Clear Orders were
selection-scoped; wounded/eliminated badge and roster rules were checked.

The original fixed-position Hold and retained-position Push/Fall Back behavior was
superseded by the line-command revision below. Wounds still interrupt explicit
commands and use existing survival behavior; wounded cards allow inspection.

Reproduction and evidence: [tools/tactical_controls](../tools/tactical_controls/README.md).
No new broad performance/32-unit campaign was run. A brief interactive smoke
averaged 59.91 FPS; its commanded scenario is not comparable to prior benchmarks.
Next: Brandon's in-game HUD/control review and requested refinements, before
resuming Whittaker Estate.

## Owner review corrections — 2026-09-13

Approved in Brandon’s screenshot review; IMPLEMENTED / VALIDATED; owner visual acceptance pending.
Selected floating emblems use a yellow ring and soft glow. Their anchors move modestly
from -29 to -26 above standing actors, and -21 to -19 above wounded/cover actors.
Unselected badges retain their normal appearance; the Emblems toggle controls all.

Transport controls use drawn geometry rather than font-dependent glyphs, left to
right: pause bars, double left triangles (0.5×), right triangle (1×), double right
triangles (1.5×), Emblems, Audio. Pause explicitly pauses; Space still toggles pause.
The active button outline carries the state. Selection/manual instructions and the
separate pause/speed label are removed. Contextual failed orders, blocked shots,
out-of-range targets and wounded status remain available.

Roster header: active and eliminated counts only, with green/red numbers and neutral
words. Faction emblem and name sit immediately left of relative strength. The pistol
icon is a side-profile handgun with a distinct slide, angled grip and open trigger guard.

Vehicle correction: the accepted bridge traffic used 1.6× dimensions; fleet art and
bodies remained at 1×. A shared VehicleModelCatalog.TACTICAL_SCALE now governs fleet
art, physical profiles/collision cache, bridge traffic, door panels and exit offsets.
Body cover/placement already derives from profiles. All 75 fleet models use this
shared path. Campaign capacity, price, upkeep, speed and source art stay unchanged.
The existing road traffic size remains unchanged. Evidence below is a representative
convoy validation, not an exhaustive playtest of every vehicle combination/map.

Revision validation: 146 native checks passed in official Godot 4.7.2 release with
zero engine/script errors. The 12-v-12 bridge fixture used three transports per side:
Aegis/Vigil/Aegis versus Bulwark/Interceptor/Bulwark. Enlarged fleet body corners agree
with equivalent static road footprints, collision cache agrees with placement,
vehicles do not overlap, and all 12 attacking units have a disembark route. Native
GUI input verified class/all/card selection, selected-emblem ownership/clearing,
emblem toggle, pause/speeds, Clear Orders, camera movement and projected ground orders.
All 12 friendly cards fit; 24 actors rendered. Evidence: `tools/tactical_controls/native.json`,
`native.log`, `hud_revision_full_force.png` and `hud_revision_orders.png`.
The earlier 63 core checks were not rerun; this pass did not change order authority.
No new performance benchmark campaign was run.

## 2026-09-13 — Aligned faction and strength header (IMPLEMENTED / VISUALLY CHECKED)

Source: Brandon liked the revised HUD and requested the faction emblem/name and
relative strength to fill the upper-right space after the Sniper selector as two
aligned fields, with a thin white divider. Faction emblem grows from 26 to 38;
name uses larger wrapping type. Strength label grows and its thicker meter sits
lower. Both fields use the available header height without overlapping cards or
class selectors. This changes layout only. Native screenshot reviewed at 1440×1000 in official Godot 4.7.2 release with
zero script/engine errors: `tools/tactical_controls/hud_header.png` and
`header_preview.log`. No combat/performance suite rerun for this layout change.
Next: owner review before Whittaker Estate.

## 2026-09-13 ? Owner-approved asymmetric order completion (DESIGN APPROVED; NOT IMPLEMENTED)

Source: Brandon's follow-up to the tactical command discussion. Fall Back becomes
Holding per recipient after reaching a suitable position on the friendly/near side
of the chosen line. Push ends after each unit completes a meaningful role-appropriate
advance: close-range units seek suitable cover nearer the forward line, while snipers
advance to an appropriate position farther behind it. Completed Push releases that
unit to normal combat AI and removes its Pushing status. Completion is individual;
there is no requirement to wait for every selected unit. This supersedes the assistant
proposal that both movement commands should become Holding. Hold itself remains the
approved next-design correction: seek useful directional cover rather than freeze
exposed in place. These are design decisions, not claims of implemented behavior.

Implication discussed: after Push completes, normal AI can advance beyond the former
line when appropriate; the Push line constrains that active movement order, not all
future autonomous movement. A sniper already behind the line must not immediately
complete without the requested meaningful advance where a viable advance exists.
Recording remains paused during this discussion. Next: finish command design agreement
before implementing the revision or staging the requested battle recording.


## 2026-09-14 — Cover-aware line commands (IMPLEMENTED / VALIDATED)

Source: Brandon approved starting after the asymmetric completion discussion and
explicitly put the scripted recording on hold. This section supersedes the earlier
DESIGN APPROVED / NOT IMPLEMENTED snapshot and the original point-group command rules.

- Hold keeps useful occupied cover or reserves a nearby reachable protective slot.
  Candidate direction uses the existing relevant-threat/cover evaluator; this is
  protection against a relevant threat, not a promise of safety from every firing angle.
- Push/Fall Back enter a placement mode: move the pointer horizontally over the map,
  then left-click to commit. Wheel remains camera zoom; right-click/Escape cancel.
  Lines are green/red, 8 screen-space pixels before viewport stretch, 45% opacity,
  segmented around impassable ground/vehicle bodies. Commit briefly brightens to
  60%, then fades within 0.55 seconds, including while tactical time is paused.
- Advance direction comes from stable friendly/enemy deployment geometry. Active
  Push paths cannot cross the line. Role goals advance shotgun/SMG farther than
  rifles/snipers, with at least a meaningful forward step where viable. On arrival
  at the chosen final cover, only that recipient returns to ordinary role AI;
  the former line no longer restricts subsequent autonomous movement.
- Fall Back seeks cover on the friendly side, avoids forward path excursions, and
  converts to Holding on arrival. Holding retains that boundary when replanning.
  Long movements stage through useful intermediate cover when available, with a
  short firing interval before the next leg. Existing aiming, firing, reload,
  occupancy, navigation and wounded-survival systems remain authoritative.
- Individual move/cover replacement removes that recipient from the group order.
  Clear Orders, wounds and death release ownership. Independent target priority
  can coexist. Labels derive from live per-unit ownership; old badges are replaced.
- Hold briefly pulses a small gray ground ring at accepted recipients. A procedural
  mechanical click/two-note radio receipt plays once per group, with distinct
  order/failure tones, respecting Audio mute and tactical pause. No spoken faction
  voice recordings were added. Tone/visual feel remains subject to owner review.
- An impossible advance or unavailable protective cover reports failed recipients
  and does not issue them a new order. Existing safe orders remain. An interrupted
  route with no safe replacement reports waiting and retries instead of silently
  restoring aggressive AI. Cover search is bounded (14-unit local Hold radius,
  16-unit intermediate hops, at most 12 candidate path searches per decision).
  Live protective-position re-evaluation is throttled to 1.25 seconds.

Validation: official Godot 4.7.2 release, Windows D3D12 Forward+, 1440×1000 bridge,
12-v-12, Aegis/Vigil/Aegis versus Bulwark/Interceptor/Bulwark. **125 command checks
and 43 native UI checks passed**, zero final script/engine errors. This includes
real runtime Push travel/completion and Fall Back travel/transition without position
teleporting (weapons held on cooldown to isolate movement), plus pause, cover ownership,
mirrored direction, individual completion/release, native mouse placement/cancel,
labels, transient feedback, audible-player activity during pause and all 12 cards.

Initial verification caught own occupied cover being rejected by reserve_slot;
assignment now occupies an already-reached slot directly. A native retreat chosen
behind all available start cover correctly failed; the corrected valid placement
passed, and actual retreat travel is covered by the runtime check. Preview capture
was initially off camera; final capture is framed and line contrast was increased.

Evidence and reproduction: [line-command checks](../tools/tactical_controls/README.md).
No new broad performance campaign, all-map exhaustive test, mobile-touch test or
whole-core regression suite was run. Owner acceptance is pending. Immediate next:
Brandon playtests Hold, Push and Fall Back; refine requested behavior/feel. Scripted
recording, Whittaker Estate and dedicated performance work remain deferred.


## 2026-09-14 — Owner path-overlay correction
Persistent selected-unit movement routes and target connection lines are hidden.
Selection still uses the glowing emblem and yellow ring. Brief Push/Fall Back
placement lines and Hold acknowledgements remain. This supersedes earlier route-line
presentation rules; command behavior is preserved.
