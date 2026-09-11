"""Eastex wardrobe adapter over the accepted body, gait and weapon rig.

Changes are process-local. Shared Mercer art and live faction bindings are kept.
"""
from pathlib import Path
import copy, re, sys, xml.etree.ElementTree as E
import numpy as np

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import mercer_preview as rig

outfits, directions, build = rig.outfits, rig.directions, rig.build
N, path, xy = rig.N, outfits.path, outfits.xy
BASE = copy.deepcopy(rig.BASE_PISTOL)
WHITE = ('#d6d5c9', '#eeeee2', '#929c9b')
BLACK = ('#202527', '#353b3d', '#111819')
BLUE = ('#244d92', '#3d6bb3', '#19335d')


def costume(top, colors, head, sleeve='short', **extra):
    return dict(top=top, cloth=colors[0], lit=colors[1], shade=colors[2],
                head=head, sleeve=sleeve, wide=BASE['wide'],
                pants='#202527', pants_hi='#353b3d', shoe='#202527',
                shoe_hi='#42494a', eastex=True, new_unit=True, **extra)


SPECS = {
    'pistol': costume('tee', WHITE, 'durag', tattoo=True),
    'smg': costume('jersey', BLUE, 'white_mask'),
    'shotgun': costume('hoodie', BLACK, 'mask', 'long', camo=True, boots=True),
    'rifle': costume('tee', BLACK, 'backward_cap'),
    'sniper': costume('hoodie', BLACK, 'hood_white_mask', 'long', boots=True),
}
for key in ['pistol', 'smg']:
    SPECS[key].update(shoe=WHITE[0], shoe_hi=WHITE[1])
SPECS['smg'].update(pants='#626a6e', pants_hi='#879094')
SPECS['shotgun'].update(pants='#485240', pants_hi='#66705a',
                        shoe='#ad7e43', shoe_hi='#cba065')


def head(g, c, skin, hi, direction='SE'):
    if not c.get('eastex'):
        return rig.head(g, c, skin, hi, direction)
    h = c['head']; back = direction in ['N', 'NE', 'NW']; side = direction in ['E', 'W']
    shape = ('M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z'
             if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z')
    if h == 'mask':
        return rig.ORIGINAL_HEAD(g, c, skin, hi, direction)
    if h == 'white_mask':
        temp = E.Element(N+'g')
        rig.ORIGINAL_HEAD(temp, dict(c, head='mask'), skin, hi, direction)
        for el in temp.iter():
            for attr in ['fill', 'stroke']:
                color = el.get(attr)
                if color in ['#202527', '#42494a']:
                    el.set(attr, {'#202527':WHITE[0], '#42494a':WHITE[2]}[color])
        g.extend(list(temp)); return
    if h == 'hood_white_mask':
        # Original hood silhouette and head placement, with a separate mask inside.
        temp = E.Element(N+'g')
        rig.head(temp, dict(c, head='hood', pocket_rag=True), skin, hi, direction)
        if not back:
            # Replace only the visible face insert; the hood keeps its black cloth.
            for el in list(temp):
                if el.get('d', '').startswith(('M-4 -43 Q0 -46', 'M-5 -40', 'M-3 -38', 'M-3 -42')):
                    temp.remove(el)
            path(temp, 'M-4 -43 Q0 -46 5 -42 L5 -35 1 -32 -4 -35Z', WHITE[0], '#111819', .65)
            path(temp, 'M-3.5 -42 L4 -41.6 4 -39.8 -3.5 -40.2Z', skin, '#111819', .5)
            path(temp, 'M-2.7 -41.1 L-1.1 -41 M1.6 -40.9 L3 -40.8', 'none', '#111819', .55)
            path(temp, 'M-2 -37 L1 -35.5 M-1 -34.7 L1 -34', 'none', WHITE[2], .65)
        g.extend(list(temp)); return
    if h == 'backward_cap':
        temp = E.Element(N+'g')
        rig.ORIGINAL_HEAD(temp, dict(c, head='cap'), skin, hi, direction)
        for i, el in enumerate(list(temp)):
            for attr in ['fill', 'stroke']:
                color = el.get(attr)
                if color in ['#953d43', '#be5854', '#281e24', '#c0806d']:
                    el.set(attr, {'#953d43':BLACK[0], '#be5854':BLACK[1],
                                  '#281e24':BLACK[2], '#c0806d':'#626a6e'}[color])
                elif i in [1, 2] and color in ['#202527', '#42494a']:
                    el.set(attr, BLUE[0] if color == '#202527' else BLUE[1])
        g.extend(list(temp)); return
    assert h == 'durag'
    path(g, shape, skin, w=1.15)
    if not back:
        path(g, 'M-3 -40 L-1 -40 M2 -40 L4 -40 M-1 -35 L2 -35', 'none', '#382b25', .65)
        path(g, 'M1 -39 L2 -37', 'none', hi, .7)
    path(g, 'M-7 -43 L-7 -47 Q-5 -51 0 -51 Q6 -51 7 -46 L7 -42 Q0 -40 -7 -43Z', BLUE[0], BLUE[2], .9)
    path(g, 'M0 -50 Q-1 -46 0 -42 M-5 -47 Q-3 -49 -1 -49', 'none', BLUE[1], .65)
    path(g, 'M-7 -43 Q0 -41 7 -43', 'none', BLUE[2], .65)
    if back:
        path(g, 'M-2 -42 L2 -42 3 -39 1 -38 -2 -39Z', BLUE[2], 'none')
        path(g, 'M-1 -39 L-3 -31 0 -32 1 -39Z M1 -39 L3 -33 5 -32 3 -40Z', BLUE[0], BLUE[2], .5)
    elif side or direction == 'SE':
        path(g, 'M-6 -42 L-9 -40 -9 -34 -7 -35 -6 -40Z', BLUE[0], BLUE[2], .5)


def arm(parent, start, elbow, hand, c, skin, hi):
    if not c.get('eastex') or c['sleeve'] == 'long':
        return rig.connected_arm(parent, start, elbow, hand, c, skin, hi)
    a, b, h = (np.array(v, float) for v in [start, elbow, hand])
    v = (b-a)/np.linalg.norm(b-a); end = a+(b-a)*.56
    near = a[0] < (40 if a[1] > 0 else 0)
    inward = 1 if near else -1
    n = np.array([-v[1], v[0]]) * (1 if near else -1)
    inner = a+[6*inward, -5.5]
    if a[1] > 0: inner = np.array([33.,26.5] if near else [49.,26.5])
    r = 3.7*c['wide']; outer = a+[-inward*(r-.8), -1.5]
    cloth, light, shade = WHITE if c['top'] == 'jersey' else (c['cloth'], c['lit'], c['shade'])
    g = E.SubElement(parent, N+'g', {'data-shoulder-join':'continuous'})
    # Exposed upper arm and forearm carry continuous tattoo sleeves if requested.
    outfits.forearm(g, a+v*5, b, c, skin, hi)
    outfits.forearm(g, b, h, c, skin, hi)
    left, right = end+n*(r-.5), end-n*(r-.5)
    path(g, f'M{xy(inner)} Q{xy(a+[0,-4])} {xy(outer)} Q{xy(a+v*4+n*r)} {xy(left)} '
         f'Q{xy(end+v*.9)} {xy(right)} L{xy(a+v*3-n*(r-.5))} Q{xy(a+[inward*2,0])} {xy(inner)}Z', cloth, 'none')
    path(g, f'M{xy(outer)} Q{xy(a+v*4+n*r)} {xy(left)}', 'none', '#090f12', .9)
    path(g, f'M{xy(left)} Q{xy(end+v*.6)} {xy(right)}', 'none', shade, .65)
    path(g, f'M{xy(a+[.2,-1])} L{xy(end-v*2+n*.8)}', 'none', light, .8)


def decorate_lower(root, c):
    """Fabric patches follow each limb's existing segment; geometry stays intact."""
    for parent in list(root.iter()):
        for el in list(parent):
            d = el.get('d', '')
            if el.get('fill') != c['pants'] or re.search('[QCAqca]', d): continue
            nums = re.findall(r'-?\d+(?:\.\d+)?', d)
            if len(nums) != 12: continue
            points = np.array(list(map(float, nums))).reshape(6,2)
            a, b = (points[0]+points[5])/2, (points[2]+points[3])/2
            length = np.linalg.norm(b-a)
            if length < 2: continue
            v=(b-a)/length; n=np.array([-v[1],v[0]])
            radius=np.linalg.norm(points[2]-points[3])/2
            g=E.Element(N+'g', {'data-garment-detail':'true'})
            if c.get('camo'):
                for t,offset,color in [(.20,-.4,'#786244'),(.38,.6,'#202923'),(.58,-.6,'#303d28'),(.77,.4,'#7f7956')]:
                    center=a+(b-a)*t+n*offset
                    def pt(x,y): return xy(center+n*x+v*y)
                    width=min(2.7,radius-.65)
                    path(g, f'M{pt(-width,-1.9)} Q{pt(-.4,-3)} {pt(1,-1.6)} '
                         f'L{pt(width,-.2)} Q{pt(.6,1)} {pt(width-.3,2.6)} '
                         f'L{pt(-1.3,3)} Q{pt(-width,1.4)} {pt(-1.2,.2)}Z', color, 'none')
            if c.get('boots') and radius < 3.5:
                top=b-v*min(7,length*.34)
                path(g, f'M{xy(top+n*radius)} L{xy(top-n*radius)} L{xy(b-n*radius)} '
                     f'Q{xy(b+v)} {xy(b+n*radius)}Z', c['shoe'], 'none')
                path(g, f'M{xy(top+n*radius)} L{xy(top-n*radius)}', 'none', '#30302a', .6)
                for depth in [2.,4.]:
                    center=top+v*depth
                    path(g, f'M{xy(center-n*1.4)} L{xy(center+n*1.4)}', 'none', c['shoe_hi'], .5)
            if len(g):
                # Keep camouflage visible above the base limb's broad highlight.
                index=list(parent).index(el)+1
                if index<len(parent) and parent[index].get('fill')==c['pants_hi']:
                    index+=1
                parent.insert(index,g)


def install():
    outfits.head=head
    outfits.arm=arm


def make(role, model, direction, **state):
    import build_art as art
    c=SPECS[role]; w=model['art_base']
    outfits.SPECS[(0,w)]=c
    _,definition=art.bind(model)
    if role == 'sniper': definition['view_lengths']={'S':.80,'N':.72}
    root=directions.make(0,state.pop('q',1.25),direction,w,**state)
    signature=rig.body_signature(root)
    lower=rig.lower_signature(root)
    if c.get('camo') or c.get('boots'): decorate_lower(root,c)
    clean=copy.deepcopy(root)
    for parent in clean.iter():
        for child in list(parent):
            if child.get('data-garment-detail'):parent.remove(child)
    assert rig.body_signature(clean)==signature
    assert rig.lower_signature(clean)==lower
    return root


install()
