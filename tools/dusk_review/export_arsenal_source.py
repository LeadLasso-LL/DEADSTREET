import pathlib,json,zlib,base64
r=pathlib.Path(__file__).resolve().parents[2]
paths=set()
for pat in ["battle/**/*.gd","gameplay/*.gd","core/*.gd","assets/art/units/pixel_v1/manifest.json","tools/unit_source_recovery/src/**/*.py","tools/unit_source_recovery/src/weapons/*","tools/unit_source_recovery/*.py","tools/unit_source_recovery/*.gd","tools/battle_audio/*.py","tools/battle_showcase/*.gd","project.godot"]:
 for p in r.glob(pat):
  if p.is_file() and p.suffix in [".gd",".py",".json",".svg",".godot"] and "core_validation" not in p.name and "/frames/" not in p.as_posix(): paths.add(p)
data={p.relative_to(r).as_posix():p.read_text(encoding="utf-8-sig") for p in paths}
s=base64.b64encode(zlib.compress(json.dumps(data).encode(),9)).decode()
out=r/"tools/arsenal_production";out.mkdir(exist_ok=True)
(out/"source_transfer.txt").write_text(s)
print("FILES",len(data),"B64",len(s))
