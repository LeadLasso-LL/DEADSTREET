from pathlib import Path
import os,re,json,subprocess,shutil,hashlib,time
from PIL import Image,ImageChops
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent
stage=o/'stage';stage.mkdir(exist_ok=True);release=o/'candidate';release.mkdir(exist_ok=True)
runtime=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe')
assert hashlib.sha256(runtime.read_bytes()).hexdigest()=='d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562'
shutil.copy2(runtime,release/'DeadStreetSandbox.exe')
art=Image.open(r/'assets/menu/opening/approved_title.png').convert('RGB')
box=art.point(lambda p:255 if p>55 else 0).getbbox()
title=art.crop(box)
for name,size in [('sandbox_icon',512),('cover',1024)]:
 canvas=Image.new('RGB',(size,size),'black');part=title.copy();part.thumbnail((int(size*.91),int(size*.84)),Image.Resampling.LANCZOS)
 canvas.paste(part,((size-part.width)//2,(size-part.height)//2));canvas.save(stage/(name+'.png'))
Image.open(stage/'sandbox_icon.png').save(release/'DeadStreet.ico',sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
shutil.copy2(stage/'cover.png',release/'DeadStreet_Cover.png')
wanted={'.gd','.tscn','.tres','.json','.cfg','.csv','.txt','.import','.gdshader','.gdshaderinc','.res','.bin','.uid'}
media={'.png','.jpg','.jpeg','.webp','.svg','.ogg','.ogv','.wav','.mp3','.ttf','.otf'}
files={}
for folder in ['assets','battle','campaign','core','gameplay','world','validation']:
 for p in (r/folder).rglob('*'):
  if p.is_file() and (p.suffix.lower() in wanted or folder=='assets' and p.suffix.lower() in media):
   files[p.relative_to(r).as_posix()]=str(p)
for rel in ['.godot/global_script_class_cache.cfg','.godot/uid_cache.bin','icon.svg','icon.svg.import']:
 if (r/rel).is_file():files[rel]=str(r/rel)
queue=list(files);seen=set()
while queue:
 rel=queue.pop()
 if rel in seen:continue
 seen.add(rel);p=Path(files[rel])
 if p.suffix.lower() not in {'.gd','.tscn','.tres','.json','.cfg','.import'} or p.stat().st_size>5000000:continue
 for sub in re.findall(r'["\x27]res://([^"\x27\n]+)["\x27]',p.read_text(encoding='utf-8',errors='replace')):
  if (r/sub).is_file() and sub not in files:files[sub]=str(r/sub);queue.append(sub)
files['assets/branding/sandbox_icon.png']=str(stage/'sandbox_icon.png')
files['assets/branding/cover.png']=str(stage/'cover.png')
for name in ['bench.gd','boot.gd','boot.tscn']:files['tools/playtest_release_20260915/'+name]=str(o/name)
manifest=[{'path':k,'source':v} for k,v in sorted(files.items())]
(stage/'manifest.json').write_text(json.dumps(manifest),encoding='utf-8')
hashes={k:hashlib.sha256(Path(v).read_bytes()).hexdigest() for k,v in files.items() if k.split('/')[0] in ['battle','campaign','core','gameplay','world'] or k.startswith('assets/menu/opening/')}
(o/'source_hashes.json').write_text(json.dumps(hashes,indent=2))
print('PACKAGE_INPUTS',len(files),'bytes',sum(Path(v).stat().st_size for v in files.values()),flush=True)
def quote(p):return json.dumps(str(p).replace('\\','/'))
packer='extends SceneTree\nfunc _initialize():\n'
for key,value in {'application/config/name':'Dead Street Sandbox','application/run/main_scene':'res://tools/playtest_release_20260915/boot.tscn','application/config/icon':None,'application/config/use_custom_user_dir':True,'application/config/custom_user_dir_name':'DeadStreetSandbox','display/window/size/viewport_width':1920,'display/window/size/viewport_height':1080,'display/window/size/window_width_override':1600,'display/window/size/window_height_override':900}.items():
 gd='null' if value is None else json.dumps(value)
 packer+=' ProjectSettings.set_setting('+json.dumps(key)+','+gd+')\n'
packer+=' if ProjectSettings.save_custom('+quote(stage/'project.binary')+')!=OK:quit(2);return\n var pack=PCKPacker.new()\n if pack.pck_start('+quote(release/'DeadStreetSandbox.pck')+')!=OK:quit(3);return\n if pack.add_file("res://project.binary",'+quote(stage/'project.binary')+')!=OK:quit(4);return\n var rows=JSON.parse_string(FileAccess.get_file_as_string('+quote(stage/'manifest.json')+'))\n for row in rows:\n  if pack.add_file("res://"+row.path,row.source)!=OK:printerr("PACK_FAILED ",row.path);quit(5);return\n if pack.flush()!=OK:quit(6);return\n FileAccess.open('+quote(release/'Godot_License.txt')+',FileAccess.WRITE).store_string(Engine.get_license_text())\n print("PACKAGE_READY ",rows.size())\n quit()\n'
(o/'pack.gd').write_text(packer,encoding='utf-8')
editor=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (o/'pack.log').open('wb') as log:
 p=subprocess.run([editor,'--headless','--path',str(r),'--script','res://tools/playtest_release_20260915/pack.gd'],stdout=log,stderr=subprocess.STDOUT,timeout=300)
assert p.returncode==0,(o/'pack.log').read_text(errors='replace')[-3000:]
print('PACK_COMPLETE',flush=True)
for map_id in ['harold','river_bridge','whittaker_estate','doble_ocho','freight_exchange']:
 out=o/(map_id+'.json')
 cmd=[str(release/'DeadStreetSandbox.exe'),'--resolution','1920x1080','--fullscreen','--','--benchmark','--map='+map_id,'--out='+str(out)]
 (o/(map_id+'_command.json')).write_text(json.dumps(cmd,indent=2))
 print('BATTLE_BEGIN',map_id,flush=True)
 with (o/(map_id+'.log')).open('wb') as log:p=subprocess.run(cmd,cwd=release,stdout=log,stderr=subprocess.STDOUT,timeout=820)
 if out.exists():
  d=json.loads(out.read_text());print('BATTLE_RESULT',map_id,d['status'],d['combat'],flush=True)
 else:print('BATTLE_FAILED',map_id,'exit',p.returncode,(o/(map_id+'.log')).read_text(errors='replace')[-1800:],flush=True);break
print('BATCH_FINISHED',flush=True)
