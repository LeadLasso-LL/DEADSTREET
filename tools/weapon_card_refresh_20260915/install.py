from pathlib import Path
import json,hashlib,zipfile,tempfile,subprocess,shutil
R=Path(__file__).resolve().parents[2];O=Path(__file__).resolve().parent
report=json.loads((O/'asset_validation.json').read_text())
assert report['portraits']==691 and report['baseline_mismatches']==0
for path,sha in json.loads((O/'protected_hashes.json').read_text()).items():assert hashlib.sha256((R/path).read_bytes()).hexdigest()==sha,path
for row in report['rows']:
 assert hashlib.sha256((R/row['portrait']).read_bytes()).hexdigest()==row['before_sha256'],row['variant']
 assert hashlib.sha256((O/'candidates'/(row['variant']+'.png')).read_bytes()).hexdigest()==row['candidate_sha256'],row['variant']
icons=[x[0] for x in json.loads((O/'icon_jobs.json').read_text())['jobs']]
for row in report['rows']:shutil.copyfile(O/'candidates'/(row['variant']+'.png'),R/row['portrait'])
for id in icons:shutil.copyfile(O/'renders'/('icon_'+id+'.png'),R/f'assets/art/weapons/arsenal/icons/{id}.png')
manifest={'schema_version':1,'source':'Current Arsenal source SVG artwork, layered into accepted anatomy-corrected card poses.','weapons':{r['model']:hashlib.sha256((R/f"assets/art/weapons/arsenal/source/{r['model']}.svg").read_bytes()).hexdigest() for r in report['rows']},'portraits':{r['variant']:{'path':r['portrait'],'model':r['model'],'sha256':r['candidate_sha256']} for r in report['rows']}}
(R/'assets/data/unit_card_weapon_art.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
# Refresh only imported changed PNGs; runtime-only faction assets need no editor sweep.
files=[r['portrait'] for r in report['rows']]+[f'assets/art/weapons/arsenal/icons/{id}.png' for id in icons]
imported=[p for p in files if (R/(p+'.import')).exists()]
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with tempfile.TemporaryDirectory(prefix='dead_street_weapon_cards_') as work:
 w=Path(work);(w/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Card weapon imports"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for p in imported:
  dest=w/p;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(R/p,dest);shutil.copyfile(R/(p+'.import'),str(dest)+'.import')
 with (O/'imports.log').open('w',encoding='utf-8') as f:p=subprocess.run([godot,'--headless','--editor','--import','--path',str(w)],stdout=f,stderr=subprocess.STDOUT,timeout=60)
 assert p.returncode==0
 for source in (w/'.godot/imported').glob('*'):shutil.copyfile(source,R/'.godot/imported'/source.name)
print('INSTALLED',len(files),'REFRESHED_IMPORTS',len(imported),flush=True)
entry='\n\n## 20260915-weapon-cards-02 - Trigger artwork and all card weapons installed\n\nEight requested trigger assemblies refined with open guards and distinct curved trigger blades (six shotguns plus Mini-14/AUG). All 691 canonical unit portraits now embed current Arsenal SVG artwork, including all 30 regular weapon models and both specialist pistols. Verified exact accepted source match for every baseline and structurally identical non-weapon SVG nodes in both standing directions (1,382 checks): existing anatomy corrections, hands, clothing and card framing are retained. New assets/data/unit_card_weapon_art.json records each source SVG and installed portrait hash for future freshness checks. Refreshed only changed imported images in an isolated Godot import. Other chats\' current UI, Harold maps, music and world atlases preserved. Evidence in tools/weapon_card_refresh_20260915/. Next: native catalogue/card/texture checks, final visual review, records and scoped publication; owner acceptance remains separate.\n'
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md']:
 with (R/'docs'/name).open('a',encoding='utf-8') as f:f.write(entry)
with (O/'native.log').open('w',encoding='utf-8') as f:p=subprocess.run([godot,'--path',str(R),'--rendering-method','gl_compatibility','--resolution','1152x764','--script','res://tools/weapon_card_refresh_20260915/check_native.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=60)
print('NATIVE_RETURN',p.returncode,(O/'native.log').read_text(encoding='utf-8')[-1400:],flush=True)
assert p.returncode==0
