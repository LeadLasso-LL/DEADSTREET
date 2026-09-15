"""Detailed display illustrations for existing Dead Street gun art.
Native SVG authoring. Does not change unit rig anchors, silhouettes or atlases.
Used by the normal arsenal icon build, so the polish survives regeneration.
"""
import copy, xml.etree.ElementTree as E
from weapon_precision_art import precision_art
N='{http://www.w3.org/2000/svg}'
EDGE='#142025';MID='#536267';LIGHT='#a4b2ad';LOW='#2b373d'
def p(g,d,fill='none',stroke=EDGE,width=.55,**kw):
    return E.SubElement(g,N+'path',dict(d=d,fill=fill,stroke=stroke,**{'stroke-width':str(width),'stroke-linejoin':'round','stroke-linecap':'round'},**kw))
def ln(g,d,color=LIGHT,w=.35):return p(g,d,stroke=color,width=w)
def rect(g,x,y,w,h,c=MID):return p(g,f'M{x} {y}h{w}v{h}h{-w}Z',c)
def pin(g,x,y,r=.26):
    E.SubElement(g,N+'circle',{'cx':str(x),'cy':str(y),'r':str(r),'fill':LIGHT})
def guard(g,x,y,w=6,h=4):
    # A solid frame with a genuinely open center, plus a separate curved trigger.
    p(g,f'M{x} {y} H{x+w} Q{x+w+1} {y+1} {x+w-.4} {y+h} H{x-.6} Z M{x+.6} {y+.8} L{x+.1} {y+h-.8} H{x+w-1.1} Q{x+w-.1} {y+1.3} {x+w-.5} {y+.8} Z',MID,EDGE,.35,**{'fill-rule':'evenodd'})
    ln(g,f'M{x+2.3} {y+.6} Q{x+3.1} {y+2} {x+1.9} {y+h-1}',LIGHT,.55)
def grip_texture(g,x,y,w=3,h=6,wood=False):
    for k in range(1,int(h),2):ln(g,f'M{x} {y+k} l{w} -.4','#b88b61' if wood else '#66757a',.25)
    pin(g,x+w/2,y+.4,.21);pin(g,x+w/2,y+h-.2,.21)
def pistol(g,id):
    if id=='glock_17':
        # Replace the three-path placeholder with a complete frame/slide/guard.
        g.clear()
        p(g,'M-2 -1 H16.6 L18 .3 V2.9 L6.2 3.4 H-2Z','#4d5b60',EDGE,.65)
        p(g,'M-1.6 3.2 H15.8 L15.3 4.4 H6.4 L4.9 12.3 .4 11.4 .5 5.2 -1.8 4.7Z','#303e43',EDGE,.65)
        p(g,'M1.3 5 L5.4 5 4.2 10.9 1.4 10.3Z','#25343a',EDGE,.35)
        guard(g,5.9,4.3,5.8,4.2)
        ln(g,'M-1 -.2 H16.4 M-.6 2.9 H15.8',LIGHT,.42)
        rect(g,10.8,-.2,3.5,1.3,'#1d2b30');ln(g,'M11 .9 H14',MID,.3)
        rect(g,-.8,-1.9,1.6,.9,LOW);rect(g,15.9,-1.8,.9,.8,LOW)
        for x in [-.4,.5,1.4,2.3]:ln(g,f'M{x} .3 v1.8','#95a4a4',.32)
        grip_texture(g,1.6,5.5,2.5,4.8)
        pin(g,3.6,3.9);rect(g,3.4,4.8,.8,.6,'#7e8e90')
        ln(g,'M1 11.3 L4.8 12.1',LIGHT,.4);ln(g,'M17.4 .6 v1.4',EDGE,.7)
        return
    length={'m1911':20,'usp':19,'cz75':21,'desert_eagle':25,'five_seven':20}[id]
    for child in list(g):
        if child.get('d')=='M5 5 H10 Q12 9 8 10 H4':g.remove(child)
    guard(g,5,4.7,6,4.8)
    ln(g,f'M.8 3.4 H{length-1.2}', '#687a80',.45)
    ln(g,f'M7 1.5 H{length-3}', '#6d7c80',.3)
    ln(g,f'M{length-.8} .6 v2.4',EDGE,.7)
    pin(g,3.8,4.3);pin(g,1.8,4.6,.18)
    if id=='m1911':
        grip_texture(g,.5,7,2.3,5,True)
        ln(g,'M1 4 H5.4 M2 13.8 L4 14',LIGHT,.4)
    elif id=='desert_eagle':
        ln(g,'M8 .6 H21', '#879393',.3)
        grip_texture(g,-1,7,3.5,7)
        for x in [15,17,19]:ln(g,f'M{x} 1.4 h1',EDGE,.5)
    else:
        grip_texture(g,0,7,3.3,6)
        for x in [11.5,13.5,15.5]:ln(g,f'M{x} 3.7 v.3',MID,.3)
    if id=='five_seven':
        ln(g,'M5 .3 H8 M6 2.5 H8',LIGHT,.5)
        rect(g,4.2,4,.9,.6,'#81949a')
def smg(g,id):
    if id=='uzi':
        # Mag-in-grip silhouette retained; receiver panels, grip safety and guard restored.
        p(g,'M8 .3 H28 V5.6 H19 L18 7 H12 L8 5.7Z','#45565c',EDGE,.5)
        rect(g,10,1,7,2.1,'#24343b');ln(g,'M10 3.3 H17',LIGHT,.3)
        rect(g,19,.8,6.8,1.2,'#17272e')
        ln(g,'M8 -.4 H28 M30 3.5 H36',LIGHT,.5)
        guard(g,18,6.8,6,4.4)
        grip_texture(g,13.3,8.3,3,7)
        ln(g,'M13 18 H16.8 M1 2 H7 M1 4 H7',MID,.5)
        for x in [23,25,27]:ln(g,f'M{x} 3.3 v1.5',LIGHT,.35)
        pin(g,9.2,4.9);pin(g,18,3.6)
        ln(g,'M36.6 1.7 v1.6',EDGE,.7)
        return
    if id=='mac10':
        rect(g,10.8,1.1,15.6,1.1,'#617278');rect(g,20.2,2.7,5.8,1.6,'#18292f')
        guard(g,17.2,7.5,5.6,4.2);grip_texture(g,13.7,10,2.3,9)
        rect(g,17,-1.4,2.3,1.4,'#57696d');pin(g,12,5.4);pin(g,25.8,5.7)
        ln(g,'M12 7 H17 M14 20 H17 M29 2.7 H32',LIGHT,.35)
    elif id in ['mp5','mp5k']:
        guard(g,16,7.2,5.7,4);grip_texture(g,11.2,10,2.8,5)
        ln(g,'M9 2 H27 M10 5.2 H18',LIGHT,.35)
        rect(g,19.3,2.7,6.4,1.2,'#1a2930');pin(g,11,5.5);pin(g,18.3,6.3)
        for y in [10,13,16]:ln(g,f'M23 {y} l2.7 .2',MID,.35)
        for x in ([31,34,37,40] if id=='mp5' else [30,32]):ln(g,f'M{x} 2 v2.5','#667a80',.4)
        ln(g,'M24 -1.3 H28 L29 .1',MID,.6)
    elif id=='vector':
        guard(g,15.7,6,5.7,4.1);grip_texture(g,11,10,2.4,4.8)
        ln(g,'M23 8 L20 17 H23 M28 2 H36 M28 5 H34',LIGHT,.4)
        rect(g,28,2.7,6,1.1,'#1a2a31');pin(g,17,3.5);pin(g,25,6.2)
        ln(g,'M20 18 H23 M20 21 H23',MID,.4)
    else:
        # P90 translucent top magazine and molded bullpup panels.
        for x in range(3,25,3):ln(g,f'M{x} -1 l1.4 .8','#b5a47a',.35)
        ln(g,'M-1 2 H17 M-1 4 H7 M-1 10 L2 12',LIGHT,.4)
        ln(g,'M16 4.5 Q20 5 19 8',MID,.55)
        ln(g,'M25 6 Q23 8 25 9',LIGHT,.55)
        pin(g,3,5);pin(g,32,3)
        ln(g,'M22 -5.8 H30',LIGHT,.4)
def longgun(g,id,kind):
    # Restrained material and machining detail for the already readable long guns.
    wood=id in ['ak47','mini14','rem870','rem700','sks','svd']
    ln(g,'M10 2.8 H16 M12 4.6 H17','#74878a',.35)
    for x,y in [(10,3.9),(24,4.9),(28,3.9)]:pin(g,x,y,.22)
    if wood:
        furniture=[]
        for node in g.iter(N+'path'):
            color=node.get('fill','')
            if len(color)==7 and color.startswith('#'):
                red,green,blue=[int(color[i:i+2],16) for i in (1,3,5)]
                if red>green*1.18 and green>blue*1.1:
                    shape=copy.deepcopy(node);shape.set('stroke','none');furniture.append(shape)
        if furniture:
            clip=E.SubElement(E.SubElement(g,N+'defs'),N+'clipPath',{'id':'furniture_grain'})
            for shape in furniture:clip.append(shape)
            grain=E.SubElement(g,N+'g',{'clip-path':'url(#furniture_grain)'})
            ln(grain,'M-3 3.1 Q1 2.2 4 3.1 M-3 5 Q0 4 3 4.7 M32 2.3 L37 2.7','#bb8f60',.35)
            ln(grain,'M-3 6.8 L1 6.3','#624b39',.5)
    if kind=='rifle':
        for x in [12,15,18]:ln(g,f'M{x} 1.1 h1.3',LIGHT,.3)
        if id not in ['ak47','mini14','aug']:guard(g,15.8,6.7,5.2,3.4)
        if id=='ak47':
            ln(g,'M8 .2 H25 M30 1.7 H36 M21 9 l1 5',LIGHT,.4)
    elif kind=='shotgun':
        ln(g,'M31 .3 H40 M31 5.7 H38',LIGHT,.4)
        if id in ['rem870','moss500','spas12']:
            for x in [31,33,35,37,39]:ln(g,f'M{x} 3 v1.5','#879899',.3)
    else:
        ln(g,'M15 -3 H28 M34 1.4 H48',LIGHT,.35)
        ln(g,'M24 .5 l2 1.1 v2',MID,.7)
        pin(g,26,3.3,.5)
        ln(g,'M16 -5.3 h2 M28 -4 v2','#c0cac1',.3)
def make_display_icon(model,art):
    root=E.Element(N+'svg',{'width':'752','height':'320','viewBox':'-18 -12 94 40'})
    g=E.SubElement(root,N+'g',{'id':'display_firearm'})
    for child in art:g.append(copy.deepcopy(child))
    # Flatten the base group for surgical shape refinements.
    if len(g)==1 and g[0].tag==N+'g' and not g[0].get('transform'):
        group=g[0];g.remove(group)
        for c in group:g.append(c)
    id=model['id'];kind=model['weapon_class']
    if precision_art(g,id):pass
    elif kind=='pistol':pistol(g,id)
    elif kind=='smg':smg(g,id)
    else:longgun(g,id,kind)
    return root
