"""Build full accepted outfit/model animations with isolated, resumable workers.

Guide loadouts are deliberately not consulted. Every class-compatible model is
built. Existing Mercer and regular Orlov production assets are reused verbatim.
"""
from pathlib import Path
import argparse, concurrent.futures, copy, hashlib, importlib, json, math
import os, shutil, subprocess, sys, time, xml.etree.ElementTree as E
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
DEST = ROOT / 'assets/art/units/factions'
WORK = Path(os.environ.get('LOCALAPPDATA', str(HERE))) / 'DeadStreetTools/roster_build'
GODOT = Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe')
PROFILES = ['eastex','calle_ocho','ventresca','ravicci','orlov_sniper','zangyaku','bitian','stateline','sierra_roja','whittaker','mcallister','trc','nbpd','mercer44','wm_corp','union_sur','lombardia','sand_raiders','saffar','kurgan','ashford_crane','blacktop']
FOLDERS = ['units','death_back','check_comrade','blood_masks','portraits','anchors','validation']
sys.path[:0] = [str(ROOT/'tools/faction_design'), str(ROOT/'tools/arsenal_production'), str(ROOT/'tools/unit_source_recovery')]

def fingerprint(profile):
    files = sorted((ROOT/'tools/faction_design').glob('*.py'))
    files += sorted((ROOT/'tools/unit_source_recovery/src').glob('*.py'))
    files += [HERE/'build_roster.py', HERE/'render_batch.gd', ROOT/'assets/data/weapon_models.json']
    files += sorted((ROOT/'tools/arsenal_production').glob('*.py'))
    return hashlib.sha256(b''.join(p.read_bytes() for p in files)).hexdigest()

def finish_exact(path, palette):
    """Same RGB Euclidean nearest-palette rule/ties as showcase_finish, once per unique color."""
    a = np.array(Image.open(path).convert('RGBA'))
    valid = a[:,:,3] >= 128
    rgb = a[:,:,:3][valid].astype(np.int32)
    packed=(rgb[:,0].astype(np.uint32)<<16)|(rgb[:,1].astype(np.uint32)<<8)|rgb[:,2].astype(np.uint32)
    unique, inverse = np.unique(packed, return_inverse=True)
    colors=np.stack([(unique>>16)&255,(unique>>8)&255,unique&255],axis=1).astype(np.int32)
    nearest = np.empty_like(colors, dtype=np.uint8)
    for start in range(0, len(colors), 6000):
        part = colors[start:start+6000]
        nearest[start:start+6000] = palette[((part[:,None,:]-palette)**2).sum(2).argmin(1)]
    a[:,:,:3][valid] = nearest[inverse]
    a[:,:,3] = np.where(valid,255,0)
    a[~valid] = 0
    Image.fromarray(a).save(path, compress_level=3)

def worker(profile, only_model=''):
    import mercer_animation as anim
    import build_art as art
    import showcase_build as show
    import showcase_finish as finish
    style = importlib.import_module(profile+'_outfits')
    extra = [v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
    extra += ['244d92','3d6bb3','19335d','929c9b','786244','202923','303d28','7f7956','30302a']
    extra += [v.lstrip('#') for v in getattr(style,'EXTRA_PALETTE',[])]
    palette = np.vstack([finish.PAL, np.array([tuple(bytes.fromhex(v)) for v in extra],dtype=np.int32)])
    for folder in FOLDERS:
        (DEST/folder).mkdir(parents=True, exist_ok=True)
    # Runtime reads these PNGs explicitly. Avoid redundant editor texture imports.
    (DEST/'.gdignore').touch()
    key = fingerprint(profile)
    models = [m for m in art.MODELS if m['weapon_class'] in style.SPECS and (not only_model or m['id']==only_model)]
    current = {'clip':'', 'frame':0}
    original_bind = art.bind
    def bound(model):
        result, definition = original_bind(model)
        if current['clip']=='check_comrade' and model['weapon_class']=='sniper':
            t = current['frame']/9
            definition['carry_angle'] = 25-14*t*t*(3-2*t)
        return result, definition
    art.bind = bound
    for model in models:
        begin = time.monotonic()
        variant = 'faction_'+profile+'_'+model['id']
        record = DEST/'validation'/f'{variant}.json'
        if record.exists() and json.loads(record.read_text()).get('fingerprint')==key:
            print('CACHED',variant,flush=True)
            continue
        work = WORK/variant
        work.mkdir(parents=True,exist_ok=True)
        jobs=[]; muzzles={}; abdomen={}; body_checks=0
        role, w = model['weapon_class'], model['art_base']
        def make(direction, st, clip, i):
            nonlocal body_checks
            current.update(clip=clip,frame=i)
            root = style.make(role,model,direction,**st)
            if clip in ['idle','aim','reload','wounded_walk','death_back'] and i==0:
                kind=next((k[0] for k,v in style.outfits.SPECS.items() if v is style.SPECS[role]),getattr(style,'KIND',0))
                costume=style.outfits.SPECS[(kind,w)]
                style.outfits.SPECS[(kind,w)]=style.BASE
                ref=style.directions.make(kind,st.get('q',1.25),direction,w,**{k:v for k,v in st.items() if k!='q'})
                style.outfits.SPECS[(kind,w)]=costume
                assert style.rig.body_signature(root)==style.rig.body_signature(ref),(variant,direction,clip,'body geometry')
                body_checks += 1
            dy=-6-(6*st['fall'] if clip=='death_back' else 0)
            group=E.Element(art.N+'g', transform=f'translate(0 {dy:.3f})')
            for child in list(root): root.remove(child); group.append(child)
            root.append(group)
            return root
        E.register_namespace('',art.N[1:-1])
        for d, direction in enumerate(art.MANIFEST['directions']):
            for clip, info in art.MANIFEST['clips'].items():
                for i in range(info['count']):
                    if clip=='check_comrade':
                        u=(i/9)**2*(3-2*i/9)
                        st=dict(q=1.25,settle=1,aim=.2*(1-u),crouch=.97*u,lean=8*u)
                    else: st=show.state(clip,i,w)
                    root=make(direction.upper(),st,clip,i)
                    extra_atlas=info.get('atlas','')
                    target=extra_atlas or 'units'
                    cell=info['start']+i
                    x=i*128 if extra_atlas else cell%32*128
                    y=d*128 if extra_atlas else (d*6+cell//32)*128
                    label=f'{direction}/{clip}/{i}'
                    jobs.append([E.tostring(root,encoding='unicode'),target,x,y,label])
                    if clip in ['wounded_idle','wounded_walk']:
                        anchor_key=f'{variant}/{label}'
                        muzzles[anchor_key]=art.anchor(root,'muzzle_anchor')
                        abdomen[anchor_key]=art.anchor(root,'abdomen_anchor')
                        mask=copy.deepcopy(root); show.clothing_mask(mask)
                        jobs.append([E.tostring(mask,encoding='unicode'),'blood_masks',x,y,label+'/mask'])
            for pose,crouch in [('open',0),('cover',.15)]:
                st=dict(q=1.25,settle=1,aim=1,crouch=crouch,kick=.8*{'pump_shotgun':4.5,'ak_rifle':1.8,'uzi_smg':.7,'pistol':1.3}[w])
                root=make(direction.upper(),st,'muzzle',0)
                muzzles[f'{variant}/{direction}/{pose}']=art.anchor(root,'muzzle_anchor')
        assert all(p is not None and all(math.isfinite(x) for x in p) for p in list(muzzles.values())+list(abdomen.values())),variant
        (work/'jobs.json').write_text(json.dumps(dict(variant=variant,output=str(work),jobs=jobs)),encoding='utf-8')
        del jobs
        generated=time.monotonic()
        result=subprocess.run([str(GODOT),'--headless','--path',str(ROOT),'--script','res://tools/faction_roster/render_batch.gd','--',str(work/'jobs.json')],capture_output=True,text=True)
        if result.returncode:
            raise RuntimeError(variant+'\n'+result.stdout+'\n'+result.stderr)
        rendered=time.monotonic()
        render=json.loads((work/'render.json').read_text())
        assert render['frames']==2224 and not render['empty'],(variant,render)
        raw_sample=Image.open(work/'units.png').crop((24*128,128*6,25*128,128*7))
        raw_sample.save(work/'palette_check.png')
        finish.PAL=palette; finish.finish(work/'palette_check.png')
        for folder in ['units','death_back','check_comrade']:
            finish_exact(work/(folder+'.png'),palette)
        # Both algorithms must agree exactly on an actual rendered crop.
        quantized=Image.open(work/'units.png').crop((24*128,128*6,25*128,128*7))
        assert np.array_equal(np.array(quantized),np.array(Image.open(work/'palette_check.png'))),variant
        im=Image.open(work/'units.png')
        portrait=im.crop((24*128,3*6*128,25*128,3*6*128+128)).crop((18,6,108,86))
        portrait.save(DEST/'portraits'/f'{variant}.png')
        for folder in ['units','death_back','check_comrade','blood_masks']:
            shutil.copy2(work/(folder+'.png'),DEST/folder/f'{variant}.png')
        (DEST/'anchors'/f'{variant}.json').write_text(json.dumps(dict(muzzles=muzzles,abdomen=abdomen)))
        report=dict(variant=variant,profile=profile,model=model['id'],role=role,fingerprint=key,
                    frames=1840,clips=17,directions=8,body_checks=body_checks,
                    borders=render['borders'],seconds=round(time.monotonic()-begin,2),
                    generation_seconds=round(generated-begin,2),render_seconds=round(rendered-generated,2))
        record.write_text(json.dumps(report,indent=2)+'\n')
        shutil.rmtree(work)
        print('BUILT',variant,json.dumps({k:report[k] for k in ['seconds','generation_seconds','render_seconds','body_checks']}),'borders',len(report['borders']),flush=True)

def run_all(workers):
    WORK.mkdir(parents=True,exist_ok=True)
    def run(profile):
        with (WORK/(profile+'.log')).open('w') as log:
            p=subprocess.run([sys.executable,__file__,'--worker',profile],stdout=log,stderr=subprocess.STDOUT)
        if p.returncode:raise RuntimeError(profile+' failed; see '+str(WORK/(profile+'.log')))
        return profile
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        for result in pool.map(run,PROFILES):print('PROFILE_COMPLETE',result,flush=True)

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--worker');parser.add_argument('--model',default='');parser.add_argument('--workers',type=int,default=2)
    args=parser.parse_args()
    if args.worker:worker(args.worker,args.model)
    else:run_all(args.workers)
