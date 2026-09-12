"""2034 fleet geometry. Shared world dimensions, shaped bodywork and fitted glass.

Geometry is the source of truth for all eight facings and door phases. Deliberate
heritage and scavenged vehicles keep their identity within a contemporary fleet.
"""
import math
import random
from vehicle_detail_geometry import shell, badge, shade, motorcycle, exotic

INK='#162127'; GLASS='#243b49'; SILVER='#a1b0b6'; GREEN='#284b3c'; GOLD='#bba166'

def blend(a,b,t): return tuple(a[i]+(b[i]-a[i])*t for i in range(len(a)))

def greenhouse(d,x0,x1,w,z0,z1,paint,front_rake=.62,rear_rake=.53,windows=2,roof=None,opaque_until=None):
    """Shorter crowned roof, low glass, raked pillars; no tall rectangular cabin."""
    t0=x0+rear_rake;t1=x1-front_rake;rw=w*.83
    for side in [-1,1]:
        y=side*w;ry=side*rw
        bottom=[(x0,y,z0),(x1,y,z0)]
        top=[(t0,ry,z1-.025),(t1,ry,z1-.045)]
        d.poly([bottom[0],bottom[1],top[1],top[0]],shade(paint,.91),None)
        for n in range(windows):
            a=(n+.045)/windows;b=(n+.945)/windows
            if opaque_until is not None and x0+(x1-x0)*(a+b)*.5<opaque_until:continue
            lo0=blend(bottom[0],bottom[1],a);lo1=blend(bottom[0],bottom[1],b)
            hi0=blend(top[0],top[1],a);hi1=blend(top[0],top[1],b)
            q=[blend(lo0,hi0,.13),blend(lo1,hi1,.13),blend(lo1,hi1,.89),blend(lo0,hi0,.89)]
            d.poly(q,GLASS,'#354b55',1,.014)
            d.line([q[3],q[2]],'#728b94',1,.024)
        d.line(bottom,shade(paint,1.25),1,.028)
    for x,tx,front in [(x0,t0,False),(x1,t1,True)]:
        q=[(x,-w,z0),(x,w,z0),(tx,rw,z1-.045),(tx,-rw,z1-.045)]
        d.poly(q,paint,None)
        if not front and opaque_until is not None:continue
        mid=tuple(sum(p[i] for p in q)/4 for i in range(3))
        glass=[blend(mid,p,.91) for p in q]
        d.poly(glass,GLASS,'#415966',1,.014)
        d.line([glass[3],glass[2]],'#839ea7',1,.025)
        if front:
            for a in [.22,.65]:d.line([blend(glass[0],glass[1],a),blend(glass[0],glass[2],a+.13)],INK,1,.03)
    roof=roof or paint
    for ya,yb,mul,za,zb in [(-1,-.53,1.03,-.035,.005),(-.53,.53,1.14,.005,.005),(.53,1,1.03,.005,-.035)]:
        d.poly([(t0,rw*ya,z1+za),(t1,rw*ya,z1+za-.018),(t1,rw*yb,z1+zb-.018),(t0,rw*yb,z1+zb)],shade(roof,mul),None)

def wheel_body(d,m,r,axles,anchors,paint=None):
    """Wheel arches are real cut-outs in the lower body, not lines over hidden tires."""
    L=m['length'];Y=m['width']/2;p=paint or m['paint']
    for x in axles:
        for side in [-1,1]:
            d.wheel(x,side*(Y-.018),r,.23,rim_color=m.get('rim_color'),spokes=7 if m['price']>40000 else 5)
    xs=set(a[0] for a in anchors)
    for axle in axles:
        xs.update(axle+math.cos(i*math.pi/12)*(r+.055) for i in range(13))
    def at(x):
        for a,b in zip(anchors,anchors[1:]):
            if a[0]<=x<=b[0]:
                t=(x-a[0])/(b[0]-a[0]);return [a[j]+(b[j]-a[j])*t for j in range(1,4)]
        return list((anchors[0] if x<anchors[0][0] else anchors[-1])[1:])
    sections=[]
    for x in sorted(xs):
        if x<anchors[0][0] or x>anchors[-1][0]:continue
        w,low,high=at(x)
        for axle in axles:
            if abs(x-axle)<r+.055:low=max(low,r+math.sqrt(max(0,(r+.055)**2-(x-axle)**2)))
        sections.append((x,w,min(low,high-.065),high))
    shell(d,sections,p)
    for side in [-1,1]:
        for x in axles:
            pts=[(x+math.cos(a)*(r+.062),side*(Y+.004),r+math.sin(a)*(r+.062)) for a in [i*math.pi/18 for i in range(19)]]
            d.line(pts,shade(p,.68),1,.02)
        d.line([(axles[0]+r+.12,side*Y,.27),(axles[-1]-r-.12,side*Y,.27)],'#344048',2,.025)

def lamps(d,L,Y,belt,paint,kind='modern',brand=''):
    xf=L*.491;xb=-L*.491
    # Wide shallow grilles sit beneath thin, separated LED signatures.
    lo=.41 if belt<1.2 else .62
    d.poly([(xf,-Y*.68,lo),(xf,Y*.68,lo),(xf,Y*.55,belt-.17),(xf,-Y*.55,belt-.17)],'#15262e',None)
    for z in [lo+.065,lo+.14]:d.line([(xf+.01,-Y*.5,z),(xf+.01,Y*.5,z)],'#465860',1,.018)
    for side in [-1,1]:
        yy=side*Y*.66
        d.line([(xf,side*Y*.43,belt-.105),(xf,side*Y*.82,belt-.105),(L*.452,side*Y*.91,belt-.055)],'#d3edf1',2,.03)
        d.line([(xb,side*Y*.28,belt-.09),(xb,side*Y*.82,belt-.09),(-L*.447,side*Y*.94,belt-.03)],'#d35554',1,.03)
        d.poly([(xf,yy-.085,lo+.035),(xf,yy+.085,lo+.035),(xf,yy+.12,belt-.25),(xf,yy-.12,belt-.25)],'#293a43',None,.0,.022)
    if kind in ['ev','luxury','fastback']:
        d.line([(xf+.012,-Y*.44,belt-.102),(xf+.012,Y*.44,belt-.102)],'#a6cbd0',1,.04)
        d.line([(xb-.008,-Y*.70,belt-.09),(xb-.008,Y*.70,belt-.09)],'#b94348',1,.04)
    if kind=='luxury':
        d.poly([(xf+.018,-Y*.27,lo),(xf+.018,Y*.27,lo),(xf+.018,Y*.27,belt-.06),(xf+.018,-Y*.27,belt-.06)],'#3b4c54',SILVER,1,.05)
        for j in range(-4,5):d.line([(xf+.03,j*Y*.055,lo+.05),(xf+.03,j*Y*.055,belt-.10)],SILVER,1,.06)
    d.poly([(xf+.025,-.17,lo+.03),(xf+.025,.17,lo+.03),(xf+.025,.17,lo+.12),(xf+.025,-.17,lo+.12)],'#bbc0b4',None,priority=.04)
    if brand=='nbpd':
        for side in [-1,1]:d.line([(xf+.075,side*Y*.4,lo-.06),(xf+.075,side*Y*.4,belt-.08)],'#303d42',2,.055)

def livery(d,m,belt,h,x0,x1):
    brand=m.get('brand','');L=m['length'];Y=m['width']/2
    if not brand:return
    for side in [-1,1]:
        y=side*(Y+.025)
        low=max(.50,belt-.36)
        d.poly([(x0,y,low),(x1,y,low),(x1+.12,y,belt-.07),(x0+.15,y,belt-.07)],GREEN,None,priority=.04)
        text='POLICE' if brand=='nbpd' else 'TRC'
        d.marking(text,-.20,y+side*.004,low+.035,1.12 if brand=='nbpd' else .75,.19,GOLD if brand=='trc' else '#e6e2cb')
        badge(d,brand,.65,y+side*.01,low+.16,.29)
    if brand=='nbpd':
        d.box(-.10,.08,-Y*.56,Y*.56,h+.01,h+.075,'#263a43')
        d.line([(.08,-Y*.55,h+.084),(.08,-.07,h+.084)],'#6fa4c7',2,.025)
        d.line([(.08,.07,h+.084),(.08,Y*.55,h+.084)],'#bf595b',2,.025)
    else:
        for side in [-1,1]:d.line([(L*.493,side*.26,belt-.30),(L*.493,side*.46,belt-.30)],'#527c79',1,.04)

def openings(d,m,door,belt,h,paint=None):
    if not door:return
    L=m['length'];Y=m['width']/2;p=paint or m['paint']
    for row in m['door_rows']:
        for side in [-1,1]:
            x=L*row;width=.84 if m['vehicle_class']!='heavy_transports' else .90
            a=door*math.pi*.43
            lo0=(x,side*Y,.37);lo1=(x-width*math.cos(a),side*(Y+width*math.sin(a)),.37)
            hi0=(x-.10,side*Y*.87,min(h-.09,belt+.38));hi1=(lo1[0]-.10,lo1[1]-side*.10,hi0[2])
            mid0=blend(lo0,hi0,.60);mid1=blend(lo1,hi1,.60)
            d.poly([lo0,lo1,mid1,mid0],p,INK,1,.04)
            d.poly([mid0,mid1,hi1,hi0],GLASS,shade(p,1.2),1,.05)

def trim(d,m,belt,cab1,h):
    Y=m['width']/2;L=m['length'];p=m['paint']
    for side in [-1,1]:
        y=side*(Y+.017)
        d.line([(-L*.36,y,belt-.03),(L*.32,y,belt-.06)],shade(p,1.15),1,.025)
        for row in m['door_rows']:
            x=row*L
            d.line([(x,y,.38),(x,y,belt-.10)],shade(p,.75),1,.014)
            d.line([(x-.25,y,belt-.13),(x-.09,y,belt-.13)],SILVER if m['price']>40000 else shade(p,1.3),1,.03)
        d.line([(cab1-.16,side*Y*.85,belt+.10),(cab1-.13,side*(Y+.08),belt+.14)],INK,1,.023)
        d.box(cab1-.25,cab1-.06,side*(Y+.07)-.05,side*(Y+.07)+.05,belt+.12,belt+.18,p)

def passenger(d,m,door=0):
    L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];b=m['body']
    legacy=b in ['vintage','lowrider','sedan','hatch']
    wagon=b=='shooting_brake';hatch=b in ['hatch','rally_hatch'];fast=b in ['fastback','ev_fastback']
    r=.33 if legacy else (.355 if m['price']<70000 else .38)
    belt=h*.69;axles=[-L*.325,L*.325]
    anchors=[(-L*.49,Y*.79,.29,belt-.10),(-L*.43,Y*.94,.24,belt-.01),(-L*.32,Y,.24,belt+.025),(-L*.10,Y*.97,.24,belt),(L*.22,Y*.97,.24,belt),(L*.35,Y,.25,belt-.01),(L*.44,Y*.94,.30,belt-.065),(L*.49,Y*.80,.35,belt-.14)]
    wheel_body(d,m,r,axles,anchors)
    cab0=-L*(.405 if wagon or hatch else (.35 if fast else .275));cab1=L*.215
    rear_rake=.29 if hatch else (.40 if wagon else (.92 if fast else .54))
    roof=m.get('roof_color',p)
    greenhouse(d,cab0,cab1,Y*.88,belt,h,p,.62 if not legacy else .48,rear_rake,3 if wagon else 2,roof)
    kind='luxury' if b in ['luxury','towncar'] else ('ev' if b=='ev_fastback' else ('fastback' if fast else 'modern'))
    lamps(d,L,Y,belt,p,kind,m.get('brand',''))
    trim(d,m,belt,cab1,h);livery(d,m,belt,h,-L*.30,L*.27)
    for side in [-1,1]:
        d.line([(L*.22,side*Y*.38,belt+.022),(L*.38,side*Y*.49,belt-.003)],shade(p,1.18),1,.02)
    if b=='rally_hatch':
        d.box(-L*.43,-L*.31,-Y*.88,Y*.88,h-.07,h-.025,'#25343c')
        for side in [-1,1]:
            d.poly([(-L*.32,side*(Y+.026),.35),(-L*.10,side*(Y+.026),.35),(L*.04,side*(Y+.026),belt-.16),(-L*.16,side*(Y+.026),belt-.16)],'#eee3cb',None,priority=.05)
    if b=='tuner':
        d.box(-L*.44,-L*.30,-Y*.83,Y*.83,belt+.16,belt+.205,'#27343c')
        for side in [-1,1]:d.line([(-L*.22,side*(Y+.025),.37),(L*.22,side*(Y+.025),.37)],'#798ecc',1,.03)
    if b=='lowrider':
        for side in [-1,1]:d.line([(-L*.46,side*(Y+.025),.41),(L*.45,side*(Y+.025),.41)],SILVER,2,.04)
    if b=='vintage':
        for side in [-1,1]:
            for yy in [.55,.79]:
                d.poly([(L*.495,side*Y*yy+.07*math.cos(a),belt-.17+.07*math.sin(a)) for a in [k*math.tau/12 for k in range(12)]],'#d7d9c6',SILVER,1,.07)
    if m['price']<8000:weather(d,m,.35,belt,False)
    openings(d,m,door,belt,h)

def utility(d,m,door=0):
    L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];b=m['body']
    pickup=b in ['pickup','crew_pickup','lifted_pickup','ev_pickup','prerunner']
    rugged=b in ['offroad','surplus_utility','lifted_pickup','prerunner']
    armored=b=='tactical_utility';coupe=b=='coupe_suv';r=.45 if rugged or armored else .405
    belt=h*.66;rear=-L*.33;front=L*.33
    anchors=[(-L*.49,Y*.84,.36,belt-.10),(-L*.41,Y*.97,.28,belt+.01),(-L*.30,Y,.28,belt+.035),(L*.20,Y*.985,.29,belt),(L*.34,Y,.30,belt-.025),(L*.45,Y*.93,.38,belt-.08),(L*.49,Y*.82,.42,belt-.13)]
    wheel_body(d,m,r,[rear,front],anchors)
    cab0=-L*(.045 if b=='pickup' else .17) if pickup else -L*.41;cab1=L*.235
    greenhouse(d,cab0,cab1,Y*.91,belt,h,p,.48 if pickup or armored else .60,.19 if pickup else (.56 if coupe else .35),1 if b=='pickup' else (2 if pickup else 3),m.get('roof_color',p))
    lamps(d,L,Y,belt,p,'ev' if b=='ev_pickup' else ('luxury' if b=='luxury_suv' else 'modern'),m.get('brand',''))
    trim(d,m,belt,cab1,h);livery(d,m,belt,h,-L*.29,L*.23)
    if pickup:
        # A visibly recessed cargo bed; pickups still cannot carry campaign resources.
        bed0=-L*.455;bed1=cab0-.06
        d.box(bed0,bed1,-Y*.78,Y*.78,belt+.035,belt+.065,'#283940')
        for side in [-1,1]:d.box(bed0,bed1,side*Y*.91-.065,side*Y*.91+.065,belt+.07,belt+.20,p)
        d.box(bed0-.035,bed0+.035,-Y*.91,Y*.91,belt+.07,belt+.20,p)
        for yy in [-.6,-.3,0,.3,.6]:d.line([(bed0+.08,yy*Y,belt+.076),(bed1-.08,yy*Y,belt+.076)],'#59676c',1,.035)
    else:
        for side in [-1,1]:d.line([(cab0+.38,side*Y*.73,h+.032),(cab1-.53,side*Y*.73,h+.032)],'#3c4a4e',1,.02)
    if rugged:
        for side in [-1,1]:d.box(-L*.18,L*.17,side*(Y+.06)-.055,side*(Y+.06)+.055,.37,.43,'#3e494c')
    if armored:
        for side in [-1,1]:
            y=side*(Y+.028)
            for x in [-L*.28,-L*.04,L*.20]:
                d.line([(x,y,belt-.32),(x,y,belt+.03)],'#68777c',1,.04)
            d.line([(-L*.27,y,.43),(L*.23,y,.43)],'#586970',2,.025)
        for side in [-1,1]:d.line([(L*.50,side*.60,.40),(L*.50,side*.60,belt-.11)],'#576870',2,.04)
    if b=='prerunner':
        for side in [-1,1]:
            d.line([(-L*.23,side*Y*.73,belt+.02),(cab0-.12,side*Y*.73,h-.10),(cab0+.08,side*Y*.73,h-.10)],'#252e32',2,.04)
            d.poly([(-L*.41,side*(Y+.035),.55),(-L*.20,side*(Y+.035),.55),(-L*.13,side*(Y+.035),belt-.07),(-L*.33,side*(Y+.035),belt-.07)],'#1c3035',None,priority=.04)
    if b=='surplus_utility':
        d.box(cab0+.22,-L*.03,-Y*.73,Y*.73,h-.03,h+.02,'#83826a')
        spare(d,-L*.507,.0,.95,.36,axis='x')
    if b=='offroad':
        for x in [-L*.28,-L*.16,-L*.04,L*.08]:d.line([(x,-Y*.72,h+.05),(x,Y*.72,h+.05)],'#424c4d',1,.025)
    if m['price']<20000:weather(d,m,.4,belt,False)
    openings(d,m,door,belt,h)

def spare(d,x,y,z,r,axis='z'):
    def pt(a,rr):return (x+rr*math.cos(a),y+rr*math.sin(a),z) if axis=='z' else (x,y+rr*math.cos(a),z+rr*math.sin(a))
    d.poly([pt(k*math.tau/20,r) for k in range(20)],'#263038','#687070',1,.04)
    d.poly([pt(k*math.tau/16,r*.50) for k in range(16)],'#65706b',INK,1,.05)
    for k in range(6):d.line([pt(0,0),pt(k*math.tau/6,r*.46)],'#a6a997',1,.06)

def weather(d,m,low,high,raider=False):
    rng=random.Random(m['id']);L=m['length'];Y=m['width']/2
    for _ in range(60 if raider else 18):
        x=rng.uniform(-L*.45,L*.4);z=rng.uniform(low,high);side=rng.choice([-1,1]);y=side*(Y+.028)
        d.line([(x,y,z),(x+rng.uniform(.06,.19),y,z+.025)],rng.choice(['#746857','#927c60','#725445']) if raider else shade(m['paint'],.78),1,.06)

def heavy(d,m,door=0):
    L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];b=m['body'];brand=m.get('brand','')
    raider=b in ['raider_bus','raider_rv'];bus=b in ['bus','raider_bus'];rv=b in ['rv','raider_rv'];van=b in ['panelvan','passengervan','highroof','command_van','luxury_shuttle'];box=b in ['boxtruck','cabover'];troop=b in ['military_truck','surplus_truck'];armored=b=='armored_transport'
    r=.49 if troop or armored or raider else .44
    front=L*(.335 if armored else .34);rear=-L*.33;axles=[rear,front]+([-L*.16] if b=='surplus_truck' else [])
    belt=(h*.63 if van or bus or rv or armored or b=='stepvan' else 1.30)
    cab_h=h if van or bus or rv or armored or b=='stepvan' else min(2.24,h)
    anchors=[(-L*.49,Y*.86,.40,belt-.12),(-L*.43,Y*.98,.36,belt),(-L*.30,Y,.36,belt),(L*.22,Y,.37,belt),(L*.40,Y*.97,.45,belt-.06),(L*.49,Y*.79,.54,belt-.17)]
    wheel_body(d,m,r,axles,anchors)
    if armored:
        cab0=-L*.44;cab1=L*.20
        greenhouse(d,cab0,cab1,Y*.94,belt,h,p,.47,.22,3,p,opaque_until=L*.015)
        for side in [-1,1]:
            y=side*Y*.94;ry=y*.83
            # Small protected rear windows inset in sloped armor, rather than a tall glass box.
            d.poly([(cab0,y,belt),(L*.015,y,belt),(L*.015,ry,h-.03),(cab0+.22,ry,h-.03)],shade(p,.92),None,priority=.04)
            for xx in [-L*.30,-L*.15]:
                z=belt+.25;yy=y+(ry-y)*(z-belt)/(h-belt)
                d.poly([(xx-.22,yy,z),(xx+.22,yy,z),(xx+.22,yy-side*.055,z+.23),(xx-.22,yy-side*.055,z+.23)],GLASS,'#779293',1,.05)
            d.marking('SWAT' if brand=='nbpd' else 'TRC',-L*.18,y+side*.02,belt+.055,.92,.21,'#d4dcc9' if brand=='nbpd' else GOLD)
        lamps(d,L,Y,belt,p,'modern',brand)
        livery(d,m,belt,h,-L*.28,L*.19)
        for side in [-1,1]:
            d.line([(L*.50,side*.62,.51),(L*.50,side*.62,belt-.18)],'#53656d',3,.05)
            d.line([(-L*.34,side*(Y+.07),.42),(L*.19,side*(Y+.07),.42)],'#556269',2,.05)
        d.line([(L*.505,-Y*.75,.58),(L*.505,Y*.75,.58)],'#61717a',2,.06)
    elif van or bus or rv or b=='stepvan':
        cab0=-L*.46;cab1=L*(.34 if van else .465)
        opaque=(L*(.09 if van else .26)) if ((van and b not in ['passengervan','luxury_shuttle']) or rv or b=='stepvan') else None
        greenhouse(d,cab0,cab1,Y*.96,belt,h,p,.52 if van else .37,.17,5 if bus else (4 if b in ['passengervan','luxury_shuttle'] else 3),m.get('roof_color',p),opaque_until=opaque)
        if van and b not in ['passengervan','luxury_shuttle'] or rv or b=='stepvan':
            for side in [-1,1]:
                y=side*Y*.965;ry=y*.83;stop=L*(.09 if van else .26)
                d.poly([(cab0,y,belt-.01),(stop,y,belt-.01),(stop,ry,h-.04),(cab0+.18,ry,h-.04)],shade(p,.94),None,priority=.04)
                for xx in ([L*-.32,L*-.06] if rv else ([L*-.24] if b in ['command_van','highroof'] else [])):
                    z=belt+.22;yy=y+(ry-y)*(z-belt)/(h-belt)
                    d.poly([(xx-.40,yy,z),(xx+.40,yy,z),(xx+.40,yy-side*.065,z+.32),(xx-.40,yy-side*.065,z+.32)],GLASS,'#7b8989',1,.055)
                d.line([(L*.05,y,belt),(L*.05,ry,h-.05)],shade(p,.63),1,.06)
        lamps(d,L,Y,belt,p,'ev' if b=='luxury_shuttle' else 'modern',brand)
        if bus or rv:
            for side in [-1,1]:
                yy=side*(Y+.028)
                d.line([(-L*.45,yy,belt-.15),(L*.40,yy,belt-.15)],'#73674f' if not raider else '#645542',2,.05)
                d.line([(-L*.45,yy,belt-.32),(L*.40,yy,belt-.32)],'#423e34',1,.05)
        if rv:
            d.box(-.8,.15,-.43,.43,h+.01,h+.15,'#777d71')
        if b=='command_van':
            # Stowed mast and low roof sensor pod, no weaponry.
            d.box(-L*.18,L*.08,-.46,.46,h+.01,h+.16,'#324543')
            d.poly([(-L*.27+.23*math.cos(a),.21*math.sin(a),h+.10+.08*math.sin(a)) for a in [k*math.tau/16 for k in range(16)]],'#76857c',INK)
            livery(d,m,belt,h,-L*.30,L*.27)
        if b=='luxury_shuttle':
            for side in [-1,1]:d.line([(-L*.39,side*(Y+.02),belt-.10),(L*.28,side*(Y+.02),belt-.10)],'#b29c6d',1,.03)
    else:
        cab0=L*(.16 if box else .10);cab1=L*.465
        greenhouse(d,cab0,cab1,Y*.94,belt,cab_h,p,.37,.14,1,p)
        lamps(d,L,Y,belt,p,'modern',brand)
        if box:
            boxpaint='#d0c6ae' if b=='boxtruck' else '#b5beb9'
            shell(d,[(-L*.49,Y*.97,.61,h-.05),(-L*.46,Y,.61,h),(L*.105,Y,.61,h),(L*.14,Y*.93,.66,h-.10)],boxpaint)
            for side in [-1,1]:
                yy=side*(Y+.025)
                d.line([(-L*.45,yy,.77),(L*.10,yy,.77)],'#738078',1,.025)
                if b=='boxtruck':d.line([(-L*.43,yy,h*.58),(L*.09,yy,h*.58)],'#b4753d',3,.04)
            for z in [.78+i*.16 for i in range(int((h-.92)/.16))]:d.line([(-L*.495,-Y*.9,z),(-L*.495,Y*.9,z)],'#83918c',1,.04)
        else:
            bed1=L*.07
            d.box(-L*.47,bed1,-Y,Y,.64,1.54,shade(p,.82))
            shell(d,[(-L*.47,Y*.90,1.52,h-.15),(-L*.43,Y*.94,1.52,h),(bed1-.06,Y*.94,1.52,h),(bed1,Y*.88,1.52,h-.15)],shade(p,1.08))
            for side in [-1,1]:
                for xx in [-L*.40,-L*.23,-L*.06]:d.line([(xx,side*(Y+.01),.71),(xx,side*(Y+.01),1.48)],'#45534c',2,.03)
            if brand:livery(d,m,1.43,cab_h,-L*.39,L*.04)
    if raider:raider_details(d,m,belt)
    elif m['price']<20000:weather(d,m,.5,belt,False)
    openings(d,m,door,belt,cab_h)

def raider_details(d,m,belt):
    L=m['length'];Y=m['width']/2;h=m['height'];bus=m['body']=='raider_bus'
    # Practical scavenged additions: racks, repaired panels, screens and luggage.
    for side in [-1,1]:
        y=side*(Y+.034)
        for xx,ww,zz,col in [(-L*.32,.60,.76,'#716e57'),(-L*.04,.45,.92,'#865640'),(L*.22,.34,.68,'#696e63')]:
            d.poly([(xx-ww,y,zz),(xx+ww,y,zz+.06),(xx+ww,y,zz+.38),(xx-ww,y,zz+.34)],col,'#383c35',1,.06)
            for u in [-ww*.86,ww*.86]:
                for v in [.06,.28]:d.line([(xx+u,y,zz+v),(xx+u+.025,y,zz+v)],'#c2ac82',1,.08)
        if bus:
            # Bars follow the sloped window plane; they do not float above the roof.
            for xx in [-L*.34,-L*.24,-L*.14,-L*.04,L*.06,L*.16,L*.26]:
                d.line([(xx,side*Y*.965,belt+.07),(xx,side*Y*.81,h-.14)],'#766e58',1,.09)
        d.line([(-L*.40,side*Y*.73,h+.07),(L*.11,side*Y*.73,h+.07)],'#4e534a',2,.025)
    for xx in [-L*.39,-L*.2,.0]:d.line([(xx,-Y*.73,h+.07),(xx,Y*.73,h+.07)],'#4e534a',1,.025)
    if bus:
        d.box(-L*.34,-L*.21,-.68,-.11,h+.10,h+.37,'#766e54')
        d.box(-L*.29,-L*.14,.15,.61,h+.10,h+.29,'#805646')
        spare(d,-L*.05,.05,h+.14,.37)
    else:
        # Canvas luggage roll, reclaimed solar panel, ladder and mismatched spare.
        shell(d,[(-L*.32,.35,h+.05,h+.25),(-L*.26,.43,h+.05,h+.38),(-L*.16,.34,h+.05,h+.25)],'#8b8063')
        d.box(-L*.09,L*.09,-.69,.12,h+.06,h+.105,'#243d48')
        for xx in [-L*.075,-L*.03,L*.015,L*.06]:d.line([(xx,-.65,h+.115),(xx,.08,h+.115)],'#617c84',1,.025)
        spare(d,-L*.506,-.12,1.04,.43,'x')
    for yy in [Y*.56,Y*.76]:d.line([(-L*.505,yy,.56),(-L*.505,yy,h+.06)],'#7d7e66',2,.035)
    for zz in [.65+i*.26 for i in range(int((h-.5)/.26))]:d.line([(-L*.51,Y*.56,zz),(-L*.51,Y*.76,zz)],'#88886c',1,.045)
    weather(d,m,.54,belt,True)

def special_car(d,m,door=0):
    if m['body']=='roadster':
        # Sculpted sports body with its open cockpit modeled as an actual recess.
        mm=dict(m,body='grandtourer',open_top=True)
        exotic(d,mm,door)
        L=m['length'];Y=m['width']/2
        d.box(-L*.22,L*.065,-Y*.70,Y*.70,.78,.81,'#202c32')
        for side in [-1,1]:
            d.box(-L*.16,-L*.10,side*.38-.16,side*.38+.16,.81,1.025,'#a27856')
            d.line([(-L*.16,side*.38-.19,1.03),(-L*.16,side*.38-.15,1.12),(-L*.16,side*.38+.15,1.12),(-L*.16,side*.38+.19,1.03)],SILVER,1,.03)
        d.poly([(L*.11,-Y*.73,.81),(L*.11,Y*.73,.81),(-.02,Y*.61,1.14),(-.02,-Y*.61,1.14)],GLASS,SILVER,1,.025)
    else:
        mm=dict(m,body='exotic_curved' if m['body']=='hypercar' else m['body'])
        exotic(d,mm,door)
        if m['body']=='hypercar':
            L=m['length'];Y=m['width']/2
            for side in [-1,1]:
                d.line([(-L*.28,side*(Y+.014),.40),(L*.30,side*(Y+.014),.37)],'#e7b44d',1,.06)
            d.box(-L*.43,-L*.30,-Y*.84,Y*.84,.93,.97,'#263740')

def render(d,m,door=0):
    if m['vehicle_class']=='two_wheelers':
        mm=dict(m)
        if m['body']=='electric_trail':mm.update(body='dualsport',electric=True)
        if m['body']=='cafe':mm.update(body='cruiser',paint='#916247',cafe_style=True)
        motorcycle(d,mm)
        if m['body']=='electric_trail':
            shell(d,[(-.17,.12,.38,.76),(.17,.14,.39,.78),(.29,.1,.51,.77)],'#293d40')
            for side in [-1,1]:d.line([(-.07,side*.16,.45),(.08,side*.16,.69),(.17,side*.16,.63)],'#b2dbbc',1,.03)
        if m['body']=='cafe':
            shell(d,[(-.69,.10,.78,.86),(-.49,.15,.76,.91),(-.34,.12,.74,.82)],'#754c38')
        return
    if m['vehicle_class']=='heavy_transports':heavy(d,m,door)
    elif m['vehicle_class']=='utility_vehicles':utility(d,m,door)
    elif m['body'] in ['sportcoupe','grandtourer','exotic_curved','hypercar','roadster']:special_car(d,m,door)
    else:passenger(d,m,door)
