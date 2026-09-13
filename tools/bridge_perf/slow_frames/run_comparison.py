from pathlib import Path
import json, subprocess, sys

# Reuse the verified release assets created by headroom/build_release_package.py.
r = Path(__file__).resolve().parents[3]
out = Path(__file__).resolve().parent
if len(sys.argv) != 4:
    raise SystemExit("Usage: python run_comparison.py EDITOR_EXE RELEASE_FOLDER fixed|native|checks|pack")
editor, base, mode = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
if mode not in ("fixed", "native", "checks", "pack"):
    raise SystemExit("Unknown mode")
stage = base / "slow_frames"
stage.mkdir(exist_ok=True)
rel = "battle/combat/battle_target_selection_service.gd"
reference = subprocess.check_output(["git", "show", "16405fbb057e8390fa0c0e864e879e461494232e:" + rel], cwd=r).decode("utf-8")
(stage / "target_before.gd").write_bytes(reference.encode())
(stage / "target_oracle.gd").write_bytes("\n".join(x for x in reference.splitlines() if not x.startswith("class_name ")).encode() + b"\n")
runtime = (r / "battle/runtime/battle_runtime_service.gd").read_text(encoding="utf-8")
runtime = "\n".join(x for x in runtime.splitlines() if not x.startswith("class_name "))
runtime = runtime.replace("res://" + rel, "res://tools/bridge_perf/slow_frames/target_oracle.gd")
(stage / "runtime_oracle.gd").write_bytes(runtime.encode() + b"\n")
files = {row["path"]: row["source"] for row in json.loads((base / "package/launcher_manifest.json").read_text(encoding="utf-8"))}
for name in ("native_fixed", "target_exact_replay"):
    source = (out / (name + ".gd")).read_text(encoding="utf-8")
    source = source.replace("C:/Users/brand/OneDrive/Documents/dead-street/tools/bridge_perf/slow_frames", out.as_posix())
    p = stage / (name + ".gd")
    p.write_bytes(source.encode())
    files["tools/bridge_perf/headroom/" + name + ".gd"] = str(p)
for name in ("target_oracle", "runtime_oracle"):
    files["tools/bridge_perf/slow_frames/" + name + ".gd"] = str(stage / (name + ".gd"))
boot = 'extends Node\nfunc _ready():\n if not ProjectSettings.load_resource_pack(' + json.dumps((base / "benchmark_data.pck").as_posix()) + ',false):get_tree().quit(5);return\n var mode="native"\n for arg in OS.get_cmdline_user_args():\n  if arg.begins_with("--check="):mode=arg.trim_prefix("--check=")\n var tree=get_tree()\n tree.set_script(load("res://tools/bridge_perf/headroom/"+mode+".gd"))\n tree.call_deferred("_initialize")\n queue_free()\n'
(stage / "clean_boot.gd").write_bytes(boot.encode())
files["tools/bridge_perf/headroom/release_boot.gd"] = str(stage / "clean_boot.gd")
manifest = stage / "clean_manifest.json"
probe = r / "tools/bridge_perf/headroom/build_probe.gd"
probe.write_bytes(('extends SceneTree\nfunc _initialize():\n var p=PCKPacker.new()\n if p.pck_start(' + json.dumps((base / "godot.pck").as_posix()) + ')!=OK:quit(2);return\n for row in JSON.parse_string(FileAccess.get_file_as_string(' + json.dumps(manifest.as_posix()) + ')):\n  if p.add_file("res://"+row.path,row.source)!=OK:quit(3);return\n if p.flush()!=OK:quit(4);return\n quit()\n').encode())

def run(cmd, label):
    result = subprocess.run(cmd, cwd=r, capture_output=True, timeout=180)
    log = (result.stdout + result.stderr).decode("utf-8", errors="replace")
    (out / (label + ".log")).write_bytes(("\n".join(x.rstrip() for x in log.splitlines()).rstrip() + "\n").encode())
    errors = [x for x in log.splitlines() if "SCRIPT ERROR" in x or x.startswith("ERROR:") or "REPLAY_FAIL" in x]
    print(label, "exit", result.returncode, "errors", len(errors), flush=True)
    if result.returncode or errors:
        raise RuntimeError(log[-5000:])

def pack(source):
    files[rel] = str(source)
    manifest.write_bytes(json.dumps([dict(path=k, source=v) for k, v in files.items()]).encode())
    run([str(editor), "--headless", "--path", str(r), "--script", "res://tools/bridge_perf/headroom/build_probe.gd"], "pack_clean")

pack(r / rel)
if mode == "checks":
    for check in ("focused", "target_exact_replay"):
        run([str(base / "godot.exe"), "--headless", "--", "--check=" + check], check)
elif mode in ("fixed", "native"):
    results = []
    try:
        for version, source in (("after", r / rel), ("before", stage / "target_before.gd")):
            pack(source)
            label = mode + "32_" + version
            report = (out if mode == "fixed" else base / "results") / (label + ".json")
            report.unlink(missing_ok=True)
            run([str(base / "godot.exe"), "--", "--check=" + ("native_fixed" if mode == "fixed" else "native"), "--side=16", "--duration=30", "--label=" + label, "--uncapped"], label)
            value = json.loads(report.read_text(encoding="utf-8"))
            if value["sim_seconds"] < 29 or value["damage"] <= 0 or value["rendered"] != 32:
                raise RuntimeError("Battle failed validity gate")
            (out / report.name).write_bytes((json.dumps(value, indent=2) + "\n").encode())
            results.append(value)
            print(label, value["fps"], value["p95_frame_ms"], flush=True)
        if mode == "fixed" and results[0]["final_state"] != results[1]["final_state"]:
            raise RuntimeError("Fixed rendered battle state differs")
    finally:
        pack(r / rel)
