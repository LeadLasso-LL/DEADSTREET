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
- Selected units show routes, destination/cover and priority-target feedback.
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
