# Flexible faction battle setup

Open the Battle Sandbox and choose **CUSTOM BATTLE SETUP**.

- Choose one faction for each side. Its entire force uses that faction’s existing class outfits and full animation bindings.
- Add, duplicate or remove individual pistol, SMG, shotgun, rifle and sniper units. Balanced Five resets only that side’s composition.
- Each unit has its own weapon, unit tier and armor. Weapons can be any model in the unit’s class; faction guide pairings impose no restrictions.
- All 23 factions, 30 weapons, tiers 1–3, three armor items and 75 vehicles remain unlocked. Unit tiers retain the existing training rules and gold HUD stars; armor retains its HP-only 15/30/50% modifier and blue/silver HUD circles. Outfits never change from armor selection.
- Harold Avenue supports 1–12 units per side, including uneven forces. This is a sandbox/map limit, not a campaign recruitment limit.
- Choose the attacking convoy manually or use Auto-Fit Seats to assign enough Bayou sedans. Each vehicle uses one of the selected attackers as its driver. Defenders are an on-foot HQ garrison.
- The Start button explains invalid forces or insufficient seats/drivers. Launch also checks actual vehicle placement against the existing map.
- The battle HUD pages through five cards at a time, including casualties. World selection reveals the corresponding page. Page changes immediately refresh card IDs. The operative counter covers the whole force.
- Results scroll independently for each side and include every participant. Continue or Escape returns to the retained setup. Settings persist for this running sandbox session, not across app restarts.

## Implementation boundaries

`gameplay/sandbox_force_config.gd` owns the validated sandbox configuration; `sandbox_force_builder.gd` edits it. `arsenal_battle_fixture.gd` builds the chosen soldiers and convoy through existing campaign deployment, mission entry and battle services using a fresh sandbox world. Native battles use normal real-time combat, AI, cover, weapon and animation systems.

The legacy quick 5v5 armory and Encounter Lab fixtures are retained. Encounter Lab is accessible from the main fleet browser; it is omitted from the custom convoy picker to keep its scenarios separate. The existing Mercer dual-pistol specialist can carry through a compatible legacy setup. This milestone adds regular-unit composition, not a new specialist roster.

Campaign saves/economy/outcomes, new maps, helicopter/ship systems and two-wheeler riding/dismount animation are outside this change. Two-wheelers retain the accepted parked arrival behavior. A seat-valid oversized convoy may still fail map placement with an explicit error.

## Reproduction

Run with the installed Godot executable and project root:

```text
--headless --script tools/sandbox_setup/compile.gd
--headless --script tools/sandbox_setup/validate.gd
--headless --script tools/vehicle_fleet/validate_panel.gd
--headless --script tools/vehicle_fleet/validate_blockades.gd
--script tools/sandbox_setup/review.gd
```

Reports and native captures are written to `tools/sandbox_setup/results/`. Rules validation covers all faction choices, malformed configurations, class restrictions, independent equipment, armor HP, exact participant counts, crew/seats, 1v1, 7v3, 3v9 and 12v12, a full heavy transport and six motorcycles. Native review exercises the actual controls, 7v3 and 12v12 combat, HUD paging/selection, retained settings and 24 result cards. The native results check uses a clearly marked test-only terminal state after ordinary live combat; it is not evidence of a naturally completed battle.
