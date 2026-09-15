"""Entirely new scores after owner rejected audition01. No old audio/notes reused.
Tempo exactly 0.8 * original BPM. Preview only; existing game assets untouched.
"""
import json,sys
from pathlib import Path
import numpy as np
from scipy.signal import butter,sosfilt
import engine as E

sampled_render=E.render_track

def shape(x,attack=.006,release=.1):
    a=min(len(x)//2,int(attack*E.SR)); r=min(len(x)//2,int(release*E.SR))
    x[:a]*=np.linspace(0,1,a); x[-r:]*=np.linspace(1,0,r)
    return x

def custom_render(s,tr):
    if tr.program>=0: return sampled_render(s,tr)
    n=int(s.duration*E.SR); out=np.zeros(n); rng=np.random.default_rng(670+s.number)
    for b,key,dur,vel in tr.notes:
        sec=max(.15,dur*s.beat); t=np.arange(int(sec*E.SR))/E.SR
        freq=440*2**((key-69)/12); gain=(vel/127)**1.1
        if tr.program==-1: # deep overdriven 808: clear sub plus audible dirty upper harmonics
            freq_curve=freq*(1+.045*np.exp(-t/.04))
            phase=2*np.pi*np.cumsum(freq_curve)/E.SR
            osc=np.sin(phase)+.20*np.sin(2*phase)+.13*np.sin(3*phase)
            x=np.tanh(osc*2.4)*.22*np.exp(-t/(sec*.72))*gain
        elif tr.program==-2: # physical-feeling heavy kick, fast drop and dry low thump
            phase=2*np.pi*(47*t+4.2*(1-np.exp(-t/.025)))
            x=(np.sin(phase)*np.exp(-t/.19)+rng.normal(size=len(t))*.10*np.exp(-t/.008))*.49*gain
        elif tr.program==-3: # low cracked snare, deliberately no bright dance clap
            noise=sosfilt(butter(2,[650,5300],btype='bandpass',fs=E.SR,output='sos'),rng.normal(size=len(t)))
            x=(.20*noise*np.exp(-t/.10)+.23*np.sin(2*np.pi*155*t)*np.exp(-t/.055))*gain
        elif tr.program==-4: # restrained dissonant low drone / pressure, not a hummable tune
            x=(np.sin(2*np.pi*freq*t)+.23*np.sin(2*np.pi*freq*1.059*t)+.19*np.sin(2*np.pi*freq*1.501*t))*.065
            x*=gain*(.74+.09*np.sin(2*np.pi*.32*t))
            shape(x,.7,.65)
        elif tr.program==-5: # struck scrap iron, damped inharmonic partials
            x=sum(np.sin(2*np.pi*freq*r*t)*np.exp(-t/(.11+.06*i))/(i+1) for i,r in enumerate([1,1.47,2.19,3.72,5.31]))*.15*gain
        elif tr.program==-6: # amplifier rumble / saw bass, filtered and detuned
            phase=(freq*t)%1
            osc=2*phase-1 + .45*(2*((freq*1.004*t)%1)-1)
            x=sosfilt(butter(2,1050,fs=E.SR,output='sos'),np.tanh(osc*2.7))*.17*gain
        else: raise ValueError(tr.program)
        shape(x,.003,.07)
        at=round(b*s.beat*E.SR); count=min(len(x),n-at)
        if count>0: out[at:at+count]+=x[:count]
    out=E.filt(out,tr.hp,'highpass') if tr.hp else out
    if tr.lp: out=E.filt(out,tr.lp,'lowpass')
    stereo=np.column_stack([out,out])
    if tr.room:
        for sec,g in [(.041,.14),(.089,.1),(.151,.08),(.239,.05),(.373,.03)]:
            d=int(sec*E.SR); stereo[d:]+=np.column_stack([out[:-d],out[:-d]])*g*tr.room
    return stereo*tr.level

E.render_track=custom_render

def drums(s,pattern,weight=1,metal=False):
    kick=s.track('sub kick',-2,weight,hp=28,lp=6500,room=0)
    sn=s.track('cracked snare',-3,weight*.8,hp=110,lp=5700,room=.8)
    hats=s.track('closed hat / distant cymbal',0,.31,hp=2700,lp=7700,room=.3,drum=True)
    for bar in range(s.bars):
        b=bar*s.meter
        kicks,snares,hs=pattern[bar%len(pattern)]
        for p in kicks: kick.n(b+p,36,.48,117 if p==0 else 100)
        for p in snares: sn.n(b+p,38,.36,107)
        for i,p in enumerate(hs): hats.n(b+p,42,.07,54 if i%2==0 else 32)
        if bar in [0,4] and metal: hats.n(b,49,1.3,78)
    return kick,sn,hats

SLOW=[([0,1.5],[2],[.5,1.5,2.5,3.5]),([0,2.75,3.5],[2],[.5,1.5,3.25,3.5])]
STALK=[([0,2.5],[2],[1,3.5]),([0,1.75],[2],[.5,2.75,3.5])]
CRUSH=[([0,.75],[2],[0,1,2,3]),([0,1.5,3.25],[2],[0,1.5,2.5,3.5])]
MARCH=[([0,1.5,2.75],[2],[0,.5,1.5,2.5,3.5]),([0,.75,3.5],[2],[0,1,1.75,2.5,3.75])]
TRIPLE=[([0],[2],[1.5]),([0,1.5],[2],[.5,2.5])]

def floor(s,root,kind='sub',level=1):
    t=s.track('sub pressure' if kind=='sub' else 'distorted low bass',-1 if kind=='sub' else -6,level,hp=24,lp=1600,room=0)
    for bar in range(s.bars):
        b=bar*s.meter
        # Pedal-centered with occasional semitone pressure, never a walking/funky bass line.
        shift=1 if bar%4==3 else (0 if bar%4!=2 else -2)
        t.n(b,root+shift,1.65,113)
        t.n(b+2.5 if s.meter==4 else b+1.5,root+shift,.85,95)
        if s.meter==4 and bar%2: t.n(b+3.5,root,.35,92)
    return t

def drone(s,root,level=.4):
    t=s.track('low unresolved pressure',-4,level,hp=30,lp=1300,room=1)
    for b in range(0,s.bars,2): t.n(b*s.meter,root,2*s.meter-.1,84)
    return t

def voice(s,label,pr,level=.65,pan=0,lp=3600,room=1,delay=0,drive=0):
    return s.track(label,pr,level,pan,hp=95,lp=lp,room=room,delay=delay,drive=drive)

def motif(s,tr,root,events,cycle=4):
    # events: beat within phrase, interval, duration, velocity. New authored motifs only.
    for bar in range(0,s.bars,cycle):
        for pos,interval,dur,vel in events:
            if bar*s.meter+pos<s.bars*s.meter: tr.n(bar*s.meter+pos,root+interval,dur,vel)

def stab(s,tr,root,intervals,times=(0,2.75),gate=.35):
    for bar in range(s.bars):
        b=bar*s.meter; shift=1 if bar%4==3 else 0
        for i,p in enumerate(times): tr.chord(b+p,[root+shift+x for x in intervals],gate,100-i*9,strum=.006)

def all_songs():
    songs=[]
    def song(id,name,vibe,old,meter=4,bars=8):
        s=E.Song(len(songs)+1,id,name,vibe,round(old*.8,2),meter,bars)
        s.original_bpm=old; songs.append(s); return s

    s=song('eastex','Eastex 44’s','Cold Houston menace · blown-out sub · haunted keys',80)
    drums(s,SLOW); floor(s,29,level=1.25); drone(s,29,.55)
    t=voice(s,'chopped low piano',0,.7,lp=2300,room=1.5,delay=.25)
    motif(s,t,53,[(0,0,.35,104),(.75,1,.25,77),(3,0,.5,84),(6,-5,.55,79),(8,0,.6,98),(11,1,.22,77),(14,-1,.7,91)])
    t=voice(s,'buried organ',16,.21,pan=-.25,lp=1500)
    stab(s,t,41,[0,7,13],times=(0,),gate=2.4)

    s=song('calle_ocho','Calle Ocho','After-midnight lowrider threat · dirty guitar · deep bass',88)
    drums(s,STALK); floor(s,28,level=1.1)
    t=voice(s,'baritone guitar',27,1.05,pan=-.3,lp=2500,room=1,delay=.18,drive=3)
    motif(s,t,40,[(0,0,.45,110),(1.5,7,.3,92),(3,1,.4,103),(4,0,1.4,112),(7,-1,.6,90),(8,0,.35,108),(10,6,.6,91),(12,1,.5,105),(14,0,1.6,113)])
    o=voice(s,'suffocated organ',16,.27,pan=.28,lp=1900)
    stab(s,o,52,[0,3,6],times=(1.25,),gate=1.25)

    s=song('ventresca','Ventresca Family','Back-room intimidation · wounded trumpet · black organ',98)
    drums(s,STALK,.72); floor(s,33,level=.85); drone(s,33,.75)
    t=voice(s,'low muted trumpet',59,.69,lp=2600,room=1.5,delay=.17)
    motif(s,t,57,[(0,0,1.4,83),(3,-1,.65,72),(6,-5,1.8,79),(9,0,.8,84),(12,1,.7,75),(14,0,1.3,80)])
    o=voice(s,'ominous low organ',16,.42,pan=-.2,lp=1800,drive=2)
    stab(s,o,45,[0,7,10,13],times=(0,),gate=3.3)

    s=song('ravicci','Ravicci Family','Funeral procession · low piano · suffocating strings',90,3,10)
    drums(s,TRIPLE,.65); floor(s,26,level=.95)
    t=voice(s,'funeral piano',0,.95,lp=3100,room=2.3,delay=.16)
    motif(s,t,50,[(0,0,1.7,104),(4,1,.65,87),(6,-5,1.3,97),(9,-1,1.8,91)],cycle=4)
    c=voice(s,'low chamber pressure',48,.58,pan=.2,lp=2800,room=1.5)
    stab(s,c,38,[0,7,13],times=(0,),gate=2.85)
    t=voice(s,'cello scrape',42,.48,pan=-.3,lp=2400,room=1.6)
    motif(s,t,38,[(0,0,4.7,85),(6,-1,4.9,93)],cycle=4)

    s=song('orlov','Orlov Bratva','Concrete brutality · cold bass ostinato · corroded guitar',128,bars=12)
    drums(s,CRUSH,.95,True); floor(s,28,'grit',.85)
    t=voice(s,'driving pick bass',34,1.1,lp=2100,drive=4)
    motif(s,t,28,[(0,0,.42,116),(.75,0,.45,102),(1.5,0,.35,99),(2.5,1,.5,110),(3.5,0,.3,106),(4,0,.8,115),(5.5,-2,.45,102),(6.5,0,.8,117)],cycle=2)
    g=voice(s,'cold wire guitar',27,.82,pan=-.36,lp=2900,room=1.2,delay=.38,drive=2)
    motif(s,g,52,[(0,0,1.6,87),(3,1,.8,94),(6,6,1.3,91),(8,0,1.4,95),(11,-1,.7,89),(14,-5,1.4,87)])

    s=song('zangyaku','Zangyaku','Half-time industrial violence · jagged cuts · sub impact',142,bars=12)
    drums(s,MARCH,1.12,True); floor(s,28,'grit',1.0)
    g=voice(s,'cutting guitar',30,.78,pan=-.32,lp=4100,drive=3)
    for bar in range(s.bars):
        for p in ([0,.75,2.75] if bar%2==0 else [0,1.25,1.75,3.5]): g.chord(bar*4+p,[40,47,53 if bar%4==3 else 52],.22,116)
    m=voice(s,'struck steel',-5,.7,lp=5200,room=1.6)
    motif(s,m,48,[(1.5,0,.35,92),(4,6,.6,113),(7.5,-1,.4,78),(10,0,.6,92),(14.75,1,.3,91)])

    s=song('bitian','Bìtiān','Rain-black crime scene · hollow keys · crushing trip-hop',82)
    drums(s,STALK,.98); floor(s,30,level=1.15); drone(s,30,.48)
    k=voice(s,'hollow electric piano',4,.7,pan=-.24,lp=2400,room=1.4,delay=.27)
    stab(s,k,42,[0,3,7,13],times=(0,),gate=1.7)
    t=voice(s,'isolated plucked wire',107,.58,pan=.34,lp=3300,room=1.8,delay=.36)
    motif(s,t,54,[(.5,0,.45,83),(3,1,.25,76),(6,-5,.8,82),(8.5,0,.45,90),(12,-1,.65,75),(15,-5,.5,85)])

    s=song('sierra_roja','Cártel de Sierra Roja','Execution corrido · low picked strings · threatening brass',104)
    drums(s,STALK,.86); floor(s,26,level=1.0)
    g=voice(s,'dark steel strings',25,1.0,pan=-.2,lp=3400,room=1.2,drive=1.5)
    motif(s,g,38,[(0,0,.8,116),(1.5,7,.45,97),(3,1,.45,108),(4,0,1.3,111),(6.5,-1,.45,102),(8,0,.8,116),(10,6,.4,101),(12,1,.7,111),(14,0,1.5,117)])
    b=voice(s,'low brass warning',61,.52,pan=.2,lp=2300,room=1.3)
    stab(s,b,38,[0,7,13],times=(0,),gate=1.4)
    g=voice(s,'nylon response',24,.9,pan=.3,lp=3100,room=1.4)
    motif(s,g,50,[(2,1,.6,96),(6,0,.65,87),(10,-1,.75,100),(14,-5,1.2,104)])

    s=song('mcallister','McAllister Holdings, Inc.','Old-money cruelty · baritone blues · cold piano',100)
    drums(s,STALK,.78); floor(s,31,'grit',.7); drone(s,31,.65)
    g=voice(s,'baritone blues guitar',26,1.2,pan=.26,lp=2600,room=1.6,drive=2.6)
    motif(s,g,43,[(0,0,1.2,113),(3,6,.7,102),(5,5,1.1,92),(8,0,1.7,110),(11,-1,.8,103),(14,-5,1.3,98)])
    p=voice(s,'low piano verdict',0,.9,pan=-.28,lp=2500,room=1.8)
    stab(s,p,43,[0,3,10],times=(0,),gate=2.25)

    s=song('mercer44','Mercer 44’s','Hostile Southern weight · distorted 808 · black brass',86)
    drums(s,SLOW,1.12); floor(s,29,level=1.4)
    b=voice(s,'threat brass',61,.62,lp=2800,room=1.2,drive=2)
    motif(s,b,41,[(0,0,.9,114),(1.5,0,.3,101),(4,1,.6,109),(7,0,.5,108),(8,-2,.9,111),(11,-2,.3,94),(12,1,.65,115),(15,0,.45,112)])
    p=voice(s,'cold piano chime',0,.72,pan=.3,lp=2600,room=1.8,delay=.33)
    motif(s,p,53,[(.5,0,.5,83),(4.5,-1,.5,83),(8.5,-5,.7,84),(12.5,1,.4,92)])

    s=song('wm_corp','Whittaker–McAllister Corporation','Oil-black Southern sludge · corrupt power · slow violence',102)
    drums(s,CRUSH,1.0,True); floor(s,28,'grit',.86)
    for pan in [-.48,.48]:
        g=voice(s,'thick baritone amp',29,.81,pan,lp=3500,room=.7,drive=5)
        for bar in range(s.bars):
            r=40+(1 if bar%4==3 else 0)
            for p,d in [(0,1.2),(2.5,.55),(3.5,.28)]: g.chord(bar*4+p+(pan>0)*.019,[r,r+7],d,113)
    o=voice(s,'dirty organ pressure',16,.35,lp=1800,room=1.3,drive=2)
    stab(s,o,40,[0,7,13],times=(0,),gate=3.5)

    s=song('union_sur','La Unión del Sur','Cartel street menace · heavy percussion · threatening strings',94)
    drums(s,SLOW,1.05); floor(s,26,level=1.2)
    g=voice(s,'choked nylon riff',24,1.13,pan=-.3,lp=2900,room=1.3,drive=1.4)
    motif(s,g,50,[(0,0,.5,109),(1.5,1,.3,99),(3,-5,.5,102),(4,0,.8,111),(7,-1,.55,99),(8,0,.4,112),(10,6,.4,91),(12,1,.6,108),(14,0,1.1,114)])
    b=voice(s,'brass threat',61,.48,lp=2300,room=1.2)
    stab(s,b,38,[0,7,13],times=(0,),gate=.7)
    hand=s.track('low hand percussion',0,.48,hp=90,lp=3300,room=.5,drum=True)
    for bar in range(s.bars):
        for p,k in [(1.25,64),(2.75,63),(3.5,64)]: hand.n(bar*4+p,k,.2,89)

    s=song('lombardia','L’Ordine di Lombardia','Imperial dread · crushing brass · fatal strings',84)
    drums(s,CRUSH,.9); floor(s,24,level=1.0)
    c=voice(s,'low orchestral weight',48,.82,lp=3200,room=2)
    stab(s,c,36,[0,7,13],times=(0,),gate=3.7)
    b=voice(s,'doom brass',61,.69,lp=2800,room=1.6,drive=2)
    motif(s,b,36,[(0,0,1.7,112),(4,1,1.25,108),(8,-2,1.5,106),(12,0,2.3,115)])
    c=voice(s,'cello knife',42,.55,pan=.35,lp=2900,room=2)
    motif(s,c,48,[(2,1,2.8,95),(7,0,2.8,91),(12,-1,3,98)])

    s=song('sand_raiders','Raiders of the Sand','Rust, violence and rot · broken metal · detuned grime',76)
    drums(s,CRUSH,1.03); floor(s,27,'grit',1.0); drone(s,27,.7)
    g=voice(s,'ruined guitar',30,.7,pan=-.33,lp=2200,room=1.5,delay=.43,drive=4)
    motif(s,g,39,[(0,0,1.3,113),(3,6,.6,98),(5,1,1.1,109),(8,0,1.7,115),(11,-1,.65,106),(14,6,.85,112)])
    metal=voice(s,'scrap iron strikes',-5,.8,pan=.3,lp=4100,room=1.7)
    motif(s,metal,42,[(1.25,0,.8,110),(4.75,6,.4,93),(7.5,-1,.7,101),(10.25,1,.6,109),(13.5,6,.65,104)])

    s=song('saffar','Majmu’at al-Saffar','Desert-night dread · low plucked strings · merciless drums',90)
    drums(s,STALK,.86); floor(s,26,level=1.08); drone(s,26,.7)
    g=voice(s,'low plucked threat',24,1.3,pan=-.2,lp=2900,room=1.6,delay=.16)
    motif(s,g,50,[(0,0,.8,113),(1.5,1,.35,101),(3,4,.65,104),(5,1,.8,102),(8,0,1.2,114),(11,-1,.55,101),(13,1,.5,108),(14.5,0,1,114)])
    p=voice(s,'distant struck strings',15,.36,pan=.35,lp=2500,room=2,delay=.3)
    motif(s,p,50,[(2,1,.8,83),(6,0,1,89),(10,-1,.7,81),(14,-5,1.1,88)])
    h=s.track('deep hand drum pulse',0,.66,hp=65,lp=2600,room=.6,drum=True)
    for bar in range(s.bars):
        for p,k,v in [(0,64,113),(1.25,63,81),(2.5,64,106),(3.5,62,81)]: h.n(bar*4+p,k,.2,v)

    s=song('kurgan','The Kurgan Group','Mechanized brutality · steel impacts · low marching weight',96)
    drums(s,MARCH,1.15); floor(s,28,'grit',1.12)
    b=voice(s,'military low brass',61,.66,lp=2600,room=.8,drive=3)
    stab(s,b,40,[0,7,13],times=(0,1.5),gate=.5)
    m=voice(s,'machine impacts',-5,.63,lp=2700,room=.8)
    motif(s,m,35,[(.75,0,.3,108),(3.5,1,.4,112),(4.75,0,.4,107),(7.25,-1,.4,116)],cycle=2)
    drone(s,28,.56)

    s=song('ashford_crane','The Ashford-Crane Collective','Rotten aristocracy · decaying piano · chamber horror',96,3,10)
    drums(s,TRIPLE,.60); floor(s,25,level=.85); drone(s,25,.75)
    p=voice(s,'decaying salon piano',0,1.05,lp=2800,room=2.6,delay=.28)
    motif(s,p,49,[(0,0,1.5,103),(3,1,.7,90),(5,-1,.65,78),(6,-6,1.7,98),(9,0,1.9,104)],cycle=4)
    c=voice(s,'unresolved chamber strings',48,.52,pan=.23,lp=2400,room=2.2)
    stab(s,c,37,[0,6,13],times=(0,),gate=2.85)
    p=voice(s,'distant piano fracture',0,.44,pan=-.4,lp=2400,room=2.8)
    motif(s,p,73,[(2,1,.5,67),(8,0,.7,74)],cycle=4)

    s=song('blacktop','Blacktop Apostles MC','Punishing funeral doom · filthy low guitars · absolute weight',68,bars=6)
    drums(s,CRUSH,1.13,True); floor(s,25,'grit',1.12)
    for pan in [-.58,.58]:
        g=voice(s,'filthy doom wall',30,1.02,pan,lp=3200,room=.9,drive=6)
        for bar in range(s.bars):
            r=37+(1 if bar%3==2 else 0)
            for p,d in [(0,1.65),(2.5,.7),(3.5,.28)]: g.chord(bar*4+p+(pan>0)*.016,[r,r+7,r+12],d,121)
    g=voice(s,'feedback wound',29,.48,lp=2600,room=2.1,delay=.3,drive=4)
    motif(s,g,49,[(0,0,5.5,97),(7,1,4.5,98),(12,6,3.8,93)])
    return songs

if __name__=='__main__':
    selected=set(sys.argv[1:])
    for s in all_songs():
        if not selected or s.id in selected:
            assert s.bpm==round(s.original_bpm*.8,2)
            E.render(s)
    rows=[json.loads(p.read_text()) for p in sorted(E.OUT.glob('*.json'))]
    (E.ROOT/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
