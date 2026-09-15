"""DEAD STREET: original faction auditions, v1. NOT installed game audio.
Reproduce with Python 3.12, numpy, scipy, tinysoundfont 0.3.7 and FFmpeg.
Instrument bank: GeneralUser GS 2.0.3; see dependencies/GeneralUser_LICENSE.txt.
Every score below is original. No borrowed songs, vocals, or generated speech.
"""
from pathlib import Path
from dataclasses import dataclass, field
import json, math, hashlib, subprocess, sys
import numpy as np
from scipy.signal import butter, sosfilt
from scipy.io import wavfile
import tinysoundfont

ROOT = Path(__file__).resolve().parent
SR = 44100
SF = ROOT / 'dependencies/GeneralUser-GS.sf2'
OUT = ROOT / 'previews'
OUT.mkdir(exist_ok=True)

@dataclass
class Track:
    label: str
    program: int
    level: float = 1.0
    pan: float = 0.0
    hp: float = 45
    lp: float = 12000
    room: float = .1
    delay: float = 0
    drive: float = 0
    drum: bool = False
    notes: list = field(default_factory=list)
    def n(self, beat, pitch, length=.45, vel=85):
        self.notes.append([round(float(beat),5), int(pitch), round(float(length),5),int(vel)])
    def chord(self, beat, pitches, length=1.5, vel=70, strum=0):
        for i,p in enumerate(pitches): self.n(beat+i*strum,p,length,vel-(i%3)*3)

class Song:
    def __init__(self,number,id,name,vibe,bpm,meter=4,bars=8):
        self.number=number; self.id=id; self.name=name; self.vibe=vibe
        self.bpm=bpm; self.meter=meter; self.bars=bars; self.tracks=[]
        self.beat=60/bpm; self.duration=bars*meter*self.beat+1.8
    def track(self,*args,**kwargs):
        t=Track(*args,**kwargs); self.tracks.append(t); return t

def filt(x,f,kind): return sosfilt(butter(2,f,kind,fs=SR,output='sos'),x,axis=0)

def render_track(song,t):
    synth=tinysoundfont.Synth(gain=-8,samplerate=SR)
    sf=synth.sfload(str(SF))
    synth.program_select(0,sf,128 if t.drum else 0,t.program,is_drums=t.drum)
    synth.control_change(0,10,int(64+t.pan*48))
    events=[]; rng=np.random.default_rng(1700+song.number*13+len(t.label))
    for beat,pitch,dur,vel in t.notes:
        # Small timing/velocity differences retain each deliberately authored rhythm.
        start=max(0,int((beat*song.beat+rng.uniform(-.003,.003))*SR))
        end=start+max(128,int(dur*song.beat*SR))
        velocity=max(1,min(127,vel+int(rng.integers(-3,4))))
        events.extend([(start,1,pitch,velocity),(end,0,pitch,0)])
    events.sort()
    n=int(song.duration*SR); x=np.zeros((n,2),np.float32); pos=0
    for at,on,pitch,vel in events+[(n,0,0,0)]:
        at=min(n,at)
        if at>pos:
            x[pos:at]=np.frombuffer(synth.generate_simple(at-pos),np.float32).reshape(-1,2)
            pos=at
        if on: synth.noteon(0,pitch,vel)
        else: synth.noteoff(0,pitch)
        if pos>=n: break
    synth.sfunload(sf)
    if t.hp: x=filt(x,t.hp,'highpass')
    if t.drive:
        # Cabinet-filtered saturation, with bass kept on a separate clean track.
        x=np.tanh(x*t.drive)/max(1,t.drive*.35)
    if t.lp: x=filt(x,t.lp,'lowpass')
    dry=x.copy()
    if t.delay:
        for rep in range(1,4):
            d=int(SR*song.beat*.75*rep)
            x[d:]+=dry[:-d,::-1]*(t.delay**rep)
    if t.room:
        # Short, diffuse stereo room; no reverb cloud over the rhythm.
        wet=filt(dry,5200,'lowpass')
        for sec,g in [(.037,.26),(.053,.22),(.079,.19),(.113,.16),(.163,.12),(.229,.08),(.307,.055)]:
            d=int(SR*sec); x[d:]+=wet[:-d,::-1]*t.room*g
    return x*t.level

def drums(s,style='hiphop',gain=1,kit=0):
    d=s.track('drums',kit,gain,hp=35,lp=11500,room=.12,drum=True)
    for bar in range(s.bars):
        b=bar*s.meter
        if style=='waltz':
            for p,k,v in [(0,36,64),(1,38,43),(2,38,47),(0,51,43),(1,51,33),(2,51,38)]: d.n(b+p,k,.14,v)
            continue
        if style=='corridos':
            for p,k,v in [(0,36,82),(1,37,80),(2,36,73),(3,37,86),(1.5,69,44),(3.5,69,52)]: d.n(b+p,k,.15,v)
            continue
        if style=='doom': kicks=[0,1.5,3.5] if bar%2 else [0,.75]; snares=[2]; hats=[0,1,2,3]
        elif style=='postpunk': kicks=[0,1.5,2,2.75]; snares=[1,3]; hats=np.arange(0,4,.5)
        elif style=='breakbeat': kicks=[0,.75,2,2.5,3.75]; snares=[1,2.75,3]; hats=np.arange(0,4,.25)
        elif style=='industrial': kicks=[0,1.5,2,3.25]; snares=[1,3]; hats=np.arange(0,4,.5)
        elif style=='latin': kicks=[0,1.5,2.5]; snares=[1,3]; hats=np.arange(0,4,.5)
        elif style=='jazz': kicks=[0,2]; snares=[1,3]; hats=[0,1,1.66,2,3,3.66]
        elif style=='rock': kicks=[0,.75,2,2.5]; snares=[1,3]; hats=np.arange(0,4,.5)
        else: kicks=[0,1.75,2.5] if bar%2==0 else [0,.75,2.25,3.5]; snares=[1,3]; hats=np.arange(0,4,.5)
        for p in kicks: d.n(b+p,36,.12,97 if p in [0,2] else 84)
        for p in snares: d.n(b+p,38,.18,84 if style!='doom' else 105)
        for i,p in enumerate(hats):
            swing=.08 if style in ['hiphop','jazz','latin'] and i%2 else 0
            k=51 if style=='jazz' else (46 if i==len(hats)-1 and bar%2==1 else 42)
            d.n(b+p+swing,k,.10 if k==42 else .35,46+(i%2==0)*14)
        if style in ['hiphop','breakbeat','rock'] and bar%2==1: d.n(b+2.75,38,.07,34)
        if style in ['latin','arabic']:
            for p,k,v in [(0,64,72),(.75,62,64),(1.5,63,82),(2.25,64,69),(3.5,62,78)]: d.n(b+p,k,.16,v)
        if style=='industrial':
            for p in [.5,1.75,2.5,3.5]: d.n(b+p,56,.12,49)
        if bar in [0,4] and style in ['rock','doom','postpunk','breakbeat']: d.n(b,49,1.5,78)
        if bar==s.bars-1 and style in ['rock','doom','industrial','breakbeat']:
            for i,p in enumerate([3,3.25,3.5,3.75]): d.n(b+p,[47,45,43,41][i],.2,75+i*4)
    return d

def bass(s,roots,program=33,level=1,style='hiphop'):
    t=s.track('bass',program,level,hp=30,lp=2600,room=.02)
    for bar in range(s.bars):
        r=roots[bar%len(roots)]; b=bar*s.meter
        if style=='waltz': pats=[(0,0,1.3),(1.7,7,.7)]
        elif style=='walking': pats=[(0,0,.75),(1,4,.72),(2,7,.75),(3,9,.65)]
        elif style=='postpunk': pats=[(i*.5,[0,0,12,0,7,0,10,7][i],.39) for i in range(8)]
        elif style=='doom': pats=[(0,0,1.6),(2,0,.6),(3,1,.7)]
        elif style=='latin': pats=[(0,0,.65),(1.5,7,.4),(2.5,12,.5),(3.5,7,.35)]
        elif style=='funk': pats=[(0,0,.45),(.75,12,.25),(1.5,7,.45),(2.5,0,.5),(3.25,10,.3),(3.75,12,.18)]
        else: pats=[(0,0,1.2),(1.75,0,.35),(2.5,7,.6),(3.5,12,.3)]
        for p,interval,d in pats: t.n(b+p,r+interval,d,98 if p==0 else 84)
    return t

def chords(s,voicings,program=4,level=1,style='held',pan=0):
    t=s.track('chords',program,level,pan=pan,hp=160,lp=7500,room=.45)
    for bar in range(s.bars):
        b=bar*s.meter; ch=voicings[bar%len(voicings)]
        if style=='waltz':
            for p in [1,2]: t.chord(b+p,ch,.65,62,strum=.012)
        elif style=='funk':
            for p in [.55,1.6,2.55,3.6]: t.chord(b+p,ch,.22,72,strum=.009)
        elif style=='arpeggio':
            for i in range(s.meter*2): t.n(b+i*.5,ch[[0,2,1,3,2,1,3,2][i%8]%len(ch)],.7,62+(i%3)*6)
        elif style=='rock':
            for p in [0,1.5,2,3.5]: t.chord(b+p,ch,.58,84,strum=.014)
        else:
            t.chord(b+.04,ch,s.meter-.35,65,strum=.018)
            if bar%2: t.chord(b+s.meter-.6,ch,.35,45,strum=.012)
    return t

def melody(s,program,phrases,level=.8,pan=.16,lp=6500,room=.55,delay=0):
    t=s.track('lead',program,level,pan=pan,hp=160,lp=lp,room=room,delay=delay)
    for bar in range(s.bars):
        for p,n,d,v in phrases[bar%len(phrases)]: t.n(bar*s.meter+p,n,d,v)
    return t

def phrase(notes,times=None):
    # Explicit pitches; rhythmic shorthand for hand-authored motif phrases.
    times=times or [0,.75,1.5,2.5,3.25]
    return [(p,n,.5 if i<len(notes)-1 else .65,78 if i%2==0 else 70) for i,(p,n) in enumerate(zip(times,notes)) if n is not None]

def compose_all():
    songs=[]
    def song(*args,**kw):
        s=Song(len(songs)+1,*args,**kw); songs.append(s); return s

    s=song('eastex','Eastex 44’s','Hazy Houston bounce · heavy bass · warm keys',80)
    drums(s,'hiphop',.78)
    bass(s,[29,29,25,27],38,.93)
    chords(s,[[53,56,60,63,67],[53,56,60,63],[53,56,60,65],[55,58,62,65]],4,.77).lp=3200
    melody(s,81,[phrase([72,68,67,65]),phrase([None,68,65,63,60]),phrase([65,68,72,68,65]),phrase([67,65,63,62,60])],.26,lp=1800,delay=.22)

    s=song('calle_ocho','Calle Ocho','Lowrider funk · rubbery bass · warm street groove',88)
    drums(s,'hiphop',.65)
    bass(s,[36,36,32,34],36,.62,'funk')
    chords(s,[[55,58,62,63],[55,58,60,63],[55,58,60,63],[53,56,60,62]],16,.38,'funk',-.3).lp=3800
    melody(s,27,[phrase([75,72,70,67,70]),phrase([72,70,67,65,63]),phrase([68,70,72,75]),phrase([74,72,70,67,65])],.93,room=.5,delay=.13)
    chords(s,[[60,63,67],[60,63,67],[56,60,63],[58,62,65]],28,.4,'funk',.38)

    s=song('ventresca','Ventresca Family','Smoky Italian lounge · muted trumpet · organ',98)
    drums(s,'jazz',.35)
    b=bass(s,[45,38,47,40],32,.9,'walking')
    for n in b.notes:
        if int(n[0])%4==1 and int(n[0])//4%4 in [0,1]: n[1]-=1
    chords(s,[[60,64,66,69],[60,65,69,71],[59,62,65,69],[59,62,65,68]],16,.28,'held',-.2)
    melody(s,59,[phrase([76,72,71,69],[.5,1.5,2.25,3]),phrase([69,72,77,76,72]),phrase([74,71,69,65],[0,1,2,3]),phrase([68,71,74,71,69])],.68,room=.5)

    s=song('ravicci','Ravicci Family','Italian noir · restrained piano waltz · low strings',90,3,12)
    drums(s,'waltz',.15)
    bass(s,[38,34,31,33],32,.55,'waltz')
    chords(s,[[57,62,65],[58,62,65],[58,62,67],[57,61,64]],0,.82,'waltz',-.18)
    strings=chords(s,[[50,57,62],[46,53,58],[43,50,58],[45,52,61]],48,.27,'held',.1); strings.room=.9; strings.lp=4000
    melody(s,0,[[(0,77,.75,78),(1,76,.4,63),(1.5,74,1.1,69)],[(0,77,.6,73),(.75,74,.5,68),(1.5,70,1,65)],[(0,74,.65,74),(1,70,.5,66),(2,69,.7,60)],[(0,73,.6,72),(1,76,.5,65),(2,74,.8,77)]],.72,room=.8)

    s=song('orlov','Orlov Bratva','Cold post-punk · relentless bass · stark guitar',128,bars=12)
    drums(s,'postpunk',.73)
    bass(s,[38,34,41,36],34,1.05,'postpunk')
    g=chords(s,[[62,65,69],[58,62,65],[60,65,69],[60,64,67]],27,.72,'arpeggio',-.32); g.delay=.24; g.lp=5200
    melody(s,27,[phrase([81,77,76,74],[0,1.5,2.5,3.5]),phrase([77,74,72,70],[0,1,2,3]),phrase([77,79,81,77],[0,1.5,2,3]),phrase([79,76,74,72],[0,1,2.5,3.5])],.7,pan=.4,delay=.28)

    s=song('zangyaku','Zangyaku','Industrial breakbeat · jagged guitar · precision',142,bars=16)
    drums(s,'breakbeat',.88)
    bass(s,[28,28,29,26],38,.85,'postpunk')
    g=s.track('chopped guitar',30,.55,-.3,hp=180,lp=4800,room=.1)
    for bar in range(s.bars):
        root=[40,40,41,38][bar%4]
        for p in [0,.75,1.5,2,2.75,3.5]: g.chord(bar*4+p,[root,root+7,root+12],.2 if p!=2 else .55,95)
    melody(s,81,[phrase([76,77,76,71],[0,.5,2,2.75]),phrase([71,74,76,79],[.75,1.5,2.5,3.25]),phrase([77,76,72,71],[0,1,2.5,3]),phrase([74,72,71,64],[0,.75,2,3])],.19,lp=2200,delay=.18)

    s=song('bitian','Bìtiān','Nocturnal trip-hop · smoky keys · sparse strings',82)
    drums(s,'hiphop',.60)
    bass(s,[30,26,33,28],38,.86)
    c=chords(s,[[54,57,61,64,68],[54,57,61,66],[56,61,64,68],[56,59,63,66]],4,.95); c.lp=3400; c.delay=.1
    melody(s,107,[phrase([73,68,66],[.5,2,3]),phrase([73,69,66],[0,1.5,3]),phrase([76,73,71],[.5,2,3.25]),phrase([71,68,66],[0,1.5,3])],.45,pan=.36,room=.8,delay=.3)

    s=song('sierra_roja','Cártel de Sierra Roja','Dark corrido · picked guitar · low brass swagger',104,bars=12)
    drums(s,'corridos',.58)
    bass(s,[38,38,34,33],58,.45,'latin')
    chords(s,[[50,57,62,65],[50,57,62,65],[46,53,58,62],[45,52,57,61]],25,.90,'arpeggio',-.2)
    melody(s,24,[phrase([74,77,76,74,69]),phrase([69,72,74,77,76]),phrase([74,70,69,65,62]),phrase([73,76,73,69,62])],1.05,pan=.3,room=.4)
    chords(s,[[50,57],[50,57],[46,53],[45,52]],61,.23,'rock').lp=2500

    s=song('mcallister','McAllister Holdings, Inc.','Country-club jazz · clean guitar · brushed swing',100,bars=12)
    drums(s,'jazz',.25)
    bass(s,[43,48,43,50],32,.78,'walking')
    chords(s,[[59,62,66,69],[58,62,64,67],[59,62,65,69],[60,64,66,69]],0,.52,'held',-.3)
    melody(s,26,[phrase([71,69,67,64,62]),phrase([64,67,69,70,69]),phrase([71,74,71,69,67]),phrase([66,69,72,69,67])],1.0,room=.42)

    s=song('mercer44','Mercer 44’s','Southern hip-hop · big bass · triumphant brass',86)
    drums(s,'hiphop',.83)
    bass(s,[29,25,32,27],38,1.05)
    chords(s,[[53,56,60,63],[53,56,60,65],[55,60,63,67],[55,58,62,65]],4,.55).lp=3300
    melody(s,61,[phrase([65,68,72,70,68],[0,.75,1.5,2.5,3.25]),phrase([65,68,72,77],[0,1,2,3]),phrase([75,72,70,68],[0,1.5,2.5,3.25]),phrase([70,67,65,63],[0,.75,2,3])],.46,lp=4200,room=.4)
    chords(s,[[53,60,65],[49,56,61],[56,63,68],[51,58,63]],48,.17).lp=3200

    s=song('wm_corp','Whittaker–McAllister Corporation','Southern blues-rock · polished piano · money',102,bars=12)
    drums(s,'rock',.70)
    bass(s,[40,45,40,47],33,.86,'funk')
    chords(s,[[52,59,62,68],[57,64,67,73],[52,59,62,68],[59,66,69,75]],0,.5,'rock',-.3)
    g=chords(s,[[40,47,52],[45,52,57],[40,47,52],[47,54,59]],29,.51,'rock',.3); g.lp=4500
    melody(s,27,[phrase([76,79,78,76,74]),phrase([81,79,76,74,73]),phrase([76,74,71,69,67]),phrase([75,78,76,74,71])],.85,pan=-.05,room=.5,delay=.12)

    s=song('union_sur','La Unión del Sur','Latin street beat · corrido strings · brass power',94)
    drums(s,'latin',.83)
    bass(s,[38,34,31,33],38,.82,'latin')
    chords(s,[[57,62,65,69],[58,62,65,70],[55,58,62,67],[57,61,64,69]],25,.83,'funk',-.35)
    melody(s,61,[phrase([74,77,76,74,69]),phrase([77,74,70,69,65]),phrase([79,77,74,70,67]),phrase([76,73,69,73,74])],.46,lp=4500,room=.45)
    melody(s,24,[phrase([69,65],[1.5,3.25]),phrase([70,65],[1.5,3.25]),phrase([67,62],[1.5,3.25]),phrase([69,61],[1.5,3.25])],.55,pan=.4)

    s=song('lombardia','L’Ordine di Lombardia','Orchestral crime · dark strings · ceremonial brass',84)
    drums(s,'doom',.54)
    bass(s,[36,32,29,31],42,.56)
    c=chords(s,[[48,55,60,63],[44,51,56,60],[41,48,53,56],[43,50,55,59]],48,.64); c.room=1; c.lp=5600
    melody(s,61,[phrase([72,74,75,67],[0,1,2,3]),phrase([72,68,67,63],[0,1.5,2.5,3]),phrase([77,75,72,68],[0,.75,2,3]),phrase([74,71,67,72],[0,1,2,3])],.41,lp=5000,room=1)
    p=chords(s,[[60,63,67,72],[60,63,68,72],[60,65,68,72],[59,62,67,71]],45,.45,'arpeggio',-.3)

    s=song('sand_raiders','Raiders of the Sand','Scrapyard horror · damaged guitar · rattling metal',76)
    drums(s,'industrial',.6)
    bass(s,[30,30,31,29],34,.9,'doom')
    g=chords(s,[[42,49,54],[42,48,54],[43,50,55],[41,48,53]],29,.44,'held',-.3); g.delay=.31; g.lp=2900
    melody(s,27,[phrase([66,67,61],[0,1.75,3]),phrase([66,65,60],[.5,2,3.5]),phrase([67,61,60],[0,1.5,3]),phrase([65,66,59],[0,2,3.25])],.63,room=.8,delay=.44)
    metal=s.track('scrap metal',0,.32,.38,hp=450,lp=6500,room=1,delay=.21,drum=True)
    for bar in range(s.bars):
        for p,k in [(0,56),(.75,80),(2.5,53),(3.25,81)]: metal.n(bar*4+p,k,.27,55+(bar%3)*9)

    s=song('saffar','Majmu’at al-Saffar','Arabic downtempo · plucked strings · hand drums',90)
    drums(s,'latin',.40)
    bass(s,[38,38,34,33],33,.83,'latin')
    chords(s,[[50,57,62],[50,57,62],[46,53,58],[45,52,57]],48,.13,'held').lp=3300
    melody(s,24,[phrase([74,75,78,79,78]),phrase([81,79,78,75,74]),phrase([82,81,79,78,75]),phrase([78,75,74,73,74])],1.18,room=.7,delay=.19)
    melody(s,15,[phrase([62,69,74],[0,1.5,3]),phrase([63,66,69],[.5,2,3.5]),phrase([62,65,70],[0,1.5,3]),phrase([61,64,69],[0,2,3])],.37,pan=-.4,room=.6,delay=.14)
    hand=s.track('hand drums',0,.6,hp=100,lp=5500,room=.2,drum=True)
    for bar in range(s.bars):
        for p,k,v in [(0,64,92),(.5,62,59),(1.25,63,72),(2,64,86),(2.75,62,68),(3.5,63,77),(3.75,62,43)]: hand.n(bar*4+p,k,.18,v)

    s=song('kurgan','The Kurgan Group','Militaristic industrial · measured drums · low brass',96,bars=12)
    drums(s,'industrial',.90)
    bass(s,[28,28,24,27],38,.95,'postpunk')
    chords(s,[[40,47,52],[40,47,52],[36,43,48],[39,46,51]],61,.40,'rock').lp=3400
    melody(s,48,[phrase([64,64,67,66],[0,1.5,2.5,3.25]),phrase([64,59,62,64],[0,1,2,3]),phrase([67,64,60,59],[0,1.5,2.5,3.25]),phrase([66,63,59,64],[0,1,2,3])],.33,room=.5)
    march=s.track('march rolls',0,.30,drum=True,hp=220,lp=6500,room=.6)
    for bar in range(s.bars):
        for p in [0,.5,.75,1.5,2,2.5,2.75,3.5]: march.n(bar*4+p,38,.08,52 if p%1 else 76)

    s=song('ashford_crane','The Ashford-Crane Collective','Warped ballroom · chamber strings · uneasy elegance',96,3,12)
    bass(s,[33,29,38,28],32,.55,'waltz')
    chords(s,[[57,60,64],[57,60,65],[57,62,65],[56,59,64]],0,.72,'waltz',-.2)
    c=chords(s,[[45,52,60],[41,48,57],[50,57,62],[44,51,59]],48,.35); c.lp=3500; c.room=1.1
    melody(s,0,[[(0,76,.8,72),(1,75,.4,55),(1.5,72,.4,63),(2,71,.7,62)],[(0,77,.8,73),(1,76,.45,61),(2,72,.7,59)],[(0,77,.6,70),(.75,74,.5,64),(1.5,73,.35,57),(2,74,.7,66)],[(0,75,.4,66),(.5,76,.6,69),(1.5,71,.45,56),(2.2,69,.6,73)]],.85,room=1)
    melody(s,10,[[(0,88,1.4,44)],[],[(0,89,1.4,41)],[(1,87,1,38)]],.12,lp=4200,room=1.5)

    s=song('blacktop','Blacktop Apostles MC','Doom / sludge metal · downtuned guitars · weight',68)
    drums(s,'doom',.9)
    bass(s,[33,33,34,31],34,1.15,'doom')
    for side in [-.58,.58]:
        g=s.track('heavy guitar '+str(side),29,.82,side,hp=90,lp=3900,room=.22,drive=3.8)
        for bar in range(s.bars):
            r=[33,33,34,31][bar%4]
            for p,d in [(0,1.6),(2,.55),(3, .68)]: g.chord(bar*4+p+(side>0)*.015,[r,r+7,r+12],d,106,strum=.008)
    melody(s,30,[[(0,69,2.7,72),(3,70,.7,75)],[(0,69,1.7,70),(2,67,1.5,68)],[(0,70,2.7,75),(3,65,.7,69)],[(0,67,2.7,70),(3,64,.7,63)]],.29,room=.8,delay=.12)
    return songs

def render(s):
    total=np.zeros((int(s.duration*SR),2),np.float64)
    print(f'{s.number:02d} {s.name}: {len(s.tracks)} tracks, {s.duration:.1f}s',flush=True)
    for t in s.tracks: total+=render_track(s,t)
    if s.id=='ashford_crane':
        # A restrained whole-ensemble tape flutter, no abrupt pitch jumps.
        t=np.arange(len(total))/SR
        shift=.00055*np.sin(2*np.pi*.57*t)+.00014*np.sin(2*np.pi*4.1*t)
        at=np.clip(np.arange(len(total))+shift*SR,0,len(total)-1)
        total=np.column_stack([np.interp(at,np.arange(len(total)),total[:,ch]) for ch in range(2)])
    total=filt(total,28,'highpass')
    total-=total.mean(axis=0)
    # Gentle mix-bus rounding; final EBU normalization is done by FFmpeg below.
    scale=max(.01,np.quantile(np.abs(total),.998))
    total=np.tanh(total/(scale*1.6))*.76
    a=int(.025*SR); tail=int(1.55*SR)
    total[:a]*=np.linspace(0,1,a)[:,None]
    total[-tail:]*=np.linspace(1,0,tail)[:,None]**1.5
    base=f'{s.number:02d}_{s.id}'
    raw=ROOT/(base+'_mix.wav')
    wavfile.write(raw,SR,(np.clip(total,-1,1)*32767).astype(np.int16))
    # Two-pass loudness keeps quiet previews and heavier previews comparable.
    pre=subprocess.run(['ffmpeg','-hide_banner','-i',str(raw),'-af','loudnorm=I=-18:TP=-2:LRA=9:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
    stats=json.loads(pre.stderr[pre.stderr.rfind('{'):])
    af='loudnorm=I=-18:TP=-2:LRA=9:measured_I={input_i}:measured_TP={input_tp}:measured_LRA={input_lra}:measured_thresh={input_thresh}:offset={target_offset}:linear=true'.format(**stats)
    master=OUT/(base+'.wav'); mp3=OUT/(base+'.mp3')
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(raw),'-af',af,'-ar',str(SR),'-c:a','pcm_s16le',str(master)],check=True)
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(master),'-c:a','libmp3lame','-b:a','192k','-metadata','title='+s.name+' — audition 01','-metadata','artist=DEAD STREET','-metadata','album=Faction audio directions — awaiting review','-metadata','track='+str(s.number),str(mp3)],check=True)
    raw.unlink()
    pcm=wavfile.read(master)[1].astype(np.float64)/32768
    assert np.all(np.isfinite(pcm)) and np.max(np.abs(pcm))<.98 and np.max(np.abs(pcm))>.04
    spec={'number':s.number,'id':s.id,'name':s.name,'vibe':s.vibe,'bpm':s.bpm,'meter':s.meter,'bars':s.bars,'duration':len(pcm)/SR,'status':'PREVIEW — NOT OWNER APPROVED','mp3':mp3.name,'wav':master.name,'peak':float(abs(pcm).max()),'rms':float(np.sqrt(np.mean(pcm**2))),'sha256':hashlib.sha256(mp3.read_bytes()).hexdigest(),'score':[{'label':t.label,'program':t.program,'notes':t.notes} for t in s.tracks]}
    (OUT/(base+'.json')).write_text(json.dumps(spec,ensure_ascii=False,indent=2))
    print(f'  rendered {mp3.name}, peak {spec["peak"]:.3f}',flush=True)
    return spec

if __name__=='__main__':
    selected=set(sys.argv[1:])
    for s in compose_all():
        if not selected or s.id in selected: render(s)
    rows=[json.loads(p.read_text()) for p in sorted(OUT.glob('[0-9][0-9]_*.json'))]
    (ROOT/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
