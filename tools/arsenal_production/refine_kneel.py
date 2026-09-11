"""Keep long sniper barrels inside the existing aftermath frame."""
from pathlib import Path
import sys,json,subprocess
H=Path(__file__).parent;R=H.parents[1];sys.path.insert(0,str(H))
from produce_art import GODOT,finish
models=json.loads((R/'assets/data/weapon_models.json').read_text())['models']
for m in models.values():
 if m['weapon_class']!='sniper':continue
 for k in range(3):
  v=f'{k}_{m["id"]}'
  subprocess.run([sys.executable,str(H/'build_art.py'),m['id'],str(k),'--clip=check_comrade'],cwd=R,check=True)
  subprocess.run([str(GODOT),'--headless','--path',str(R),'--script',str(H/'render_art.gd')],cwd=R,check=True)
  check=json.loads((H/'render_check.json').read_text());assert not check['touching_frame_border'],check
  finish(R/'assets/art/weapons/arsenal/check_comrade'/f'{v}.png')
  path=H/f'completed_{v}.json';old=json.loads(path.read_text());old['touching_frame_border']=[x for x in old['touching_frame_border'] if '_check_comrade_' not in x];path.write_text(json.dumps(old))
  for p in (H/'render_svg').glob('*.svg'):p.unlink()
(H/'art_report.json').write_text(json.dumps([json.loads(p.read_text()) for p in sorted(H.glob('completed_*.json'))],indent=2))
print('LONG_RIFLE_KNEEL_REVIEWED 18 variants; zero clipped aftermath frames')
