from pathlib import Path
import sys, json, importlib, copy, xml.etree.ElementTree as E
import numpy as np
R=Path(__file__).resolve().parents[2]
O=Path(__file__).parent
sys.path[:0]=[str(R/'tools/faction_roster'),str(R/'tools/faction_design'),str(R/'tools/arsenal_production'),str(R/'tools/unit_source_recovery'),str(R/'tools/unit_source_recovery/src')]
import build_art as art, showcase_build as show, showcase_finish as finish
profile=sys.argv[1]
style=None if profile in ['mercer','orlov'] else importlib.import_module(profile+'_outfits')
import mercer_preview as rig
sys.path.insert(0,str(O))
import portrait_anatomy as repair
rows=[x for x in json.loads((O/'inventory.json').read_text()) if x['faction']==profile]
if '--sample' in sys.argv: rows=[x for x in rows if x['model']=='glock_17']
models={m['id']:m for m in art.MODELS}
extra=[] if style is None else [v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
extra+=['244d92','3d6bb3','19335d','929c9b','786244','202923','303d28','7f7956','30302a']
if style is not None:extra += [v.lstrip('#') for v in getattr(style,'EXTRA_PALETTE',[])]
palette=finish.PAL if style is None else np.vstack([finish.PAL,np.array([tuple(bytes.fromhex(v)) for v in extra],dtype=np.int32)])
E.register_namespace('',art.N[1:-1])
jobs=[];report=[]
for row in rows:
    model=models[row['model']]
    for direction in ['SE','SW']:
        def make():
            st=show.state('idle',0,'pistol')
            if style is not None:
                root=style.make('pistol',model,direction,**st)
                wrap=E.Element(art.N+'g',{'transform':'translate(0 -6)'})
                for child in list(root):root.remove(child);wrap.append(child)
                root.append(wrap)
                return root
            art.bind(model)
            return art.directions.make(0 if profile=='mercer' else 1,st.pop('q'),direction,'pistol',**st)
        original=make()
        with repair.corrected(style is None): candidate=make()
        assert rig.body_signature(original)==rig.body_signature(candidate)
        assert rig.lower_signature(original)==rig.lower_signature(candidate)
        assert art.anchor(original,'muzzle_anchor')==art.anchor(candidate,'muzzle_anchor')
        assert E.tostring(list(original.find(".//*[@id='upper_pose']"))[-1])==E.tostring(list(candidate.find(".//*[@id='upper_pose']"))[-1])
        for name,root in [('before',original),('after',candidate)]:
            label=row['variant']+'_'+direction+'_'+name
            jobs.append([label,E.tostring(root,encoding='unicode')])
        report.append({'variant':row['variant'],'direction':direction,'body_unchanged':True,'lower_unchanged':True})
(O/'jobs').mkdir(exist_ok=True)
(O/'jobs'/(profile+'.json')).write_text(json.dumps({'jobs':jobs,'palette':palette.tolist(),'report':report,'rows':rows}),encoding='utf-8')
print('PORTRAIT_SVG',profile,len(jobs),flush=True)
