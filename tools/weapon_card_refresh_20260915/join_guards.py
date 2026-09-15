from pathlib import Path
import json,sys,xml.etree.ElementTree as E
O=Path(__file__).resolve().parent;R=O.parents[1]
p=R/'tools/arsenal_production/weapon_trigger_art.py';s=p.read_text();s=s.replace("'spas12':(13.8,6.9,","'spas12':(13.8,6.15,").replace("'benelli_m2':(13.8,6.9,","'benelli_m2':(13.8,6.15,");p.write_text(s,encoding='utf-8',newline='\n')
sys.path.insert(0,str(R/'tools/arsenal_production'))
import build_art as art
from weapon_display_art import make_display_icon
models={m['id']:m for m in art.MODELS};data=json.loads((O/'icon_jobs.json').read_text())
for job in data['jobs']:
 if job[0] not in ['spas12','benelli_m2']:continue
 root=make_display_icon(models[job[0]],art.make(models[job[0]],art.ORIGINAL)[0]);E.register_namespace('',art.N[1:-1])
 job[1]=E.tostring(root,encoding='unicode');(R/f'assets/art/weapons/arsenal/source/{job[0]}.svg').write_text(job[1],encoding='utf-8')
(O/'icon_jobs.json').write_text(json.dumps(data),encoding='utf-8')
exec(compile((O/'build_cards.py').read_text(encoding='utf-8'),str(O/'build_cards.py'),'exec'))
