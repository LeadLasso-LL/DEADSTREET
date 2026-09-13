from pathlib import Path
import os,sys,json,subprocess,time,re
sys.stdout.reconfigure(encoding="utf-8")
r=Path(__file__).resolve().parents[3];out=Path(__file__).resolve().parent
if len(sys.argv)!=3:raise SystemExit("Usage: python "+Path(__file__).name+" GODOT_EDITOR_EXE RELEASE_RUNTIME_FOLDER")
base=Path(sys.argv[2]);exe=base/"godot.exe"
editor=Path(sys.argv[1])
stage=base/"package";stage.mkdir(exist_ok=True);resultdir=base/"results";resultdir.mkdir(exist_ok=True)
def clean(raw):return b"\n".join(x.rstrip(b" \t\r") for x in re.sub(rb"\r+\n",b"\n",raw).split(b"\n")).rstrip(b"\n")+b"\n"
def run(command,label,timeout=240):
 print("RUN_BEGIN",label,flush=True);t=time.monotonic()
 p=subprocess.run(command,cwd=r,capture_output=True,timeout=timeout)
 raw=clean(p.stdout+p.stderr);(out/(label+".log")).write_bytes(raw);txt=raw.decode("utf-8",errors="replace")
 bad=[v for v in txt.splitlines() if "SCRIPT ERROR" in v or v.startswith("ERROR:") or "REPLAY_FAIL" in v]
 print("RUN_END",label,"exit",p.returncode,"errors",len(bad),"seconds",round(time.monotonic()-t,2),flush=True)
 if p.returncode or bad:print(txt[-8000:],flush=True);raise SystemExit("Failed "+label)
 return txt
native=out/"native.gd";s=native.read_text(encoding="utf-8")
needle=' report["uncapped"]=uncapped;'
addition=' report["build"]={"debug":OS.has_feature("debug"),"editor":OS.has_feature("editor"),"version":Engine.get_version_info()}\n'
assert needle in s
if addition not in s:s=s.replace(needle,addition+needle);native.write_bytes(s.encode("utf-8"))
from prepare_oracles import prepare
prepare()
files={}
wanted={".gd",".tscn",".tres",".json",".cfg",".csv",".txt",".import",".gdshader",".gdshaderinc",".res",".bin",".uid"}
media={".png",".jpg",".jpeg",".webp",".svg",".ogg",".wav",".mp3",".ttf",".otf"}
for folder in ["assets","battle","gameplay","core","world","campaign","tools"]:
 top=r/folder
 if not top.exists():continue
 for current,dirs,names in os.walk(top):
  dirs[:]=[d for d in dirs if d not in {".git","__pycache__","node_modules"}]
  for name in names:
   p=Path(current)/name
   if p.suffix.lower() in wanted or folder=="assets" and p.suffix.lower() in media:
    files[p.relative_to(r).as_posix()]=str(p)
queue=list(files);seen=set()
while queue:
 rel=queue.pop()
 if rel in seen:continue
 seen.add(rel);p=Path(files[rel])
 if p.suffix.lower() not in {".gd",".tscn",".tres",".json",".cfg",".import"}:continue
 if p.stat().st_size>5000000:continue
 text=p.read_text(encoding="utf-8",errors="replace")
 for target in re.findall(r'["\x27](res://[^"\x27\n]+)["\x27]',text):
  sub=target[6:];q=r/sub
  if q.is_file() and sub not in files:files[sub]=str(q);queue.append(sub)
  elif q.is_dir() and len(Path(sub).parts)>=3 and not sub.startswith(".godot"):
   for child in q.rglob("*"):
    if child.is_file() and child.suffix.lower() in wanted|media:
     cr=child.relative_to(r).as_posix()
     if cr not in files:files[cr]=str(child);queue.append(cr)
for rel in [".godot/global_script_class_cache.cfg",".godot/uid_cache.bin",".godot/extension_list.cfg"]:
 if (r/rel).exists():files[rel]=str(r/rel)
prefix=resultdir.as_posix()+"/"
# Package-only output relocation; repository evidence files remain distinct.
for script,old,new in [("native.gd",None,None),("focused.gd","focused.json","release_focused.json"),("replay.gd","replay_collision.json","release_replay.json"),("visual_checks.gd","visual_checks.json","release_visual_checks.json")]:
 s=(out/script).read_text(encoding="utf-8")
 if script=="native.gd":
  oldpath='"res://tools/bridge_perf/headroom/"+label+".json"'
  assert oldpath in s;s=s.replace(oldpath,json.dumps(prefix)+'+label+".json"')
 else:
  oldpath="res://tools/bridge_perf/headroom/"+old
  assert oldpath in s;s=s.replace(oldpath,prefix+new)
 p=stage/script;p.write_bytes(s.encode("utf-8"));files["tools/bridge_perf/headroom/"+script]=str(p)
probe='extends SceneTree\nfunc _initialize():\n var row={"debug":OS.has_feature("debug"),"editor":OS.has_feature("editor"),"version":Engine.get_version_info(),"path":ProjectSettings.globalize_path("res://")}\n FileAccess.open('+json.dumps(prefix+"release_probe.json")+',FileAccess.WRITE).store_string(JSON.stringify(row,"  "))\n print("RELEASE_PROBE ",JSON.stringify(row))\n quit()\n'
(stage/"release_build_info.gd").write_bytes(probe.encode("utf-8"));files["tools/bridge_perf/headroom/release_build_info.gd"]=str(stage/"release_build_info.gd")
boot='extends Node\nfunc _ready():\n var mode="native"\n for arg in OS.get_cmdline_user_args():\n  if arg.begins_with("--check="):mode=arg.trim_prefix("--check=")\n var scripts={"native":"native.gd","probe":"release_build_info.gd","focused":"focused.gd","replay":"replay.gd","visual_checks":"visual_checks.gd"}\n if not scripts.has(mode):get_tree().quit(4);return\n var tree=get_tree()\n var script=load("res://tools/bridge_perf/headroom/"+scripts[mode])\n tree.set_script(script)\n tree.call_deferred("_initialize")\n queue_free()\n'
(stage/"release_boot.gd").write_bytes(boot.encode("utf-8"));files["tools/bridge_perf/headroom/release_boot.gd"]=str(stage/"release_boot.gd")
scene='[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tools/bridge_perf/headroom/release_boot.gd" id="1"]\n[node name="ReleaseBenchmark" type="Node"]\nscript = ExtResource("1")\n'
(stage/"release_boot.tscn").write_bytes(scene.encode("utf-8"));files["tools/bridge_perf/headroom/release_boot.tscn"]=str(stage/"release_boot.tscn")
manifest=[{"path":k,"source":v} for k,v in sorted(files.items())]
total=sum(Path(v).stat().st_size for v in files.values());assert total<8000000000,"Unexpected package size"
(stage/"manifest.json").write_bytes(json.dumps(manifest).encode("utf-8"))
print("PACKAGE_INPUTS",len(files),"bytes",total,flush=True)
packer='extends SceneTree\nfunc _initialize():\n ProjectSettings.set_setting("application/run/main_scene","res://tools/bridge_perf/headroom/release_boot.tscn")\n var settings_path='+json.dumps((stage/"project.binary").as_posix())+'\n if ProjectSettings.save_custom(settings_path)!=OK:quit(2);return\n var pack=PCKPacker.new()\n if pack.pck_start('+json.dumps((base/"benchmark_data.pck").as_posix())+')!=OK:quit(3);return\n if pack.add_file("res://project.binary",settings_path)!=OK:quit(4);return\n var rows=JSON.parse_string(FileAccess.get_file_as_string('+json.dumps((stage/"manifest.json").as_posix())+'))\n for row in rows:\n  if pack.add_file("res://"+row.path,row.source)!=OK:printerr("PACK_FILE_FAILED ",row.path);quit(5);return\n if pack.flush()!=OK:quit(6);return\n print("PACKAGE_READY ",rows.size())\n quit()\n'
(out/"build_probe.gd").write_bytes(packer.encode("utf-8"))
run([str(editor),"--headless","--path",str(r),"--script","res://tools/bridge_perf/headroom/build_probe.gd"],"release_package",300)

print("Base package ready. Run run_release_comparison.py with the same arguments.",flush=True)
