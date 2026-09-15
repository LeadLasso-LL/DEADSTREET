"""Bounded checks/native review using the existing official release asset package."""
from pathlib import Path
import json, subprocess, sys

repo = Path(__file__).resolve().parents[2]
out = Path(__file__).resolve().parent
editor = Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe')
base = Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
mode = sys.argv[1] if len(sys.argv) > 1 else 'checks'
if mode not in ('checks', 'native', 'pack'):
    raise SystemExit('Usage: python tools/tactical_controls/run.py checks|native|pack')
stage = base / 'tactical_controls'
stage.mkdir(exist_ok=True)

def run(command, label, timeout=90):
    result = subprocess.run(command, cwd=repo, capture_output=True, timeout=timeout)
    log = (result.stdout + result.stderr).decode('utf-8', errors='replace')
    (out / (label + '.log')).write_bytes(('\n'.join(s.rstrip() for s in log.splitlines()).rstrip()+'\n').encode())
    errors = [s for s in log.splitlines() if 'SCRIPT ERROR' in s or s.startswith('ERROR:') or 'CONTROLS_FAIL' in s]
    print(label, 'exit', result.returncode, 'errors', len(errors), flush=True)
    if result.returncode or errors:
        print(log[-10000:], flush=True)
        raise SystemExit(1)
    print(log[-1800:], flush=True)

files = {x['path']: x['source'] for x in json.loads((base/'package/launcher_manifest.json').read_text(encoding='utf-8'))}
# Overlay actual current production sources, including preserved unrelated hunks;
# this avoids silently testing stale code from the large imported asset package.
for directory in ('battle', 'campaign', 'core', 'gameplay'):
    for p in (repo/directory).rglob('*.gd'):
        files[p.relative_to(repo).as_posix()] = str(p)
# Raw generated ambience is loaded directly; no full asset-package re-export.
for p in (repo/'assets/audio/convoy').glob('*.wav'):
    files[p.relative_to(repo).as_posix()] = str(p)
for p in (repo/"assets/art/whittaker_estate").glob("*.png"):
    files[p.relative_to(repo).as_posix()] = str(p)
for p in out.glob('*.gd'):
    files[p.relative_to(repo).as_posix()] = str(p)
files['tools/sandbox_setup/scenarios.gd'] = str(repo/'tools/sandbox_setup/scenarios.gd')
boot = '''extends Node
func _ready():
 if not ProjectSettings.load_resource_pack(DATA_PACK,false):get_tree().quit(5);return
 var mode="native"
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--check="):mode=arg.trim_prefix("--check=")
 var tree=get_tree()
 tree.set_script(load("res://tools/tactical_controls/"+mode+".gd"))
 tree.call_deferred("_initialize")
 queue_free()
'''.replace('DATA_PACK',json.dumps((base/'benchmark_data.pck').as_posix()))
(stage/'boot.gd').write_bytes(boot.encode())
files['tools/bridge_perf/headroom/release_boot.gd'] = str(stage/'boot.gd')
manifest = stage/'manifest.json'
manifest.write_bytes(json.dumps([dict(path=k,source=v) for k,v in files.items()]).encode())
probe = repo/'tools/bridge_perf/headroom/build_probe.gd'
probe.write_bytes(('''extends SceneTree
func _initialize():
 var p=PCKPacker.new()
 if p.pck_start(PACK_PATH)!=OK:quit(2);return
 for row in JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)):
  if p.add_file("res://"+row.path,row.source)!=OK:quit(3);return
 if p.flush()!=OK:quit(4);return
 quit()
'''.replace('PACK_PATH',json.dumps((base/'godot.pck').as_posix())).replace('MANIFEST_PATH',json.dumps(manifest.as_posix()))).encode())
run([str(editor),'--headless','--path',str(repo),'--script','res://tools/bridge_perf/headroom/build_probe.gd'],'pack')
if mode != 'pack':
    command = [str(base/'godot.exe')]
    if mode == 'checks': command.append('--headless')
    command += ['--','--check='+mode]
    (out/(mode+'.json')).unlink(missing_ok=True)
    run(command,mode)
    result = json.loads((out/(mode+'.json')).read_text(encoding='utf-8'))
    if result['checks'] <= 0 or result['errors']:
        raise SystemExit('Validation failed')
    print('VERIFIED',mode,result['checks'],flush=True)
