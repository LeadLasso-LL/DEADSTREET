"""Resumable atlas production. Intermediate SVG files are disposable."""
from pathlib import Path
import json,sys,subprocess,hashlib,shutil
from PIL import Image
import numpy as np
R=Path(__file__).resolve().parents[2];H=Path(__file__).parent;D=R/'assets/art/weapons/arsenal'
sys.path.insert(0,str(R/'tools/unit_source_recovery'))
from showcase_finish import PAL
M=json.loads((R/'assets/data/weapon_models.json').read_text())['models'].values()
GODOT=Path.home()/'OneDrive/Documents/Godot/Godot_v4.7.2-stable_win64_console.exe'
palette=Image.new('P',(1,1));colors=PAL.astype('uint8').reshape(-1).tolist();palette.putpalette((colors+[0]*768)[:768])
def finish(p):
 im=Image.open(p).convert('RGBA');alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0)
 rgb=im.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(alpha);rgb.save(p)
def run(args):subprocess.run(args,cwd=R,check=True)
def main():
 sample='--sample' in sys.argv;records=[]
 for model in M:
  if not sample and model['id'] in ['glock_17','uzi','ak47','rem870']:continue
  for k in ([0] if sample else range(3)):
   v=f'{k}_{model["id"]}';check=H/f'completed_{v}.json'
   if not sample and check.exists():records.append(json.loads(check.read_text()));continue
   args=[sys.executable,str(H/'build_art.py'),model['id'],str(k)]+(['--sample'] if sample else [])
   run(args);run([str(GODOT),'--headless','--path',str(R),'--script',str(H/'render_art.gd')])
   record=json.loads((H/'render_check.json').read_text());records.append(record)
   if not sample:
    for folder in ['units','death_back','check_comrade']:finish(D/folder/f'{v}.png')
    im=Image.open(D/'units'/f'{v}.png');portrait=im.crop((24*128,3*6*128,25*128,3*6*128+128)).crop((18,12,108,92));portrait.save(D/'portraits'/f'{v}.png')
    check.write_text(json.dumps(record));print('FINISHED',v,flush=True)
   for path in (H/'render_svg').glob('*.svg'):path.unlink()
 (H/('sample_report.json' if sample else 'art_report.json')).write_text(json.dumps(records,indent=2)+'\n')
 print('ARSENAL_ART_COMPLETE',len(records),flush=True)
if __name__=='__main__':main()
