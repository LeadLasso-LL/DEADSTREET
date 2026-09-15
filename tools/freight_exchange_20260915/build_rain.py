"""Deterministic original rain synthesis. No downloaded audio or third-party samples."""
from pathlib import Path
import numpy as np
import wave,json
r=Path(__file__).resolve().parents[2];out=r/'assets/audio/ambience';out.mkdir(parents=True,exist_ok=True)
sr=44100;seconds=20;n=sr*seconds;rng=np.random.default_rng(915523);freq=np.fft.rfftfreq(n,1/sr);t=np.arange(n)/sr

def bed(low,high,slope):
    bins=rng.normal(size=len(freq))+1j*rng.normal(size=len(freq))
    shape=(np.maximum(freq,20)/1000)**(-slope)*(1-np.exp(-(freq/low)**2))*np.exp(-(freq/high)**2)
    bins*=shape;bins[0]=0;bins[-1]=bins[-1].real
    x=np.fft.irfft(bins,n);return x/np.std(x)

def event_track(count,metal=False):
    x=np.zeros(n)
    for _ in range(count):
        size=int(sr*rng.uniform(.015,.08 if metal else .035));a=np.arange(size)/sr
        hit=rng.normal(size=size)*np.exp(-a/(.009 if metal else .004))
        if metal:
            hz=rng.uniform(650,1900)
            hit+=.45*np.sin(2*np.pi*hz*a)*np.exp(-a/.025)+.12*np.sin(2*np.pi*hz*2.41*a)*np.exp(-a/.013)
        hit*=rng.uniform(.008,.04 if metal else .02)
        start=int(rng.integers(n));indices=(start+np.arange(size))%n;x[indices]+=hit
    return x

# Correlated, gently moving stereo rain; restrained mids leave room for gunfire/radio.
shared=.70*bed(240,5700,.15)+.30*bed(90,1700,.55)
swell=1+.06*np.sin(2*np.pi*t/20)+.035*np.sin(2*np.pi*3*t/20+.8)
channels=[]
for side in range(2):
    x=(shared*.88+bed(400,6500,.1)*.12)*swell*.13
    x+=event_track(1700)
    channels.append(x)
rain=np.stack(channels,axis=1)
roof=np.stack([bed(650,7400,.06)*.08+event_track(460,True),bed(650,7400,.06)*.08+event_track(460,True)],axis=1)
report={}
for name,x in [('freight_rain',rain),('freight_roof_rain',roof)]:
    x*=min(1.,.78/np.max(np.abs(x)))
    pcm=np.round(np.clip(x,-1,1)*32767).astype('<i2')
    path=out/(name+'.wav')
    with wave.open(str(path),'wb') as w:w.setnchannels(2);w.setsampwidth(2);w.setframerate(sr);w.writeframes(pcm.tobytes())
    report[name]={'seconds':seconds,'sample_rate':sr,'peak_dbfs':float(20*np.log10(np.max(abs(x)))),'rms_dbfs':float(20*np.log10(np.sqrt(np.mean(x*x)))),'loop_boundary_step':float(np.max(abs(x[0]-x[-1]))),'normal_step_p99':float(np.quantile(abs(np.diff(x,axis=0)),.99))}
(r/'tools/freight_exchange_20260915/rain_audio_validation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
