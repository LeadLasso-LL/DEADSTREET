# Bridge performance diagnostics

Latest: [runtime cleanup](RUNTIME_CLEANUP_2026-09-13.md), including the corrected engine-error gate and 42.34 FPS result.

See [PERFORMANCE_2026-09-13.md](PERFORMANCE_2026-09-13.md) for changes, native measurements, regression coverage, and remaining limitations.

- `validate.gd`: headless movement, sight-line, cache and defender behavior checks.
- `benchmark.gd`: matched 16/24-unit native benchmark, 600 updates at 0.05 seconds.
- `live.gd`: 24-unit normal playable update loop, followed by a simulation-only pause.
- JSON reports and logs preserve measurements. Older diagnostic copies are not production runtime dependencies.

These tools do not define the final convoy or unit cap.

Run current checks with Python: run_checked.py --godot <Godot-console-executable>. Use --script res://tools/bridge_perf/next_pass/replay.gd for deterministic replay. Native timing: add --native and --script res://tools/bridge_perf/benchmark.gd --side=12 --label=next_pass/verification24; use --script res://tools/bridge_perf/next_pass/live_victory.gd for the normal playable fixture.
