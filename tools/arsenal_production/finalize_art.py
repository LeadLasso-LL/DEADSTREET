from pathlib import Path
import json,sys
R=Path(__file__).resolve().parents[2];D=R/'assets/art/weapons/arsenal';H=Path(__file__).parent
models=json.loads((R/'assets/data/weapon_models.json').read_text())['models'];mapping={};variants={};muzzles={};abdomen={}
for m in models.values():
 for k in range(3):
  v=f'{k}_{m["id"]}';base=f'{k}_{m["art_base"]}'
  if m['id'] in ['glock_17','uzi','ak47','rem870']:
   mapping[v]=base;continue
  if '--partial' in sys.argv and not (H/f'completed_{v}.json').exists():continue
  for folder in ['units','death_back','check_comrade','portraits']:assert (D/folder/f'{v}.png').exists(),(v,folder)
  key='arsenal_'+v;mapping[v]=key;variants[key]={'file':v,'base':base,'model':m['id']}
  data=json.loads((D/'anchors'/f'{v}.json').read_text())
  muzzles.update({'arsenal_'+key:val for key,val in data['muzzles'].items()})
  abdomen.update({'arsenal_'+key:val for key,val in data['abdomen'].items() if val is not None})
(D/'manifest.json').write_text(json.dumps({'models':mapping,'variants':variants,'sniper_outfits':'Temporary existing rifle role outfits; dedicated faction sniper outfits deferred.'},indent=2)+'\n')
(D/'muzzles.json').write_text(json.dumps(muzzles));(D/'abdomen.json').write_text(json.dumps(abdomen));print('BOUND',len(mapping),'loadouts',len(variants),'new animated variants')
