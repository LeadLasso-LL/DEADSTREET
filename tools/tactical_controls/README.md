# Tactical controls validation

## Current line-command revision — 2026-09-14

Approved rules: [Tactical controls](../../docs/TACTICAL_CONTROLS_2026-09-13.md).
Run from the repository on the development PC:

```powershell
& 'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe' tools/tactical_controls/run.py pack
& 'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe' --headless -- --check=line_checks
& 'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe' -- --check=line_native
```

- `line_checks.gd/json/log`: 125 checks, zero errors; protective Hold, exclusive cover,
  mirrored direction, Push role progress/bounds, individual completion/interruption,
  Fall Back to Holding, pause and real runtime navigation through both movement orders.
  Travel-only fixture holds weapons on cooldown; other checks cover normal runtime.
- `line_native.gd/json/log`: 43 checks, zero errors; actual arsenal scene and viewport
  input, placement/commit/Escape, pause, live card labels, line/pulse expiry, order
  AudioStreamPlayer active during pause, all 12 friendly cards visible, simulation resume.
- `line_push_preview.png`, `line_fall_back_preview.png`, `line_command_cards.png`,
  `line_commands_live.png`: native captures at 1440×1000, official 4.7.2 release.

Bridge fixture: 12-v-12, Aegis/Vigil/Aegis versus Bulwark/Interceptor/Bulwark;
Windows D3D12 Forward+, GTX 1650 Max-Q. No all-map/mobile-touch, broad core-regression
or further performance acceptance campaign. Owner feel/visual/audio acceptance pending.
Existing historical checks below contain superseded fixed-position group semantics;
use the line-command checks above for the current command revision.

## Historical HUD/fleet validation

Approved design: [Tactical controls](../../docs/TACTICAL_CONTROLS_2026-09-13.md).

Run on the development PC from the repository:

```powershell
& 'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe' tools/tactical_controls/run.py checks
& 'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe' tools/tactical_controls/run.py native
```

The runner overlays current production source on the existing imported asset
package, then runs official Godot 4.7.2 release. It rebuilds the small adjacent
launcher pack used by the performance tools. It does not re-export the large
asset pack, alter production frame-rate settings, or change force limits.

- `checks.json`: 63 explicit checks, zero errors. Pause/RNG/weapon/position freeze,
  playback rates, selections, class shortcuts, ownership replacement and release,
  target/position coexistence, non-chasing Hold, wound/death roster/badges, and
  exclusive group cover slots.
- `native.json`: 146 checks, zero errors. Production arsenal scene, 24 rendered
  units, all 12 friendly cards visible at 1440×1000; GUI selection, pause and rates,
  camera panning while paused, Clear Orders and projected ground-click routing.
  Revised checks cover emblem selection/toggling, equivalent fleet/road footprints,
  cached collision profiles, convoy nonoverlap and all attacker disembark routes.
- `hud_revision_full_force.png`, `hud_revision_orders.png`: current native HUD captures.
  The earlier `hud_paused_full_force.png` and `hud_orders.png` retain the first HUD pass.
- `checks.log`, `native.log`, `pack.log`: final clean error gates.

The native fixture injects viewport-local mouse events through `Viewport.push_input`
so project/window stretch does not transform widget coordinates a second time.
An earlier OS-level synthetic-input trial missed the controls; no UI acceptance
was claimed from it. A Button property name collision found during initial
loading was corrected before both clean final gates.

Initial native five-second commanded smoke: 59.91 FPS. This is a responsiveness check,
not a sustained performance acceptance or a comparison to earlier battle workloads.
No broad actor/core suite or further 32-unit optimization campaign was run.

Source scope at the initial pass: the working repository contained unrelated participant/view hunks
and other unfinished work. Native validation uses that actual working source;
this checkpoint stages only this pass's participant/view hunks and its other
owned files. Source changes preserve existing wounded survival behavior.

Next: owner review of the HUD and control feel. Whittaker Estate remains deferred.
