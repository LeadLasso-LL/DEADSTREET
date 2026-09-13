from pathlib import Path
import os,sys,json,subprocess,re,time
sys.stdout.reconfigure(encoding="utf-8")
r=Path(__file__).resolve().parents[3];out=Path(__file__).resolve().parent
if len(sys.argv)!=3:raise SystemExit("Usage: python "+Path(__file__).name+" GODOT_EDITOR_EXE RELEASE_RUNTIME_FOLDER")
base=Path(sys.argv[2]);stage=base/"package";resultdir=base/"results";exe=base/"godot.exe"
editor=Path(sys.argv[1])
assert "[autoload]" not in (r/"project.godot").read_text(encoding="utf-8"),"Review startup autoload resources before splitting package"
def run(cmd,label,timeout=240):
 print("RUN_BEGIN",label,flush=True);t=time.monotonic();p=subprocess.run(cmd,cwd=r,capture_output=True,timeout=timeout)
 raw=b"\n".join(x.rstrip(b" \t\r") for x in re.sub(rb"\r+\n",b"\n",p.stdout+p.stderr).split(b"\n")).rstrip(b"\n")+b"\n";(out/(label+".log")).write_bytes(raw)
 txt=raw.decode("utf-8",errors="replace");bad=[v for v in txt.splitlines() if "SCRIPT ERROR" in v or v.startswith("ERROR:") or "REPLAY_FAIL" in v]
 print("RUN_END",label,"exit",p.returncode,"errors",len(bad),"seconds",round(time.monotonic()-t,2),flush=True)
 if p.returncode or bad:print(txt[-7500:],flush=True);raise SystemExit("Failed "+label)
 return txt
# Preserve large immutable resources; small launcher pack holds corrections.
if not (base/"benchmark_data.pck").exists():(base/"godot.pck").rename(base/"benchmark_data.pck")
native=out/"native.gd";s=native.read_text(encoding="utf-8")
line=' report["display"]={"vsync_mode":DisplayServer.window_get_vsync_mode(),"refresh_hz":DisplayServer.screen_get_refresh_rate(),"max_fps":Engine.max_fps}\n'
if line not in s:s=s.replace(' report["build"]=',line+' report["build"]=');native.write_bytes(s.encode("utf-8"))
oldpath='"res://tools/bridge_perf/headroom/"+label+".json"';assert oldpath in s
(stage/"native.gd").write_bytes(s.replace(oldpath,json.dumps(resultdir.as_posix()+"/")+'+label+".json"').encode("utf-8"))
boot=(stage/"release_boot.gd").read_text(encoding="utf-8")
line=' if not ProjectSettings.load_resource_pack(OS.get_executable_path().get_base_dir()+"/benchmark_data.pck",false):\n  printerr("BENCHMARK_DATA_PACK_FAILED");get_tree().quit(5);return\n'
assert 'func _ready():\n' in boot
if line not in boot:boot=boot.replace('func _ready():\n','func _ready():\n'+line)
# The developer executable lives elsewhere; use the same explicit data-pack location in both runs.
boot=boot.replace('OS.get_executable_path().get_base_dir()+"/benchmark_data.pck"',json.dumps((base/"benchmark_data.pck").as_posix()))
(stage/"release_boot.gd").write_bytes(boot.encode("utf-8"))
files={}
for name in ["native.gd","focused.gd","replay.gd","visual_checks.gd","release_build_info.gd","release_boot.gd","release_boot.tscn"]:files["tools/bridge_perf/headroom/"+name]=str(stage/name)
for rel in [".godot/global_script_class_cache.cfg",".godot/uid_cache.bin","icon.svg","icon.svg.import"]:
 p=r/rel
 if p.exists():files[rel]=str(p)
p=r/"icon.svg.import"
if p.exists():
 for path in re.findall(r'"res://([^"]+)"',p.read_text(encoding="utf-8")):
  if (r/path).is_file():files[path]=str(r/path)
files["project.binary"]=str(stage/"project.binary")
(stage/"launcher_manifest.json").write_bytes(json.dumps([{"path":k,"source":v} for k,v in files.items()]).encode("utf-8"))
packer='extends SceneTree\nfunc _initialize():\n var pack=PCKPacker.new()\n if pack.pck_start('+json.dumps((base/"godot.pck").as_posix())+')!=OK:quit(3);return\n var rows=JSON.parse_string(FileAccess.get_file_as_string('+json.dumps((stage/"launcher_manifest.json").as_posix())+'))\n for row in rows:\n  if pack.add_file("res://"+row.path,row.source)!=OK:quit(5);return\n if pack.flush()!=OK:quit(6);return\n print("LAUNCHER_READY ",rows.size())\n quit()\n'
(out/"build_probe.gd").write_bytes(packer.encode("utf-8"));run([str(editor),"--headless","--path",str(r),"--script","res://tools/bridge_perf/headroom/build_probe.gd"],"release_launcher")
results={"source_head":subprocess.check_output(["git","rev-parse","HEAD"],cwd=r,text=True).strip(),"method":"Same two-part benchmark PCK and imported assets for developer and official release runtimes; test launcher/report relocation only; production settings unchanged","provenance_file":"release_provenance.json","package_source_bytes":4287122827,"native":{},"checks":{},"discarded_trials":["First release 24-unit run failed error gate because root icon.svg was missing; not accepted as clean evidence"]}
def save():(out/"release_results.json").write_bytes((json.dumps(results,indent=2)+"\n").encode("utf-8"))
def invoke(mode,label,args=None,debug=False):
 p=resultdir/(label+".json");p.unlink(missing_ok=True)
 cmd=[str(editor),"--main-pack",str(base/"godot.pck")] if debug else [str(exe)]
 if mode!="native":cmd.append("--headless")
 cmd+=["--","--check="+mode]
 if args:cmd+=args
 txt=run(cmd,label)
 if not p.exists():print(txt[-7000:],flush=True);raise SystemExit("Missing fresh report "+label)
 value=json.loads(p.read_text(encoding="utf-8"));(out/p.name).write_bytes((json.dumps(value,indent=2)+"\n").encode("utf-8"));print("RESULT",label,json.dumps(value),flush=True)
 return value
row=invoke("probe","release_probe");assert row["debug"] is False and row["editor"] is False
assert row["version"]["hash"]=="ed1daf0bf001b61586d9930840f2f1394092c079";results["probe"]=row;save()
for debug,side,uncapped in [(False,12,False),(False,16,False),(False,12,True),(True,12,True),(False,16,True),(True,16,True)]:
 label=("packed_debug_" if debug else "release_")+str(side*2)+("_uncapped" if uncapped else "_normal");args=["--side="+str(side),"--duration=30","--label="+label]
 if uncapped:args.append("--uncapped")
 value=invoke("native",label,args,debug)
 assert value["units"]==side*2 and value["rendered"]==side*2 and value["damage"]>0 and value["wall_seconds"]>=29
 assert value["build"]["debug"]==debug
 results["native"][label]=value;save()
for mode in ["focused","replay","visual_checks"]:
 value=invoke(mode,"release_"+mode);results["checks"][mode]=value;save()
print("RELEASE_COMPARISON_COMPLETE",flush=True)
