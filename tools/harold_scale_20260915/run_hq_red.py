import pathlib,json,hashlib,shutil,subprocess,time
p=pathlib.Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); out=p/'tools/harold_scale_20260915/hq_red'; out.mkdir(exist_ok=True)
before=out/'before'; before.mkdir(exist_ok=True); (before/'.gdignore').write_text('')
cat=p/'battle/geometry/harold_street_catalog.gd'; data=cat.read_bytes(); assert hashlib.sha256(data).hexdigest()=='32ef823e55c7a18a5d9a8ce52530aabb587b8fdb028c7ad6b11f903c7723b928'
model=json.loads((p/'assets/data/vehicle_models.json').read_text())['models']['veloce']; assert model['length']==4.55 and model['width']==1.98
base=json.loads((p/'tools/harold_scale_20260915/hq_upgrade/baseline.json').read_text()); base['head']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=p,text=True).strip(); base['model']=model
for f in base['owned_before']: shutil.copy2(p/f,before/pathlib.Path(f).name)
base['owned_before']={f:hashlib.sha256((p/f).read_bytes()).hexdigest() for f in base['owned_before']}; (out/'baseline.json').write_text(json.dumps(base,indent=2))
event='\n\n## 20260915-harold-scale-10 - Blue HQ model rejected; scarlet replacement\nBrandon explicitly rejected the blue Volta ("not a blue model"). Selected the existing scarlet Veloce Rosso after actual sprite inspection: obvious sports-car status, fitting Saints red, $89,000 and below top-end Arsenal vehicles. This supersedes the Volta choice in harold-scale-08/09, not the request for a conspicuous HQ car. Replace only north_car_2 model, preserving x20.3, other11 cars, street and canonical1.6 scale. New footprint7.28x3.168 drives cover/art/shadow together. Scope tools/harold_scale_20260915/hq_red/. HEAD '+base['head']+'; branch verified/index empty. Preserve concurrent weapon-card/comparison/menu work. Next: rebake ground, repeat focused native access/screenshot fixture, owner review. No commit/push in this correction.\n'
for f in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']: (p/f).open('a',encoding='utf-8').write(event)
h=p/'docs/DEAD_STREET_HIVE_MIND.md'; lines=h.read_text(encoding='utf-8').splitlines(); lines=[('**Active objective (2026-09-15):** Replace rejected blue HQ Volta with scarlet Veloce Rosso, retaining conspicuous status-car placement. Harold red-car correction in progress; see harold-scale-10. Other chats retain weapon-card/comparison/menu scope.') if x.startswith('**Active objective (2026-09-15):**') else x for x in lines]; h.write_text('\n'.join(lines)+'\n',encoding='utf-8')
text=data.decode('utf-8'); assert text.count('["north_car_2", "volta", 20.3]')==1; text=text.replace('["north_car_2", "volta", 20.3]','["north_car_2", "veloce", 20.3]').replace('one conspicuous Volta GT','one conspicuous scarlet Veloce Rosso'); cat.write_bytes(text.encode('utf-8'))
test=(p/'tools/harold_scale_20260915/hq_upgrade/check.gd').read_text(); test=test.replace('hq_upgrade/','hq_red/').replace('volta','veloce').replace('Volta GT','Veloce Rosso').replace('Volta','Veloce').replace('Vector2(4.65,1.94)','Vector2(4.55,1.98)').replace('DEAD_STREET_Harold_HQ_Upgrade.png','DEAD_STREET_Harold_Red_HQ_Car.png'); (out/'check.gd').write_text(test,encoding='utf-8')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe'
jobs=[('bake',['--script','res://tools/dusk_review/bake_harold_frontage.gd','--','--ground-only'],180),('import',['--headless','--editor','--import'],600),('native',['--script','res://tools/harold_scale_20260915/hq_red/check.gd'],180)]
for name,args,limit in jobs:
    print('START',name,flush=True)
    with (out/(name+'_stdout.log')).open('w',encoding='utf-8') as log:
        child=subprocess.Popen([godot,'--path',str(p),'--log-file',str(out/(name+'.log'))]+args,cwd=p,stdout=log,stderr=subprocess.STDOUT)
        (out/'running.json').write_text(json.dumps({'stage':name,'pid':child.pid,'started':time.time()})); code=child.wait(timeout=limit)
    print('END',name,code,flush=True); assert code==0,(name,code)
print('RED_HQ_COMPLETE',flush=True)