from pathlib import Path
import json, subprocess, sys

r = Path(__file__).resolve().parents[3]
out = Path(__file__).resolve().parent
if len(sys.argv) != 4 or sys.argv[3] not in ("checks", "native", "pack"):
    raise SystemExit("Usage: python run.py EDITOR_EXE RELEASE_FOLDER checks|native|pack")
editor, base, mode = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
stage = base / "cover_close"
stage.mkdir(exist_ok=True)
files = {x["path"]: x["source"] for x in json.loads((base / "package/launcher_manifest.json").read_text(encoding="utf-8"))}
for rel in ("battle/combat/battle_combat_behavior_service.gd", "battle/combat/battle_combat_cover_evaluation_service.gd", "battle/combat/battle_target_selection_service.gd"):
    files[rel] = str(r / rel)
for name in ("behavior_oracle", "runtime_oracle", "predicate", "replay"):
    text = (out / (name + ".gd")).read_text(encoding="utf-8")
    text = text.replace("C:/Users/brand/OneDrive/Documents/dead-street/tools/bridge_perf/cover_close", out.as_posix())
    p = stage / (name + ".gd")
    p.write_bytes(text.encode())
    key = "tools/bridge_perf/headroom/cover_" + name if name in ("predicate", "replay") else "tools/bridge_perf/cover_close/" + name
    files[key + ".gd"] = str(p)
text = (r / "tools/bridge_perf/headroom/native.gd").read_text(encoding="utf-8")
text = text.replace('"res://tools/bridge_perf/headroom/"+label+".json"', json.dumps(out.as_posix() + "/") + '+label+".json"')
(stage / "native.gd").write_bytes(text.encode())
files["tools/bridge_perf/headroom/native.gd"] = str(stage / "native.gd")
boot = 'extends Node\nfunc _ready():\n if not ProjectSettings.load_resource_pack(' + json.dumps((base / "benchmark_data.pck").as_posix()) + ',false):get_tree().quit(5);return\n var mode="native"\n for arg in OS.get_cmdline_user_args():\n  if arg.begins_with("--check="):mode=arg.trim_prefix("--check=")\n var tree=get_tree()\n tree.set_script(load("res://tools/bridge_perf/headroom/"+mode+".gd"))\n tree.call_deferred("_initialize")\n queue_free()\n'
(stage / "boot.gd").write_bytes(boot.encode())
files["tools/bridge_perf/headroom/release_boot.gd"] = str(stage / "boot.gd")
manifest = stage / "manifest.json"
manifest.write_bytes(json.dumps([dict(path=k, source=v) for k, v in files.items()]).encode())
probe = r / "tools/bridge_perf/headroom/build_probe.gd"
probe.write_bytes(('extends SceneTree\nfunc _initialize():\n var p=PCKPacker.new()\n if p.pck_start(' + json.dumps((base / "godot.pck").as_posix()) + ')!=OK:quit(2);return\n for row in JSON.parse_string(FileAccess.get_file_as_string(' + json.dumps(manifest.as_posix()) + ')):\n  if p.add_file("res://"+row.path,row.source)!=OK:quit(3);return\n if p.flush()!=OK:quit(4);return\n quit()\n').encode())

def run(cmd, label):
    z = subprocess.run(cmd, cwd=r, capture_output=True, timeout=180)
    log = (z.stdout + z.stderr).decode("utf-8", errors="replace")
    (out / (label + ".log")).write_bytes(("\n".join(x.rstrip() for x in log.splitlines()).rstrip() + "\n").encode())
    errors = [x for x in log.splitlines() if "SCRIPT ERROR" in x or x.startswith("ERROR:") or "REPLAY_FAIL" in x]
    print(label, z.returncode, len(errors), flush=True)
    if z.returncode or errors:
        raise RuntimeError(log[-5000:])

run([str(editor), "--headless", "--path", str(r), "--script", "res://tools/bridge_perf/headroom/build_probe.gd"], "pack")
if mode == "checks":
    for name in ("predicate", "replay"):
        (out / (name + ".json")).unlink(missing_ok=True)
        run([str(base / "godot.exe"), "--headless", "--", "--check=cover_" + name], name)
        value = json.loads((out / (name + ".json")).read_text(encoding="utf-8"))
        if value["errors"] or value["checks"] <= 0:
            raise RuntimeError("Validation failed")
elif mode == "native":
    path = out / "cover24_normal.json"
    path.unlink(missing_ok=True)
    run([str(base / "godot.exe"), "--", "--check=native", "--side=12", "--duration=30", "--label=cover24_normal"], "cover24_normal")
    value = json.loads(path.read_text(encoding="utf-8"))
    if value["rendered"] != 24 or value["sim_seconds"] < 29 or value["damage"] <= 0:
        raise RuntimeError("Native validity gate failed")
    print(value["fps"], value["p95_frame_ms"])
