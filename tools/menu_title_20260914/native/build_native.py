"""Package the accepted opening and current sandbox into a separate native runtime."""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys,time,re
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/menu_title_20260914/native'
base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
stage=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\sandbox_opening_20260914')
editor=Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe')
mode=sys.argv[1] if len(sys.argv)>1 else 'smoke'
assert mode in ('smoke','record','package')
stage.mkdir(exist_ok=True);snapshot=stage/'source_snapshot';snapshot.mkdir(exist_ok=True)
files={x['path']:x['source'] for x in json.loads((base/'package/launcher_manifest.json').read_text())}
hashes={}
for folder in ('battle','campaign','core','gameplay'):
 for path in (repo/folder).rglob('*'):
  if path.suffix not in ('.gd','.tscn'):continue
  relative=path.relative_to(repo).as_posix();dest=snapshot/relative
  if not dest.exists() or relative in ('gameplay/sandbox_opening.gd','gameplay/sandbox_opening.tscn','gameplay/sandbox_menu_music.gd'):
   dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(path,dest)
  files[relative]=str(dest);hashes[relative]=hashlib.sha256(dest.read_bytes()).hexdigest()
for path in (repo/'assets/audio/convoy').glob('*.wav'):
 if path.stem!='trc_horn':files[path.relative_to(repo).as_posix()]=str(path)
for path in (repo/'assets/art/whittaker_estate').rglob('*.png'):files[path.relative_to(repo).as_posix()]=str(path)
files={k:v for k,v in files.items() if not k.startswith('assets/audio/factions/') and k!='gameplay/tactical_faction_voices.gd'}
for path in (repo/'assets/art').rglob('*portraits.png'):
 files[path.relative_to(repo).as_posix()]=str(path);imp=Path(str(path)+'.import')
 if imp.exists():
  files[imp.relative_to(repo).as_posix()]=str(imp)
  for target in re.findall(r'path="res://([^"]+)"',imp.read_text()):
   if (repo/target).exists():files[target]=str(repo/target)
for folder in ('assets/tutorial','assets/menu/opening'):
 for path in (repo/folder).rglob('*'):
  if path.is_file() and path.suffix in ('.png','.json','.ogv','.mp3'):files[path.relative_to(repo).as_posix()]=str(path)
files['tools/menu_title_20260914/native/validate.gd']=str(out/'validate.gd')
boot='''extends Node
func _ready():
 if not ProjectSettings.load_resource_pack(DATA_PACK,false):get_tree().quit(5);return
 if "--opening-check" in OS.get_cmdline_user_args():
  var tree=get_tree();tree.set_script(load("res://tools/menu_title_20260914/native/validate.gd"));tree.call_deferred("_initialize")
 else:
  get_tree().root.add_child(load("res://gameplay/sandbox_opening.tscn").instantiate())
 queue_free()
'''.replace('DATA_PACK',json.dumps((base/'benchmark_data.pck').as_posix()))
(stage/'boot.gd').write_text(boot);files['tools/bridge_perf/headroom/release_boot.gd']=str(stage/'boot.gd')
(stage/'override.cfg').write_text('[display]\nwindow/size/viewport_width=1280\nwindow/size/viewport_height=720\nwindow/size/window_width_override=1280\nwindow/size/window_height_override=720\nwindow/stretch/mode="disabled"\n[application]\nconfig/name="Dead Street - Battle Sandbox"\n')
files['override.cfg']=str(stage/'override.cfg')
manifest=stage/'manifest.json';manifest.write_text(json.dumps([dict(path=k,source=v) for k,v in files.items()]))
builder='''extends SceneTree
func _initialize():
 var p=PCKPacker.new()
 if p.pck_start(PACK)!=OK:quit(2);return
 for row in JSON.parse_string(FileAccess.get_file_as_string(MANIFEST)):
  if p.add_file("res://"+row.path,row.source)!=OK:quit(3);return
 if p.flush()!=OK:quit(4);return
 quit()
'''.replace('PACK',json.dumps((stage/'godot.pck').as_posix())).replace('MANIFEST',json.dumps(manifest.as_posix()))
(stage/'build_pack.gd').write_text(builder);(stage/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Opening packaging"\n')
r=subprocess.run([str(editor),'--headless','--path',str(stage),'--script',str(stage/'build_pack.gd')],capture_output=True,timeout=90)
(out/'pack.log').write_bytes(r.stdout+r.stderr);assert r.returncode==0,(r.stdout+r.stderr)[-6000:]
shutil.copy2(base/'godot.exe',stage/'godot.exe')
for dll in base.glob('*.dll'):shutil.copy2(dll,stage/dll.name)
(out/'source_hashes.json').write_text(json.dumps(hashes,indent=2))
(out/'snapshot.json').write_text(json.dumps({'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'source_snapshot':str(snapshot),'runtime':str(stage/'godot.exe'),'pack_sha256':hashlib.sha256((stage/'godot.pck').read_bytes()).hexdigest(),'shared_runtime_modified':False},indent=2))
print('NATIVE_PACKAGE_READY',mode,flush=True)
if mode=='package':sys.exit(0)
args=[str(stage/'godot.exe'),'--resolution','1280x720','--position','10,10','--disable-vsync']
if mode=='record':args+=['--write-movie',str(out/'opening_native_raw.avi'),'--fixed-fps','30']
args+=['--','--opening-check']
if mode=='record':args+=['--record']
with (out/(mode+'.log')).open('wb') as log:
 p=subprocess.Popen(args,cwd=stage,stdout=log,stderr=subprocess.STDOUT);print('NATIVE_CHECK_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  content=(out/(mode+'.log')).read_text(errors='replace')
  if 'SCRIPT ERROR' in content or time.monotonic()-start>400:
   p.kill();p.wait();raise RuntimeError(content[-6000:])
assert p.returncode==0,p.returncode
print('NATIVE_CHECK_COMPLETE',mode,flush=True)
