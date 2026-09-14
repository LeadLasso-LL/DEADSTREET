"""Isolated native UI review. Never repacks or writes the shared release runtime."""
from pathlib import Path
import hashlib, json, shutil, subprocess, sys, time

repo = Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out = repo / 'tools/sandbox_tutorial_20260914'
base = Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
stage = Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\sandbox_tutorial_20260914')
editor = Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe')
mode = sys.argv[1] if len(sys.argv) > 1 else 'capture'
assert mode in ('smoke', 'record', 'capture')
stage.mkdir(parents=True, exist_ok=True)
snapshot = stage / 'source_snapshot_v2'
snapshot.mkdir(exist_ok=True)
files = {x['path']: x['source'] for x in json.loads((base/'package/launcher_manifest.json').read_text())}
hashes = {}
for folder in ('battle','campaign','core','gameplay'):
    for path in (repo/folder).rglob('*'):
        if path.suffix not in ('.gd','.tscn'): continue
        relative = path.relative_to(repo).as_posix()
        dest = snapshot/relative
        # One frozen production snapshot, shared by smoke and final capture.
        if not dest.exists() or relative in ('gameplay/arsenal_review.gd','gameplay/sandbox_tutorial_panel.gd'):
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path,dest)
        files[relative] = str(dest)
        hashes[relative] = hashlib.sha256(dest.read_bytes()).hexdigest()
for path in (repo/'assets/audio/convoy').glob('*.wav'):
    if path.stem != 'trc_horn': files[path.relative_to(repo).as_posix()] = str(path)
for path in (repo/'assets/art/whittaker_estate').rglob('*.png'):
    files[path.relative_to(repo).as_posix()] = str(path)
files = {k:v for k,v in files.items() if not k.startswith('assets/audio/factions/') and k!='gameplay/tactical_faction_voices.gd'}
for path in (repo/'assets/art').rglob('*portraits.png'):
    files[path.relative_to(repo).as_posix()] = str(path)
    imp=Path(str(path)+'.import')
    if imp.exists():
        files[imp.relative_to(repo).as_posix()]=str(imp)
        import re
        for target in re.findall(r'path="res://([^"]+)"',imp.read_text()):
            if (repo/target).exists(): files[target]=str(repo/target)
for path in (repo/'assets/tutorial').rglob('*'):
    if path.is_file() and path.suffix in ('.png','.json'): files[path.relative_to(repo).as_posix()]=str(path)
script_name = 'capture.gd' if mode=='capture' else 'validate.gd'
files['tools/sandbox_tutorial_20260914/'+script_name] = str(out/script_name)
boot = '''extends Node
func _ready():
 if not ProjectSettings.load_resource_pack(DATA_PACK,false):get_tree().quit(5);return
 var tree=get_tree()
 tree.set_script(load("res://tools/sandbox_tutorial_20260914/SCRIPT_NAME"))
 tree.call_deferred("_initialize")
 queue_free()
'''.replace('SCRIPT_NAME',script_name).replace('DATA_PACK',json.dumps((base/'benchmark_data.pck').as_posix()))
(stage/'boot.gd').write_text(boot)
files['tools/bridge_perf/headroom/release_boot.gd'] = str(stage/'boot.gd')
(stage/'override.cfg').write_text('[display]\nwindow/size/viewport_width=1440\nwindow/size/viewport_height=1000\nwindow/size/window_width_override=1440\nwindow/size/window_height_override=1000\nwindow/stretch/mode="disabled"\n')
files['override.cfg'] = str(stage/'override.cfg')
manifest = stage/'manifest.json'
manifest.write_text(json.dumps([dict(path=k,source=v) for k,v in files.items()]))
pack = stage/'godot.pck'
builder = '''extends SceneTree
func _initialize():
 var p=PCKPacker.new()
 if p.pck_start(PACK)!=OK:quit(2);return
 for row in JSON.parse_string(FileAccess.get_file_as_string(MANIFEST)):
  if p.add_file("res://"+row.path,row.source)!=OK:quit(3);return
 if p.flush()!=OK:quit(4);return
 quit()
'''.replace('PACK',json.dumps(pack.as_posix())).replace('MANIFEST',json.dumps(manifest.as_posix()))
(stage/'build_pack.gd').write_text(builder)
(stage/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Dead Street isolated UI packaging"\n')
result = subprocess.run([str(editor),'--headless','--path',str(stage),'--script',str(stage/'build_pack.gd')],capture_output=True,timeout=90)
(out/'pack.log').write_bytes(result.stdout+result.stderr)
assert result.returncode==0,(result.stdout+result.stderr)[-6000:]
(out/'source_hashes.json').write_text(json.dumps(hashes,indent=2))
(out/'snapshot.json').write_text(json.dumps({'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'frozen_source_root':str(snapshot),'pack':str(pack),'mode':mode,'production_source_edits':False,'shared_runtime_modified':False},indent=2))
shutil.copy2(base/'godot.exe',stage/'godot.exe')
for dll in base.glob('*.dll'): shutil.copy2(dll,stage/dll.name)
args=[str(stage/'godot.exe'),'--resolution','1440x1000','--position','10,10','--fixed-fps','30','--disable-vsync']
if mode=='record':
    raw=out/'tutorial_raw.avi'
    assert not raw.exists(),'Capture already exists; preserve it before another take.'
    args+=['--write-movie',str(raw)]
args+=['--']
if mode=='smoke': args+=['--fast']
with (out/(mode+'.log')).open('wb') as log:
    process=subprocess.Popen(args,cwd=stage,stdout=log,stderr=subprocess.STDOUT)
    print('UI_CAPTURE_PID',process.pid,'MODE',mode,flush=True)
    start=time.monotonic()
    while process.poll() is None:
        try:process.wait(timeout=1)
        except subprocess.TimeoutExpired:pass
        data=(out/(mode+'.log')).read_text(errors='replace')
        if 'SCRIPT ERROR' in data or time.monotonic()-start>780:
            process.kill();process.wait()
            raise RuntimeError(data[-9000:])
assert process.returncode==0,process.returncode
print('TUTORIAL_RUN_COMPLETE',mode,flush=True)
