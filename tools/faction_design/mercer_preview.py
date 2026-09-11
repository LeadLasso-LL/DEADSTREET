"""Standing design previews; isolated from live faction bindings and combat stats.

Uses the approved unit rig and existing weapon drawings. Only this process's
outfit bindings are changed. Run from the repository; see README.md.
"""
from pathlib import Path
import copy
import json
import math
import sys
import xml.etree.ElementTree as E

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
SRC = ROOT / 'tools/unit_source_recovery/src'
sys.path[:0] = [str(SRC), str(SRC.parent), str(SRC/'directional_base'), str(ROOT/'tools/arsenal_production')]
import build
import directions
import equipment
import outfits
import weapon_art

N = build.N
OUT = HERE/'mercer'
OUT.mkdir(parents=True, exist_ok=True)
ORIGINAL_DEFINITIONS = copy.deepcopy(equipment.DEFINITIONS)
ORIGINAL_DRAW = equipment.draw
ORIGINAL_TORSO = outfits.torso
ORIGINAL_HEAD = outfits.head
SNIPER = dict(top='hoodie', cloth='#202527', lit='#353b3d', shade='#111819',
              pants='#181e21', pants_hi='#30383b', shoe='#111819', shoe_hi='#303638',
              head='hood', sleeve='long', wide=1.04, pocket_rag=True)
DUAL = dict(top='tee', cloth='#9a343b', lit='#be4c4b', shade='#622b34',
            pants='#202527', pants_hi='#353b3d', shoe='#d6d5c9', shoe_hi='#eeeee2',
            head='mask', sleeve='long', wide=1.16)


def torso(g, costume, skin, highlight, direction='SE'):
    ORIGINAL_TORSO(g, costume, skin, highlight, direction)
    if costume.get('pocket_rag'):
        # Pocket side is an art-review choice; the approved requirement is one rag.
        x = -9 if direction in ['N', 'NE', 'NW'] else 9
        outfits.path(g, f'M{x-2} -1 L{x+2} 0 L{x+2} 10 L{x} 8 L{x-2} 12 Z',
                     '#9a343b', '#622b34', .65)
        outfits.path(g, f'M{x} 1 L{x} 8', 'none', '#be4c4b', .65)


outfits.torso = torso


def head(g, costume, skin, highlight, direction='SE'):
    if costume.get('pocket_rag') and direction in ['N', 'NE', 'NW']:
        outfits.path(g, 'M-9 -35 L-10 -43 Q-9 -53 0 -53 Q9 -52 10 -44 L10 -33 5 -29 -5 -30Z',
                     costume['cloth'], costume['shade'], 1.2)
        outfits.path(g, 'M-7 -43 Q-7 -49 -2 -51 M7 -43 L7 -35',
                     'none', costume['lit'], .8)
        outfits.path(g, 'M0 -50 Q-1 -40 1 -32', 'none', costume['shade'], .7)
        outfits.path(g, 'M-6 -33 Q0 -30 6 -33', 'none', costume['lit'], .65)
    else:
        ORIGINAL_HEAD(g, costume, skin, highlight, direction)


outfits.head = head


def gun(parent, hand, angle, scale=1.0):
    """Each hand has its own complete Glock drawing and grip anchor."""
    definition = ORIGINAL_DEFINITIONS['pistol']
    theta = math.radians(angle)
    matrix = np.array([[math.cos(theta), -math.sin(theta)],
                       [math.sin(theta), math.cos(theta)]]) * definition['scale'] * scale
    hand = np.array(hand, float)
    origin = hand - matrix @ np.array(definition['right_grip'], float)
    a, b = matrix[0]
    c, d = matrix[1]
    g = build.group(parent, transform=f'matrix({a} {c} {b} {d} {origin[0]} {origin[1]})')
    ORIGINAL_DRAW(g, 'pistol')
    x, y = hand
    build.p(parent, f'M{x-1.8} {y-1.3} Q{x} {y-2.2} {x+1.8} {y-.5} '
            f'L{x+1.5} {y+1.8} Q{x-.4} {y+2.3} {x-1.7} {y+1} Z',
            '#795139', '#090f12', .95)
    build.p(parent, f'M{x-.9} {y-.6} L{x+.7} {y+.3}', 'none', '#a67550', .65)


def dual(direction, aim=False):
    outfits.SPECS[(0, 'pistol')] = DUAL
    root = directions.make(0, 1.25, direction, 'pistol', settle=1, aim=float(aim))
    skin, hi = '#795139', '#a67550'
    if direction == 'SE':
        g = root.find(".//*[@id='upper_pose']")
        # Preserve the existing head transform while rebuilding only the upper art.
        old_head = next(c for c in g if any(e.get('d', '').startswith('M-6 -37') for e in c.iter()))
        head_transform = old_head.get('transform', '')
        g[:] = []
        near_hand = np.array([43., 40.]) if aim else np.array([29., 51.])
        far_hand = np.array([59., 31.]) if aim else np.array([58., 48.])
        far_arm = build.group(g)
        outfits.arm(far_arm, [51.8, 32.5], [59., 41.], far_hand, DUAL, skin, hi)
        gun(g, far_hand, 8 if aim else 66)
        body = build.group(g, id='stain_surface', transform='translate(43 56)')
        torso(body, DUAL, skin, hi, direction)
        head = build.group(g, transform=head_transform)
        outfits.head(build.group(head, transform='translate(43 56)'), DUAL, skin, hi, direction)
        outfits.arm(g, [27., 32.5], [26., 43.], near_hand, DUAL, skin, hi)
        gun(g, near_hand, 8 if aim else 66)
    else:
        assert direction in ['S', 'N']
        wrap = list(root)[-1]
        wrap[:] = []
        g = build.group(wrap)
        back = direction == 'N'
        hands = [np.array([-12., -5.]), np.array([12., -5.])]
        if aim:
            hands = [np.array([-10., -22.]), np.array([10., -22.])]
        angles = [-78, -78] if back and aim else [68, 68]
        arms = build.group(g)
        for side, hand in zip([-1, 1], hands):
            outfits.arm(arms, [side*11., -27.], [side*15., -14.], hand, DUAL, skin, hi)
        if back:
            for hand, angle in zip(hands, angles):
                gun(g, hand, angle, .7 if aim else .85)
        torso(build.group(g, id='stain_surface'), DUAL, skin, hi, direction)
        head = build.group(g, transform='translate(0 1) translate(0 -34) scale(.88) translate(0 34)')
        outfits.head(head, DUAL, skin, hi, direction)
        if not back:
            g.remove(arms)
            g.append(arms)
            for hand, angle in zip(hands, angles):
                gun(g, hand, angle, .7 if aim else .85)
    return root


def sniper(direction, aim=False):
    models = json.loads((ROOT/'assets/data/weapon_models.json').read_text(encoding='utf-8'))['models']
    art, definition = weapon_art.make(models['rem700'], ORIGINAL_DEFINITIONS)
    equipment.DEFINITIONS['ak_rifle'] = definition
    equipment.draw = lambda parent, weapon_id, reload=0: weapon_art.draw_art(parent, art, reload)
    outfits.SPECS[(0, 'ak_rifle')] = SNIPER
    root = directions.make(0, 1.25, direction, 'ak_rifle', settle=1, aim=float(aim))
    if direction == 'SE':
        # Add ankle-height leather shafts over the existing rounded footwear.
        _, states = build.B.make(1.25, settle=1)
        lower = list(root)[0]
        for state in states:
            if 'foot' not in state:
                continue
            foot = np.array(state['foot'])
            a = build.B.proj(foot + [0, 12, 0])
            b = build.B.proj(foot + [0, 3.8, 0])
            x, y = a
            bx, by = b
            boot = build.group(lower)
            build.p(boot, f'M{x-3.6} {y} Q{x} {y-1} {x+3.6} {y} '
                    f'L{bx+3.7} {by+1} Q{bx} {by+2} {bx-3.7} {by+1}Z',
                    SNIPER['shoe'], '#090f12', .8)
            build.p(boot, f'M{x-2} {y+2} L{x+1.8} {y+2} '
                    f'M{x-1.7} {y+4} L{x+2} {y+4}', 'none', SNIPER['shoe_hi'], .6)
    equipment.DEFINITIONS['ak_rifle'] = copy.deepcopy(ORIGINAL_DEFINITIONS['ak_rifle'])
    equipment.draw = ORIGINAL_DRAW
    return root


def generate():
    jobs = []
    for name, maker in [('sniper', sniper), ('dual_glock', dual)]:
        for direction in ['SE', 'S', 'N']:
            for aimed in [False, True]:
                key = f'{name}_{direction}_{"aim" if aimed else "idle"}'
                svg = maker(direction, aimed)
                E.register_namespace('', N[1:-1])
                (OUT/(key+'.svg')).write_bytes(E.tostring(svg))
                jobs.append(key)
    (OUT/'jobs.json').write_text(json.dumps(jobs, indent=2)+'\n')
    print('PREVIEW_SVGS', len(jobs), flush=True)


def board():
    # Native 128px renders enlarged with nearest-neighbor filtering for inspection.
    import showcase_finish
    for path in OUT.glob('*.png'):
        if path.stem.startswith(('sniper_', 'dual_glock_')):
            showcase_finish.finish(path)
    font_dir = Path('C:/Windows/Fonts')
    def font(size, bold=False):
        return ImageFont.truetype(str(font_dir/('arialbd.ttf' if bold else 'arial.ttf')), size)
    im = Image.new('RGB', (1280, 1020), '#151c20')
    draw = ImageDraw.Draw(im)
    draw.rectangle((28, 28, 34, 80), fill='#a4484c')
    draw.text((50, 27), 'MERCER SAINTS', font=font(30, True), fill='#efeadc')
    draw.text((50, 65), 'New unit outfit review  /  Standing poses from the existing game rig', font=font(16), fill='#b6bdbb')
    for row, (name, title, detail) in enumerate([
        ('sniper', 'SNIPER', 'Black hood + lower-face bandana / black pants + boots / one red pocket rag'),
        ('dual_glock', 'DUAL-PISTOL SPECIALIST', 'Baggier red long sleeve / black pants / white shoes / black ski mask')
    ]):
        y = 113 + row*427
        draw.text((30, y), title, font=font(20, True), fill='#efeadc')
        draw.text((30, y+29), detail, font=font(15), fill='#b6bdbb')
        for col, (direction, pose, label) in enumerate([
            ('SE', 'idle', 'STANDING'), ('SE', 'aim', 'AIMING'),
            ('S', 'idle', 'FRONT'), ('N', 'idle', 'BACK')
        ]):
            x = 28+col*312
            draw.rounded_rectangle((x, y+62, x+300, y+411), radius=4, fill='#2a3335', outline='#465054')
            draw.text((x+14, y+76), label, font=font(13, True), fill='#adb7b6')
            actor = Image.open(OUT/f'{name}_{direction}_{pose}.png').convert('RGBA')
            actor = actor.resize((320, 320), Image.Resampling.NEAREST)
            im.paste(actor, (x-10, y+100), actor)
    draw.text((30, 984), 'Outfit and pose candidates. Specialist combat, reload animation and full motion production follow visual approval.',
              font=font(14), fill='#a9b2b0')
    im.save(OUT/'mercer_new_units_review.png')
    print('PREVIEW_BOARD', str(OUT/'mercer_new_units_review.png'), flush=True)


if __name__ == '__main__':
    board() if '--board' in sys.argv else generate()
