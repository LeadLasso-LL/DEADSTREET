"""Three independent musical forms. No shared riff, backing score or drum pattern.
Rendering infrastructure only is shared. Samples remain subject to owner review.
"""
import json,sys
import numpy as np
from scipy.signal import lfilter, butter, sosfilt, resample_poly
import engine as E

sf_render=E.render_track

def ks(freq,seconds,rng):
    delay=round(E.SR/freq-.5)
    burst=rng.normal(0,.3,delay); burst-=np.roll(burst,max(1,delay//6))*.63
    burst-=burst.mean()
    x=np.zeros(round(seconds*E.SR));x[:min(len(x),delay)]=burst[:len(x)]
    a=np.zeros(delay+2);a[0]=1;a[delay]=-.4990;a[delay+1]=-.4984
    x=lfilter([1],a,x)
    n=min(len(x)//2,300); x[:n]*=np.linspace(0,1,n)
    r=min(len(x)//2,3000);x[-r:]*=np.linspace(1,0,r)
    return x

def render_track(s,tr):
    if tr.program>=0:return sf_render(s,tr)
    out=np.zeros(int(s.duration*E.SR));rng=np.random.default_rng(sum(map(ord,tr.label))+s.number*89)
    for beat,key,dur,vel in tr.notes:
        hz=440*2**((key-69)/12); sec=dur*s.beat
        t=np.arange(max(2,round(sec*E.SR)))/E.SR
        if tr.program==-10: # 808 with an audible glide on selected written notes
            slide=tr.label.endswith('glide')
            f=hz*(1+(0.9 if slide else .02)*np.exp(-t/(.16 if slide else .015)))
            ph=2*np.pi*np.cumsum(f)/E.SR
            x=np.tanh((np.sin(ph)+.11*np.sin(ph*3))*1.9)*.24*np.exp(-t/(sec*.8))
        elif tr.program==-11: # physically modeled, double-tracked guitar power dyad
            detune=1.002 if tr.pan>0 else .998
            x=ks(hz*detune,sec,rng)+.57*ks(hz*1.4983*detune,sec,rng)+.24*ks(hz*2*detune,sec,rng)
            hi=resample_poly(x,2,1)
            hi=np.tanh(hi*14+.04)-np.tanh(.04)
            hi=sosfilt(butter(2,5300,fs=E.SR*2,output='sos'),hi)
            x=resample_poly(hi,1,2)[:len(t)]*.22
            x=sosfilt(butter(2,3200,fs=E.SR,output='sos'),x)
        elif tr.program==-12: # deep kick with a short transient
            ph=2*np.pi*(48*t+3.9*(1-np.exp(-t/.022)))
            x=(np.sin(ph)*np.exp(-t/.17)+.08*rng.normal(size=len(t))*np.exp(-t/.005))*.46
        else:raise ValueError(tr.program)
        a=min(200,len(x)//2);r=min(2000,len(x)//2)
        x[:a]*=np.linspace(0,1,a);x[-r:]*=np.linspace(1,0,r)
        x*=vel/127
        pos=round(beat*s.beat*E.SR);size=min(len(x),len(out)-pos)
        if size>0:out[pos:pos+size]+=x[:size]
    out=E.filt(E.filt(out,tr.hp,'highpass'),tr.lp,'lowpass')
    return np.column_stack([out*(1-max(0,tr.pan)*.6),out*(1+min(0,tr.pan)*.6)])*tr.level

E.render_track=render_track

def eastex():
    s=E.Song(1,'eastex','Eastex 44’s','Syncopated underground rap / 808 slides / sparse chopped keys',64,4,6)
    # Entire 24-beat rhythm is written out; no shared bar generator.
    kick=s.track('Eastex kick',-12,1,hp=27,lp=6500,room=0)
    for b,v in [(0,118),(1.25,101),(3.25,111),(4,116),(5.75,107),(7.5,101),(8,118),(10.75,113),(11.5,100),(12.25,114),(14,101),(15.75,112),(16,116),(17.5,98),(19.25,107),(20,116),(22.75,103)]:kick.n(b,36,.4,v)
    kit=s.track('Eastex clap hats',0,.58,hp=170,lp=7300,room=.25,drum=True)
    for b in [2,6,10,14,18,22]:kit.n(b,39,.2,104)
    for b in [0,.5,1.5,2.5,3,3.5,4.5,5,5.5,6.75,7,7.25,8.5,9.5,10.5,11.5,12,12.5,13.5,14.75,15,15.5,16.5,17,18.5,19,19.5,20.5,21.5,22.5,23.25,23.5,23.75]:kit.n(b,42,.07,47 if b%1 else 66)
    for b in [7.5,15.5,23]:kit.n(b,46,.28,52)
    bass=s.track('Eastex 808',-10,1.3,hp=23,lp=1800,room=0)
    for b,n,d,v in [(0,29,1.05,116),(1.25,29,.55,109),(3.25,36,.6,100),(4,29,1.5,118),(5.75,41,.55,100),(7.5,36,.35,104),(8,25,2,119),(10.75,25,.55,105),(11.5,32,.35,96),(12.25,29,1.2,116),(14,36,1,108),(15.75,41,.18,96),(16,29,1.2,119),(17.5,29,.6,108),(19.25,36,.5,103),(20,24,1.8,118),(22.75,29,.8,110)]:bass.n(b,n,d,v)
    slide=s.track('Eastex 808 glide',-10,.98,hp=24,lp=1700,room=0)
    slide.n(6.5,29,.8,110);slide.n(18.5,29,.65,106);slide.n(23.6,29,.35,105)
    keys=s.track('Eastex chopped low piano',0,.7,pan=-.3,hp=130,lp=2200,room=1.2,delay=.18)
    # A two-note chopped sample feel, not a universal chromatic melody.
    for b,ns,d in [(0,[53,60,68],.25),(3.5,[53,60,68],.17),(4.5,[53,60,68],.3),(8,[49,56,65],.5),(11,[49,56,65],.18),(12.5,[53,60,68],.28),(16,[53,60,68],.35),(19.5,[60,68],.2),(20,[48,55,63],.7)]:keys.chord(b,ns,d,89)
    return s

def ravicci():
    s=E.Song(2,'ravicci','Ravicci Family','Through-composed chamber dread / suspended time / no beat loop',72,3,10)
    # Deliberately no kit, 808, repeating bass floor, backbeat, or bar-loop helper.
    piano=s.track('Ravicci exposed piano',0,1.10,pan=-.15,hp=80,lp=3700,room=2.7)
    for b,ns,d,v in [(0,[38,57,65],3,101),(3.6,[69],.65,68),(4.65,[64],1.4,83),(7.1,[34,55,62],3.5,99),(10.8,[70],1.1,73),(12.4,[67,73],1.7,81),(15.2,[31,53,58],3.9,106),(19.1,[62],1.7,75),(22.5,[33,52,58,67],3.1,104),(26.1,[61],2.1,74),(28.2,[38,57,64],1.65,83)]:piano.chord(b,ns,d,v,strum=.018)
    cello=s.track('Ravicci cello counterline',42,.82,pan=.19,hp=55,lp=3000,room=2.1)
    for b,n,d,v in [(1.2,50,4.6,77),(6.4,46,4.4,85),(11.6,43,3.1,79),(15.6,41,4.8,90),(21,45,4.2,91),(26.4,38,3.3,84)]:cello.n(b,n,d,v)
    strings=s.track('Ravicci suspended bows',48,.45,pan=.1,hp=170,lp=3500,room=2.3)
    for b,ns,d,v in [(2,[62,69,76],4.3,64),(8.3,[62,65,70],4.9,72),(14,[58,62,67],5.7,80),(21.7,[58,64,73],4.7,78),(27,[57,64,65],2.8,70)]:strings.chord(b,ns,d,v,strum=.08)
    return s

def blacktop():
    s=E.Song(3,'blacktop','Blacktop Apostles MC','Guitar-led doom / long distorted chords / live-kit weight',54.4,4,6)
    # One 24-beat guitar phrase with rests, changing lengths and a different second half.
    riff=[(0,33,2.4),(3,33,.42),(3.6,33,.24),(4,36,1.5),(6,35,1.4),(8,33,3.1),(11.5,31,.3),(12,33,.7),(13.5,33,.65),(15,36,.7),(16,38,2.2),(19,36,.65),(20,33,3.8)]
    for pan in [-.67,.67]:
        guitar=s.track('Blacktop physical guitar '+str(pan),-11,1.3,pan=pan,hp=65,lp=3900,room=0)
        for b,n,d in riff:guitar.n(b+(pan>0)*.016,n,d,119 if d>1 else 110)
    bass=s.track('Blacktop picked bass',34,.96,hp=29,lp=1700,room=.05,drive=4)
    for b,n,d in [(0,33,2.6),(3,33,.7),(4,36,1.5),(6,35,1.6),(8,33,3.3),(12,33,1),(13.5,33,.8),(15,36,.8),(16,38,2.7),(19,36,.7),(20,33,3.8)]:bass.n(b,n,d,112)
    kit=s.track('Blacktop live kit',0,1.08,hp=34,lp=7600,room=1,drum=True)
    for b,v in [(0,120),(3,99),(3.6,110),(4,119),(6,102),(8,120),(10.5,105),(12,119),(13.5,109),(15,112),(16,120),(18.5,102),(19,107),(20,120)]:kit.n(b,36,.15,v)
    for b,v in [(2.35,116),(6.45,112),(10.4,119),(14.6,118),(18.4,117),(22.3,119)]:kit.n(b,38,.3,v)
    for b in [0,4,8,16,20]:kit.n(b,49,1.7,100)
    for b in [1.3,3,5.4,7.1,9.4,11.1,12.8,14,15.1,17.3,19.1,21.3,23]:kit.n(b,51,.4,71)
    for b,k,v in [(11.2,45,92),(11.65,41,106),(23.1,43,96),(23.55,41,108)]:kit.n(b,k,.35,v)
    return s

if __name__=='__main__':
    songs=[eastex(),ravicci(),blacktop()]
    assert not any(t.drum or t.program<0 for t in songs[1].tracks)
    assert not any(t.program==-10 for t in songs[2].tracks)
    for s in songs:E.render(s)
    rows=[json.loads(p.read_text()) for p in sorted(E.OUT.glob('*.json'))]
    (E.ROOT/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
