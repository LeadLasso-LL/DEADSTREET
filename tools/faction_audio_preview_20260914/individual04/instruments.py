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
        elif tr.program==-14: # Inharmonic struck scrap/steel; pitch is a tuning control.
            x=np.zeros_like(t)
            for ratio,amp,decay in [(1,.23,.65),(1.419,.17,.4),(2.711,.13,.3),(4.07,.065,.21)]:
                x+=np.sin(2*np.pi*hz*ratio*t)*amp*np.exp(-t/decay)
            x+=rng.normal(0,.13,len(t))*np.exp(-t/.012)
            x=np.tanh(x*2.1)*.35
        elif tr.program==-15: # Grit scrape, with an irregular but deterministic envelope.
            noise=rng.normal(0,1,len(t))
            noise=sosfilt(butter(2,[170,1800],btype='bandpass',fs=E.SR,output='sos'),noise)
            pulse=.45+.3*np.sin(2*np.pi*3.13*t)*np.sin(2*np.pi*1.79*t)
            x=np.tanh(noise*2)*pulse*.31*np.exp(-t/max(.2,sec*.7))
        else:raise ValueError(tr.program)
        a=min(200,len(x)//2);r=min(2000,len(x)//2)
        x[:a]*=np.linspace(0,1,a);x[-r:]*=np.linspace(1,0,r)
        x*=vel/127
        pos=round(beat*s.beat*E.SR);size=min(len(x),len(out)-pos)
        if size>0:out[pos:pos+size]+=x[:size]
    out=E.filt(E.filt(out,tr.hp,'highpass'),tr.lp,'lowpass')
    return np.column_stack([out*(1-max(0,tr.pan)*.6),out*(1+min(0,tr.pan)*.6)])*tr.level

E.render_track=render_track
