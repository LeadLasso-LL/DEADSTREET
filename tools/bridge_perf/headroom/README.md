# Bridge performance and capacity checks

Baseline: 613bbabb4d7d642bdaeb008e4ad272530ff53fd5. Native measurements use
the ordinary bridge scene, actual battle services and all selected actor sprites.
Godot 4.7.2 development executable; 1440 x 1000; D3D12 Forward+; GTX 1650 Max-Q.
The approved matching release runtime has now been tested; see release_results.json.

Run from the repository with the installed Python:

    python tools/bridge_perf/headroom/run_checks.py --godot "C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe"
    python tools/bridge_perf/headroom/run_checks.py --godot "<Godot executable>" --native --side 12 --label native_24
    python tools/bridge_perf/headroom/run_checks.py --godot "<Godot executable>" --native --side 16 --bulwarks --label native_32
    python tools/bridge_perf/headroom/run_checks.py --godot "<Godot executable>" --native --side 12 --bulwarks --label native_24_same_convoy
    python tools/bridge_perf/headroom/run_checks.py --godot "<Godot executable>" --native --side 12 --uncapped --label capacity_24

prepare_oracles.py reconstructs generated reference services and the old actor
presenter from the pinned commit. Git must contain that commit. The normal checker
runs exact geometry/LOS/target/cache checks, a 600-update (.05 s) whole-runtime
replay plus deciding-kill case, and an actor-state comparison. It rejects engine/
script errors even when Godot exits zero. Native tests are separate from profiling.

The larger fixture copies the existing scene/config/fixture and raises only its
test limit to 24 per side. Production still allows 12 per side. Larger fixtures
use three Bulwarks on each side for valid seating. Use --bulwarks at 12 per side
for the matching-convoy comparison; do not interpret the default 24/32 comparison
as a pure unit-count test. No final convoy/personnel cap is approved by these tests.

--uncapped disables VSync and the FPS limit for that test process only.
It measures available throughput; it is not the normal player setting and does
not prove every frame meets 16.67 ms. Each normal run includes 30 s active battle,
five-second windows, actual actor/roster counts, damage and frame percentiles.
Setup/asset preparation and the following paused measurement are outside the
combat FPS window. Setup time is recorded in the later capacity runs.

See results.json for the measured progression and
[the report](../HEADROOM_2026-09-13.md) for conclusions and remaining work.

## Packaged release comparison

The official template has path/script overrides disabled. Use the benchmark
package rather than passing --path or --script to that executable.

The already verified runtime is in:
C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe

With that official executable named godot.exe in RELEASE_RUNTIME_FOLDER:

    python tools/bridge_perf/headroom/build_release_package.py "<Godot development executable>" "<RELEASE_RUNTIME_FOLDER>"
    python tools/bridge_perf/headroom/run_release_comparison.py "<Godot development executable>" "<RELEASE_RUNTIME_FOLDER>"

The first command reconstructs the pinned reference services and builds
benchmark_data.pck from the current working tree/imported assets. The second
builds the small launcher godot.pck, verifies release build identity, then runs
normal/uncapped 24/32 samples, paired development-runtime uncapped controls, and
the three behavior checks. Both runtimes load the same data and launcher packs.

Rebuild the data package whenever production source or assets change. The
comparison command alone refreshes harness/report paths, not the underlying
game data. Preserve the live working tree: release_source_snapshot.json records
inherited runtime edits by diff hash; saved timings are not a clean-checkout
reproduction claim. No production project.godot/export preset is rewritten.
This benchmark package is not a finished shipping build.

The bounded instability check is reproducible after the main comparison:

    python tools/bridge_perf/headroom/repeat_release_capacity.py "<RELEASE_RUNTIME_FOLDER>"

It repeats 32-unit uncapped and normal runs, records AC/battery state, available
NVIDIA telemetry and CPU process snapshots. It does not change power settings
or stop other applications. Windows process CPU counters can exceed 100% across
cores; do not read a single process value as percent of the entire machine.

All commands save normalized logs and fresh JSON evidence in this folder.
Preparation and paused measurements are outside the active combat FPS window.
Use the complete distribution and five-second windows; casualties mean an
overall average alone does not establish full-roster headroom.
