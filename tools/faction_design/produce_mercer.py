"""Resumable Mercer production through the existing SVG/Godot/palette pipeline."""
from pathlib import Path
import sys, json, copy, subprocess, math, xml.etree.ElementTree as E
from PIL import Image
HERE = Path(__file__).parent
ROOT = HERE.parents[1]
sys.path[:0] = [str(HERE), str(ROOT/'tools/arsenal_production'), str(ROOT/'tools/unit_source_recovery')]
import mercer_animation as anim
import build_art as art
import showcase_build, showcase_finish

DEST = ROOT/'assets/art/units/mercer'
SVG = HERE/'animation_svg'
EXTRA = {'fire_left':dict(start=0,count=3,fps=20,loop=False,atlas='fire_left'),
         'cover_fire_left':dict(start=0,count=3,fps=20,loop=False,atlas='cover_fire_left')}
for folder in ['units','death_back','check_comrade','fire_left','cover_fire_left','portraits','anchors','blood_masks']:
    (DEST/folder).mkdir(parents=True,exist_ok=True)
SVG.mkdir(exist_ok=True); (SVG/'.gdignore').touch()


def build(model_id, sample=False):
    dual = model_id == 'dual_glock'
    model = next(m for m in art.MODELS if m['id']==('glock_17' if dual else model_id))
    _, definition = art.bind(model)
    w = model['art_base']; variant = 'mercer_'+model_id
    art.outfits = anim.outfits
    anim.outfits.SPECS[(0,w)] = anim.style.DUAL if dual else anim.style.SNIPER
    definition['view_lengths'] = {'S':.80,'N':.72}
    clips = dict(art.MANIFEST['clips'])
    if dual: clips.update(EXTRA)
    jobs=[]; muzzles={}; abdomen={}
    def make(direction, state, hand='right'):
        st = dict(state); q=st.pop('q')
        return anim.dual(direction,q,hand,**st) if dual else anim.directions.make(0,q,direction,w,**st)
    for d, direction in enumerate(art.MANIFEST['directions']):
        for clip, spec in clips.items():
            source_clip = clip.removesuffix('_left')
            frames = range(spec['count'])
            if sample:
                if clip not in ['idle','aim','fire','fire_left','reload','walk','wounded_walk','death_back']: continue
                frames = sorted(set([0,spec['count']//2,spec['count']-1]))
            for i in frames:
                if source_clip=='check_comrade':
                    u=anim.build.B.smooth(i/9)
                    state=dict(q=1.25,settle=1,aim=.2*(1-u),crouch=.97*u,lean=8*u)
                else: state=showcase_build.state(source_clip,i,w)
                if dual and source_clip=='idle': state['aim']=0
                definition['carry_angle']=25-14*anim.build.B.smooth(i/9) if source_clip=='check_comrade' and not dual else art.ORIGINAL[w]['carry_angle']
                root=make(direction.upper(),state,'left' if clip.endswith('_left') else 'right')
                if source_clip=='death_back':
                    group=E.Element(art.N+'g',transform=f'translate(0,{-6*state["fall"]:.3f})')
                    for child in list(root):root.remove(child);group.append(child)
                    root.append(group)
                # Fixed packing origin for every new frame; runtime foot anchor is 104.
                packed=E.Element(art.N+'g',transform='translate(0 -6)')
                for child in list(root):root.remove(child);packed.append(child)
                root.append(packed)
                name=f'{variant}_{d}_{clip}_{i}'
                art.save_svg(root,SVG/(name+'.svg'))
                extra=spec.get('atlas','');cell=spec['start']+i
                jobs.append([name,extra or 'units',i*128 if extra else cell%32*128,
                             d*128 if extra else (d*art.MANIFEST['rows_per_direction']+cell//32)*128])
                if clip in ['wounded_idle','wounded_walk']:
                    key=f'{variant}/{direction}/{clip}/{i}'
                    muzzles[key]=art.anchor(root,'muzzle_right' if dual else 'muzzle_anchor')
                    abdomen[key]=art.anchor(root,'abdomen_anchor')
        for pose,crouch in [('open',0),('cover',.15)]:
            for hand in (['right','left'] if dual else ['right']):
                root=make(direction.upper(),dict(q=1.25,settle=1,aim=1,crouch=crouch,kick=.8*{'pistol':1.3,'ak_rifle':1.8}[w]),hand)
                key=f'{variant}/{direction}/{pose}'+('_left' if hand=='left' else '')
                muzzles[key]=art.anchor(root,'muzzle_'+hand if dual else 'muzzle_anchor')
                muzzles[key][1]-=6
    assert all(p is not None and all(math.isfinite(x) for x in p) for p in muzzles.values())
    (DEST/'anchors'/f'{variant}.json').write_text(json.dumps(dict(muzzles=muzzles,abdomen=abdomen)))
    (HERE/'animation_jobs.json').write_text(json.dumps(dict(variant=variant,sample=sample,jobs=jobs,rows=art.MANIFEST['rows_per_direction'])))
    print('SVG',variant,len(jobs),flush=True)
    return variant


def finalize(variant):
    for folder in ['units','death_back','check_comrade','fire_left','cover_fire_left']:
        path=DEST/folder/(variant+'.png')
        if path.exists(): showcase_finish.finish(path)
    atlas=Image.open(DEST/'units'/(variant+'.png')).convert('RGBA')
    atlas.crop((24*128,3*6*128,25*128,3*6*128+128)).crop((18,6,108,86)).save(DEST/'portraits'/(variant+'.png'))
    # Full atlas mask; stain shader samples the current atlas region.
    import numpy as np
    a=np.array(atlas); colors=anim.style.DUAL if variant.endswith('dual_glock') else anim.style.SNIPER
    cloth=np.zeros(a.shape[:2],bool)
    for key in ['cloth','lit','shade']:
        rgb=tuple(bytes.fromhex(colors[key][1:]))
        cloth |= np.max(np.abs(a[:,:,:3].astype(int)-rgb),axis=2)<20
    mask=np.zeros_like(a);mask[cloth & (a[:,:,3]>0)]=255
    Image.fromarray(mask).save(DEST/'blood_masks'/(variant+'.png'))
    for p in SVG.glob(variant+'_*.svg'): p.unlink()


def manifest():
    variants={}; models={}; anchors={'muzzles':{},'abdomen':{}}
    for model in ['rem700','sks','svd','ssg69','awm','psg1','dual_glock']:
        v='mercer_'+model
        if not (DEST/'units'/(v+'.png')).exists(): continue
        variants[v]={'file':v,'base':'0_pistol' if model=='dual_glock' else '0_ak_rifle'}
        if model!='dual_glock':models['0_'+model]=v
        data=json.loads((DEST/'anchors'/(v+'.json')).read_text())
        for key in anchors:anchors[key].update(data[key])
    (DEST/'manifest.json').write_text(json.dumps(dict(variants=variants,models=models,clips=EXTRA),indent=2)+'\n')
    (DEST/'anchors.json').write_text(json.dumps(anchors)+'\n')


if __name__=='__main__':
    godot=sys.argv[1]; sample='--sample' in sys.argv
    models=[a for a in sys.argv[2:] if not a.startswith('--')] or ['dual_glock','rem700','sks','svd','ssg69','awm','psg1']
    for model in models:
        v=build(model,sample)
        subprocess.run([godot,'--headless','--path',str(ROOT),'--script','res://tools/faction_design/render_animation.gd'],check=True)
        if not sample:finalize(v);manifest()
        print('COMPLETE',v,flush=True)
