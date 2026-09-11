"""Build reproducible Eastex outfit reviews with existing weapons and animations."""
from pathlib import Path
import copy, json, sys, xml.etree.ElementTree as E
import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE=Path(__file__).parent
ROOT=HERE.parents[1]
sys.path.insert(0,str(HERE))
import eastex_outfits as style
import build_art as art
import showcase_build, showcase_finish

OUT=HERE/'eastex'
FRAMES=OUT/'frames'
FRAMES.mkdir(parents=True,exist_ok=True)
(FRAMES/'.gdignore').touch()
TITLE="EASTEX 44'S"
PREFIX='eastex'
KIND=0
ROLES=['pistol','smg','shotgun','rifle','sniper']
MODELS=dict(zip(ROLES,['glock_17','uzi','rem870','ak47','rem700']))
DIRECTIONS=['SE','S','SW','E','W','NE','N','NW']
DESCRIPTIONS={
    'pistol':'Blue durag / white tee / tattoo sleeves',
    'smg':'White mask / blue jersey over white tee',
    'shotgun':'Hood down / black mask / woodland camo',
    'rifle':'Backward black cap / blue bandana',
    'sniper':'Black hood up / white ski mask',
}


def state(clip,i,w):
    return showcase_build.state(clip,i,w)


def generate(extended=False, roles=None):
    selected=set(roles or ROLES)
    assert selected and selected.issubset(ROLES)
    jobs=[]; geometry=0
    def frame(role,direction,clip,i,model=None):
        nonlocal geometry
        model=model or next(m for m in art.MODELS if m['id']==MODELS[role])
        key=f'{role}_{direction}_{clip}_{i}'+('' if model['id']==MODELS[role] else '_'+model['id'])
        if key in jobs:return
        st=state(clip,i,model['art_base'])
        root=style.make(role,model,direction,**st)
        # Compare the body against the already accepted ordinary Mercer anatomy.
        costume=style.outfits.SPECS[(KIND,model['art_base'])]
        style.outfits.SPECS[(KIND,model['art_base'])]=style.BASE
        reference=style.directions.make(KIND,st['q'],direction,model['art_base'],**{k:v for k,v in st.items() if k!='q'})
        assert style.rig.body_signature(root)==style.rig.body_signature(reference),(key,'body geometry')
        style.outfits.SPECS[(KIND,model['art_base'])]=costume
        geometry+=1
        # Same fixed packing origin as Mercer; never scale an individual actor to fit.
        packed=E.Element(style.N+'g',transform='translate(0 -6)')
        for child in list(root):root.remove(child);packed.append(child)
        root.append(packed)
        art.save_svg(root,FRAMES/(key+'.svg'))
        jobs.append(key)
    for role in ROLES:
        if role not in selected:continue
        for direction in DIRECTIONS:
            for clip in ['idle','aim']:frame(role,direction,clip,0)
            if extended:
                for clip,i in [('walk',6),('walk',18),('reload',20),('cover_tucked_idle',0),
                               ('cover_fire',0),('wounded_walk',6),('death_back',17)]:
                    frame(role,direction,clip,i)
        if extended:
            for clip,count in [('walk',24),('fire',3),('reload',40),('cover_popout',8),
                               ('cover_tuck',9),('wounded_walk',24)]:
                for i in range(count):frame(role,'SE',clip,i)
    if extended:
        for model in art.MODELS:
            role=model['weapon_class']
            if role not in selected:continue
            for direction in DIRECTIONS:frame(role,direction,'aim',0,model)
    (OUT/'jobs.json').write_text(json.dumps(jobs),encoding='utf-8')
    (OUT/'geometry_validation.json').write_text(json.dumps({'frames':geometry,'body_matches_accepted_geometry':True,'extended':extended,'roles':sorted(selected)},indent=2)+'\n')
    print(PREFIX.upper()+'_SVG',len(jobs),flush=True)


def font(size,bold=False):
    return ImageFont.truetype('C:/Windows/Fonts/'+('arialbd.ttf' if bold else 'arial.ttf'),size)


def sprite(role,direction,clip='idle',i=0,model=None):
    key=f'{role}_{direction}_{clip}_{i}'+('' if model is None or model==MODELS[role] else '_'+model)
    return Image.open(FRAMES/(key+'.png')).convert('RGBA')


def header(im,title,subtitle):
    d=ImageDraw.Draw(im)
    d.rectangle((24,24,30,79),fill=style.BLUE[0])
    d.text((46,20),title,font=font(30,True),fill='#efeadc')
    d.text((46,61),subtitle,font=font(16),fill='#acb9bd')


def paste(im,actor,x,y,scale=2):
    actor=actor.resize((128*scale,128*scale),Image.Resampling.NEAREST)
    im.paste(actor,(x,y),actor)


def board():
    jobs=json.loads((OUT/'jobs.json').read_text())
    extras=[value[1:] for c in style.SPECS.values() for value in c.values() if isinstance(value,str) and value.startswith('#')]
    extras+=['244d92','3d6bb3','19335d','929c9b','786244','202923','303d28','7f7956','30302a']
    extras += [v.lstrip('#') for v in getattr(style,'EXTRA_PALETTE',[])]
    showcase_finish.PAL=np.vstack([showcase_finish.PAL,np.array([tuple(bytes.fromhex(v)) for v in extras])])
    for key in jobs:showcase_finish.finish(FRAMES/(key+'.png'))
    im=Image.new('RGB',(1440,824),'#151c20');header(im,TITLE,'Regular roster / standing and aiming / same rig and fixed canvas scale')
    d=ImageDraw.Draw(im)
    for col,role in enumerate(ROLES):
        x=col*288+12
        d.rounded_rectangle((x,105,x+272,794),radius=4,fill='#2a3335',outline='#465054')
        d.text((x+14,119),role.upper(),font=font(19,True),fill='#efeadc')
        d.text((x+14,151),'STANDING',font=font(12,True),fill='#aab8ba')
        paste(im,sprite(role,'SE'),x+8,170)
        d.text((x+14,435),'AIMING',font=font(12,True),fill='#aab8ba')
        paste(im,sprite(role,'SE','aim'),x+8,451)
        lines={'pistol':['Blue durag / tattoo sleeves','White tee / black pants / white shoes'],
               'smg':['White ski mask / blue jersey','White tee / gray pants / white shoes'],
               'shotgun':['Black hoodie down / black mask','Woodland camo / wheat work boots'],
               'rifle':['Backward black cap / blue bandana','Black tee / pants / shoes'],
               'sniper':['Black hoodie up / white ski mask','Black pants / black boots']}[role]
        lines=getattr(style,'NOTES',{}).get(role,lines)
        for j,line in enumerate(lines):d.text((x+12,741+j*20),line,font=font(12),fill='#bac3c3')
    im.save(OUT/f'{PREFIX}_lineup_review.png')
    im=Image.new('RGB',(800,2030),'#151c20')
    header(im,TITLE,'Five regular outfits / standing and aiming')
    d=ImageDraw.Draw(im)
    for row,role in enumerate(ROLES):
        y=108+row*378
        d.text((24,y),role.upper(),font=font(21,True),fill='#efeadc')
        d.text((24,y+29),DESCRIPTIONS[role],font=font(15),fill='#acb9bd')
        for col,clip in enumerate(['idle','aim']):
            x=20+col*390
            d.rounded_rectangle((x,y+59,x+370,y+361),radius=4,fill='#2a3335',outline='#465054')
            d.text((x+14,y+69),'STANDING' if clip=='idle' else 'AIMING',font=font(12,True),fill='#aab8ba')
            actor=sprite(role,'SE',clip).crop((8,20,120,124)).resize((280,260),Image.Resampling.NEAREST)
            im.paste(actor,(x+45,y+96),actor)
    im.save(OUT/f'{PREFIX}_outfit_review.png')
    for clip in ['idle','aim']:
        im=Image.new('RGB',(1664,1232),'#151c20')
        header(im,TITLE+" / "+('STANDING' if clip=='idle' else 'AIMING'),'All eight directions / fixed 128px source, enlarged equally')
        d=ImageDraw.Draw(im)
        for row,role in enumerate(ROLES):
            y=104+row*224
            d.text((18,y),role.upper(),font=font(16,True),fill='#efeadc')
            for col,direction in enumerate(DIRECTIONS):
                x=col*208
                d.rectangle((x+8,y+28,x+201,y+211),fill='#2a3335')
                # Fixed crop leaves the whole body and gun visible; no per-image fitting.
                actor=sprite(role,direction,clip).crop((8,20,120,124)).resize((168,156),Image.Resampling.NEAREST)
                im.paste(actor,(x+20,y+49),actor)
                d.text((x+16,y+32),direction,font=font(11,True),fill='#aab8ba')
        im.save(OUT/f'{PREFIX}_{clip}_directions.png')
    print(PREFIX.upper()+'_BOARDS',len(jobs),flush=True)
    if not (FRAMES/'pistol_SE_reload_39.png').exists():return
    frames=[];durations=[]
    for clip,count in [('walk',24),('fire',3),('reload',40),('cover_popout',8),('cover_tuck',9),('wounded_walk',24)]:
        for i in range(count):
            im=Image.new('RGB',(1440,410),'#151c20')
            header(im,TITLE+" / "+clip.replace('_',' ').upper(),'Existing animation clips / five regular outfits')
            d=ImageDraw.Draw(im)
            for col,role in enumerate(ROLES):
                x=col*288+16;d.text((x+20,102),role.upper(),font=font(17,True),fill='#efeadc')
                paste(im,sprite(role,'SE',clip,i),x,129)
            frames.append(im);durations.append(100 if clip=='fire' else 55)
        durations[-1]+=250
    frames[0].save(OUT/f'{PREFIX}_motion_review.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2)
    print(PREFIX.upper()+'_MOTION',len(frames),flush=True)


def audit():
    samples=[('walk',6),('walk',18),('reload',20),('cover_tucked_idle',0),
             ('cover_fire',0),('wounded_walk',6),('death_back',17)]
    im=Image.new('RGB',(1456,1232),'#151c20')
    header(im,TITLE+" / MOTION SAMPLES",'Fixed-scale SE stance samples from the standard clips')
    d=ImageDraw.Draw(im)
    for row,role in enumerate(ROLES):
        y=104+row*224
        d.text((18,y),role.upper(),font=font(16,True),fill='#efeadc')
        for col,(clip,i) in enumerate(samples):
            x=col*208
            d.rectangle((x+8,y+28,x+201,y+211),fill='#2a3335')
            actor=sprite(role,'SE',clip,i).resize((192,192),Image.Resampling.NEAREST)
            im.paste(actor,(x+8,y+23),actor)
            d.text((x+14,y+32),clip.replace('cover_','')+' '+str(i),font=font(10,True),fill='#aab8ba')
    im.save(OUT/f'{PREFIX}_motion_samples.png')
    models=list(art.MODELS)
    im=Image.new('RGB',(1536,1416),'#151c20')
    header(im,TITLE+" / ARMORY FIT",'All 30 existing models / aiming pose / fixed canvas scale')
    d=ImageDraw.Draw(im)
    for row,role in enumerate(ROLES):
        selected=[m for m in models if m['weapon_class']==role]
        assert len(selected)==6,(role,len(selected))
        y=104+row*260
        d.text((18,y),role.upper(),font=font(16,True),fill='#efeadc')
        for col,m in enumerate(selected):
            x=col*256
            d.rectangle((x+8,y+28,x+249,y+251),fill='#2a3335')
            actor=sprite(role,'SE','aim',0,m['id']).resize((256,256),Image.Resampling.NEAREST)
            im.paste(actor,(x,y+1),actor)
            d.text((x+14,y+32),m['id'].upper(),font=font(12,True),fill='#aab8ba')
    im.save(OUT/f'{PREFIX}_armory_fit.png')
    print(PREFIX.upper()+'_AUDIT_BOARDS',flush=True)


if __name__=='__main__':
    if '--audit' in sys.argv:audit()
    elif '--board' in sys.argv:board()
    else:generate('--extended' in sys.argv)
