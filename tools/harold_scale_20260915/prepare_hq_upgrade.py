import pathlib,hashlib,json,shutil,subprocess
p=pathlib.Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); out=p/'tools/harold_scale_20260915/hq_upgrade'
out.mkdir(exist_ok=True); before=out/'before'; before.mkdir(exist_ok=True); (before/'.gdignore').write_text('')
cat=p/'battle/geometry/harold_street_catalog.gd'; data=cat.read_bytes()
assert hashlib.sha256(data).hexdigest()=='94c5583fa214f34597ebe1f021ba85564d90536656a6edbdb68274c042800c35'
model=json.loads((p/'assets/data/vehicle_models.json').read_text())['models']['volta']; print('MODEL',json.dumps(model))
assert model['length']==4.65 and model['width']==1.94
owned=['battle/geometry/harold_street_catalog.gd','assets/art/harold_frontage/ground.png']
protected=['gameplay/harold_street_art.gd','gameplay/tactical_battle_view.gd','battle/vehicles/battle_arrival_service.gd','battle/vehicles/battle_vehicle_placement_context.gd','battle/ai/battle_vehicle_deployment_planner.gd','assets/data/vehicle_models.json']
receipt={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=p,text=True).strip(),'protected':{f:hashlib.sha256((p/f).read_bytes()).hexdigest() for f in protected},'owned_before':{f:hashlib.sha256((p/f).read_bytes()).hexdigest() for f in owned},'model':model}
for f in owned: shutil.copy2(p/f,before/pathlib.Path(f).name)
(out/'baseline.json').write_text(json.dumps(receipt,indent=2))
event='\n\n## 20260915-harold-scale-08 - Owner requests a conspicuous HQ status car\nOwner rejected the subtle Cabrillo/Rancher wealth contrast: at least one car immediately outside the steps must obviously look nicer. Selected the canonical bright azure Volta GT ($68,000 grand tourer, below exotic/endgame tiers) after inspecting actual west-facing Volta and Kensei sprites. Replace only north_car_2 Cabrillo with Volta at x20.3 (centre24.02, directly across from steps23..27.1), retain the other11 neighborhood vehicles and the accepted street/scale work. This supersedes the modest-upgrades-only choice in harold-scale-04/07. Existing1.6 model scale derives footprint7.44x3.104 and cover; rebake matching ground shadow. Current HEAD '+receipt['head']+'; branch verified, index empty, other uncommitted work preserved. Next: native clearance/access checks and screenshot; owner visual acceptance pending. Scope tools/harold_scale_20260915/hq_upgrade/. No staging/commit/push in this correction.\n'
for f in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    with (p/f).open('a',encoding='utf-8') as stream: stream.write(event)
hive=p/'docs/DEAD_STREET_HIVE_MIND.md'; current=hive.read_text(encoding='utf-8')
lines=current.splitlines(); lines=[('**Active objective (2026-09-15):** Harold HQ-car correction in progress: replace the understated Cabrillo with a visibly upscale blue Volta GT directly outside the steps. Prior widened-street/1.6-scale work retained. See harold-scale-08; native screenshot next.') if x.startswith('**Active objective (2026-09-15):**') else x for x in lines]
hive.write_text('\n'.join(lines)+'\n',encoding='utf-8')
text=data.decode('utf-8'); assert text.count('["north_car_2", "cabrillo", 19.0]')==1
text=text.replace('["north_car_2", "cabrillo", 19.0]','["north_car_2", "volta", 20.3]').replace('# Neighborhood transport; the two HQ cars are modest Mercer upgrades.','# Poor-neighborhood transport with one conspicuous Volta GT outside the HQ steps.')
cat.write_bytes(text.encode('utf-8')); print('HQ_UPGRADE_INSTALLED',receipt['head'])