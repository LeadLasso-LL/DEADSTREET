"""Mercer animation adapter: accepted anatomy, independent pistol arms.

All locomotion, hit reactions, crouching and falls remain on the existing rig.
Only garment detail and the specialist's arm/weapon poses are authored here.
"""
import copy
import math
import xml.etree.ElementTree as E
import numpy as np
import mercer_preview as style

build, directions, outfits = style.build, style.directions, style.outfits
N = style.N


def mix(a, b, t):
    return np.array(a, float)*(1-t)+np.array(b, float)*t


def gun(parent, hand, angle, size, hand_id, reload=0, visible=True):
    definition = style.ORIGINAL_DEFINITIONS['pistol']
    theta = math.radians(angle)
    matrix = np.array([[math.cos(theta), -math.sin(theta)],
                       [math.sin(theta), math.cos(theta)]])*definition['scale']*size
    origin = hand-matrix@np.array(definition['right_grip'])
    a, b = matrix[0]; c, d = matrix[1]
    group = build.group(parent, transform=f'matrix({a} {c} {b} {d} {origin[0]} {origin[1]})')
    if visible:
        style.ORIGINAL_DRAW(group, 'pistol', reload)
    x, y = definition['muzzle']
    E.SubElement(group, N+'circle', id='muzzle_'+hand_id, cx=str(x), cy=str(y), r='0')
    x, y = hand
    build.p(parent, f'M{x-1.8} {y-1.3} Q{x} {y-2.2} {x+1.8} {y-.5} '
            f'L{x+1.5} {y+1.8} Q{x-.4} {y+2.3} {x-1.7} {y+1}Z', '#795139', '#090f12', .95)
    build.p(parent, f'M{x-.9} {y-.6} L{x+.7} {y+.3}', 'none', '#a67550', .65)


def dual(direction, q=1.25, firing_hand='right', **state):
    # Preserve the project's explicitly accepted reflection convention.
    if direction in ['SW', 'W']:
        root = dual({'SW':'SE', 'W':'E'}[direction], q, firing_hand, **state)
        reflected = E.Element(N+'g', transform='translate(128 0) scale(-1 1)')
        for child in list(root): root.remove(child); reflected.append(child)
        root.append(reflected)
        return root
    outfits.SPECS[(0, 'pistol')] = style.DUAL
    root = directions.make(0, q, direction, 'pistol', **state)
    surface = root.find(".//*[@id='stain_surface']")
    parents = {c:p for p in root.iter() for c in p}
    g = parents[surface]
    # Retain the original torso, head, all parent transforms, and all lower art.
    children = list(g); body_index = children.index(surface)
    head = copy.deepcopy(children[body_index+1])
    body = copy.deepcopy(surface)
    g[:] = []
    aim = state.get('aim', 0)
    settle = state.get('settle', 0)
    reload = state.get('reload', 0)
    fall = state.get('fall', 0)
    wounded = state.get('wounded', 0)
    backward = state.get('backward', 0)
    kick = state.get('kick', 0)
    back = direction in ['N', 'NE', 'NW']
    if direction == 'SE':
        shoulders = [[27,32.5],[51.8,32.5]]
        elbows = [[26,43],[59,41]]
        idle = [[29,51],[58,48]]; aimed = [[43,40],[59,31]]
        waist = [[38,53],[48,53]]; abdomen = [43,50]
        angles = [66-58*aim]*2; size = 1.
    else:
        shoulders = [[-11,-27],[11,-27]]
        elbows = [[-15,-14],[15,-14]]
        idle = [[-12,-5],[12,-5]]; aimed = [[-10,-22],[10,-22]]
        waist = [[-5,-3],[5,-3]]; abdomen = [0,-7]
        angles = [(68-146*aim) if back else 68]*2; size = .85
        if direction == 'E':
            shoulders = [[-4,-29],[5,-29]]; elbows = [[-8,-14],[10,-14]]
            idle = [[-4,-3],[13,-6]]; aimed = [[10,-23],[22,-26]]
            waist = [[-1,-3],[7,-5]]; abdomen = [5,-7]
            angles = [66-70*aim]*2
        elif direction in ['NE', 'NW']:
            shoulders = [[-8,-27],[9,-27]]; elbows = [[-12,-14],[14,-14]]
            idle = [[-9,-6],[13,-7]]; aimed = [[-4,-24],[17,-24]]
            angles = [68-92*aim]*2
    hands = [mix(idle[i], aimed[i], aim) for i in range(2)]
    ids = ['left','right'] if back else ['right','left']
    groups = []
    reload_hand = 'right' if reload < .5 else 'left'
    for i in range(2):
        hand = hands[i]
        hand += [1.2*math.sin(2*math.pi*q+i*math.pi)*(1-settle)*(1-aim), 0]
        reload_phase = max(0., min(1., reload*2-(0 if ids[i]=='right' else 1)))
        if reload > 0:
            # Stow one pistol, use that free hand for the active magazine, then swap.
            phase = max(0., min(1., reload*2-(0 if reload_hand=='right' else 1)))
            target = (np.array(waist[0],float)+np.array(waist[1],float))*.5
            if ids[i] != reload_hand:
                target += [-3, 4+5*math.cos(math.pi*phase)]
            hand = mix(hand, target, math.sin(math.pi*reload)**.35)
            angles[i] += 20*math.sin(math.pi*reload_phase)
        if ids[i] == firing_hand:
            hand += [-kick*.7, -kick*.8]
            angles[i] -= kick*4
        if wounded and ids[i] == 'left': hand = np.array(abdomen, float)
        if backward:
            t = build.B.smooth(min(1,backward/.22))
            lift = np.array(shoulders[i])+[(-9 if i==0 else 9),-12+25*fall]
            hand = mix(hand, lift, t)
        elif fall: hand = mix(hand, idle[i], fall)
        elbow = mix(elbows[i], mix(shoulders[i], hand, .58), .25 if aim else 0)
        group = E.Element(N+'g', id='arm_'+ids[i])
        style.connected_arm(group, shoulders[i], elbow, hand, style.DUAL, '#795139', '#a67550')
        visible = fall < .45 and backward < .15 and not(wounded and ids[i]=='left')
        if .04 < reload < .96 and ids[i] != reload_hand: visible = False
        gun(group, hand, angles[i], size, ids[i], reload_phase, visible)
        groups.append(group)
    if back:
        g.extend(groups); g.extend([body,head])
    elif direction == 'SE':
        g.extend([groups[1],body,head,groups[0]])
    else:
        g.extend([body,head]+groups)
    E.SubElement(g, N+'circle', id='abdomen_anchor', cx=str(abdomen[0]), cy=str(abdomen[1]+3), r='0')
    # Geometry is contractual: torso and hierarchy must match the untouched rig.
    baseline = directions.make(0,q,direction,'pistol',**state)
    assert style.body_signature(root) == style.body_signature(baseline), (direction, state)
    assert style.lower_signature(root) == style.lower_signature(baseline), (direction, state)
    return root
