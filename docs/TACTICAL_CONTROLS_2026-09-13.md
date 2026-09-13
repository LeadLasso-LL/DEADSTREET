# Tactical HUD and player orders — 2026-09-13

Status: IMPLEMENTED and VALIDATED; owner playtest acceptance pending. Source: Brandon's
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
- Hold fixes current positions. Push/Fall Back ask for a destination and prefer
  usable cover near it. Clear Orders releases explicit movement and target orders
  to normal role behavior. New positioning replaces old positioning. No queue.
- Player-assigned positions persist on arrival until released/replaced or a
  survival interruption. Routine role AI must not silently override them.
- Group card badges: filled red right triangle for Push, filled red left triangle
  for Fall Back, orange filled square for Hold. These are derived from current
  per-unit command ownership. Individual ground/cover orders clear only the
  recipients' badges; clearing, interruption and elimination remove them too.
  A target priority can coexist with a group positioning order and its badge.
- Selected units show routes and priority-target lines; ground selection, destination and target circles are removed.
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

The retained-position behavior is deliberate: Push/Fall Back assign a destination
and retain that assignment on arrival until replaced/released; Hold fixes the
current location. Wounds interrupt explicit commands and use existing survival
behavior. Wounded cards remain selectable for inspection, not forced overrides
of that survival behavior. This is a reviewable first implementation, not owner
acceptance of every interaction.

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
