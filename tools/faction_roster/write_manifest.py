"""Register every legal regular-unit/model pairing; verify completion before release."""
from pathlib import Path
import argparse, ast, json

ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'assets/art/units/factions'

def run(allow_building=False):
    factions=json.loads((ROOT/'assets/data/faction_units.json').read_text())['factions']
    weapons=json.loads((ROOT/'assets/data/weapon_models.json').read_text())['models']
    arsenal=json.loads((ROOT/'assets/art/weapons/arsenal/manifest.json').read_text())
    mercer=json.loads((ROOT/'assets/art/units/mercer/manifest.json').read_text())
    models={}; variants={}; missing=[]
    kinds={}
    for faction in factions:
        profile='orlov_sniper' if faction=='orlov' else faction
        path=ROOT/'tools/faction_design'/(profile+'_outfits.py')
        kinds[faction]=0
        if path.exists():
            for node in ast.parse(path.read_text()).body:
                if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='KIND' for t in node.targets):
                    kinds[faction]=ast.literal_eval(node.value)
    for faction in factions:
        for mid,model in weapons.items():
            role=model['weapon_class']
            if faction=='mercer':
                variant=mercer['models'].get('0_'+mid,arsenal['models']['0_'+mid])
            elif faction=='orlov' and role!='sniper':
                variant=arsenal['models']['1_'+mid]
            else:
                profile='orlov_sniper' if faction=='orlov' else faction
                variant='faction_'+profile+'_'+mid
                variants[variant]=dict(file=variant,model=mid,role=role,faction=faction,base=str(kinds[faction])+'_'+model['art_base'])
                for folder in ['units','death_back','check_comrade','blood_masks','portraits','anchors','validation']:
                    path=DEST/folder/(variant+('.json' if folder in ['anchors','validation'] else '.png'))
                    if not path.exists():missing.append(str(path.relative_to(ROOT)))
            models[faction+':'+mid]=variant
    assert len(factions)==23 and len(models)==690 and len(variants)==636
    if missing and not allow_building:
        raise RuntimeError(f'Roster incomplete: {len(missing)} missing files, first: {missing[:3]}')
    DEST.mkdir(parents=True,exist_ok=True)
    (DEST/'manifest.json').write_text(json.dumps(dict(schema_version=1,complete=not missing,faction_count=23,unit_count=115,model_pairings=690,models=models,variants=variants),indent=2)+'\n')
    print('ROSTER_MANIFEST',len(models),'pairings;',len(missing),'files pending')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--allow-building',action='store_true')
    run(parser.parse_args().allow_building)
