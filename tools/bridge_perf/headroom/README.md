# Bridge performance and capacity checks

Baseline: 613bbabb4d7d642bdaeb008e4ad272530ff53fd5. Native measurements use
the ordinary bridge scene, actual battle services and all selected actor sprites.
Godot 4.7.2 development executable; 1440 x 1000; D3D12 Forward+; GTX 1650 Max-Q.
A release executable was not tested.

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
