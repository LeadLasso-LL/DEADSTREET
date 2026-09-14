"""Original Whittaker porch guitar and TRC low warning horn. No external samples.
Deterministic plucked-string excitation, restrained amplifier, authored parts.
"""
from pathlib import Path
import numpy as np
import wave, json, hashlib
SR=44100;BEAT=60/106;N=round(32*BEAT*SR)
rng=np.random.default_rng(9142026)
def filt(x,hz,kind='lowpass',n=2):
 f=np.fft.rfftfreq(len(x),1/SR);g=1/np.sqrt(1+(f/hz)**(2*n))
 if kind=='highpass':g=np.sqrt(np.maximum(0,1-g*g))
 return np.fft.irfft(np.fft.rfft(x)*g,n=len(x))
def note(hz,length=2.5,mute=False):
 delay=round(SR/hz-.5);n=round(length*SR)
 exc=np.zeros(n);burst=rng.normal(0,.6,delay);burst-=.63*np.roll(burst,max(1,round(delay*.21)));exc[:delay]=burst
 x=exc.copy()
 for i in range(delay+1,n):x[i]+=.499*x[i-delay]+.498*x[i-delay-1]
 t=np.arange(n)/SR
 x*=np.minimum(t/.001,1)*np.exp(-t/(.18 if mute else 2.6));x[-441:]*=np.linspace(1,0,441)
 return x

def put(dst,x,beat,gain=1):
 i=max(0,round(beat*BEAT*SR));n=min(len(x),len(dst)-i)
 if n>0:dst[i:i+n]+=x[:n]*gain

def guitar():
 rhythm=np.zeros(N);lead=np.zeros(N);bass=np.zeros(N);drums=np.zeros(N)
 # Original sunny Southern country-blues in G major: alternating bass,
 # brushed shuffle, open-string chord thirds and answering pentatonic picking.
 roots=[97.999,97.999,130.813,97.999,146.832,130.813,97.999,146.832]
 for bar,f in enumerate(roots):
  for beat,muted,gain in [(0,False,.72),(1,True,.55),(2,False,.66),(3,True,.5)]:
   for ratio,weight,offset in [(1,1.,0),(1.25992,.4,.025),(1.4983,.7,.05),(2,.25,.065)]:
    put(rhythm,note(f*ratio,1.6,muted),bar*4+beat+offset,gain*weight*.32)
  for beat,ratio in [(0,1),(1,1.4983),(2,1),(3,1.4983)]:
   put(bass,note(f/2*ratio,.52,True),bar*4+beat,.45)
  for beat in [0,2]:
   t=np.arange(round(.22*SR))/SR
   put(drums,np.sin(2*np.pi*(61*t+30*.02*(1-np.exp(-t/.02))))*np.exp(-t/.06),bar*4+beat,.10)
  for beat in [1,3]:
   t=np.arange(round(.15*SR))/SR
   brush=filt(rng.normal(0,1,len(t)),2600,'highpass')*np.exp(-t/.045)
   put(drums,brush,bar*4+beat,.025)
  for beat in [.66,1.66,2.66,3.66]:
   t=np.arange(round(.06*SR))/SR
   put(drums,filt(rng.normal(0,1,len(t)),5400,'highpass')*np.exp(-t/.012),bar*4+beat,.012)
 phrase=[(0,7,.8),(1,9,.42),(1.66,11,.4),(2,14,.9),(3.3,11,.6),
 (4,9,.7),(5,7,.8),(6.4,4,.4),(7,2,.7),(8,12,1.),(9.6,9,.5),
 (10.3,7,.6),(11,4,.6),(12,7,1.1),(13.7,9,.5),(14.5,11,1.),
 (16,14,1.1),(17.7,11,.5),(18.5,9,.5),(19.3,7,.6),
 (20,12,1.),(21.7,9,.5),(22.4,7,.6),(23.2,4,.6),
 (24,7,1.2),(26,4,.6),(27,2,.6),(28,7,1.5),(30.4,2,.5),(31.1,6,.5)]
 for beat,semitone,duration in phrase:
  hz=195.998*2**(semitone/12)
  x=note(hz,duration*BEAT+.12)
  # Tiny finger vibrato only; the former multi-millisecond modulation produced
  # a queasy pitch wobble and made the minor-key part feel ominous.
  t=np.arange(len(x))/SR
  sample=np.arange(len(x))+.000025*SR*np.sin(2*np.pi*5*t)*np.minimum(t/.2,1)
  x=np.interp(sample,np.arange(len(x)),x,left=0,right=0)
  put(lead,x,beat+rng.uniform(-.014,.014),.30)
 rhythm=filt(filt(rhythm,100,'highpass'),4400)
 lead=filt(np.tanh(lead*1.15),4500)
 dry=rhythm*.9+lead*.65+bass*.45+drums
 echo=np.zeros(N)
 for seconds,g in [(.052,.08),(.103,.045)]:
  i=round(seconds*SR);echo[i:]+=dry[:-i]*g
 return filt(filt(dry+echo,100,'highpass'),3400)
def horn():
 # Repeating civil-defense/foghorn blasts, not a police hi-lo siren. Strong
 # 2nd/3rd/4th harmonics preserve the warning character on phone speakers.
 t=np.arange(12*SR)/SR;x=np.zeros(len(t))
 for start,duration in [(.12,3.3),(6.1,3.5)]:
  u=t-start;valid=(u>=0)&(u<duration);v=u[valid]
  envelope=np.minimum(v/.26,1)*np.minimum((duration-v)/.52,1)
  frequency=124.-8*np.minimum(v/.7,1)+1.5*np.sin(2*np.pi*.55*v)
  phase=2*np.pi*np.cumsum(frequency)/SR
  body=np.sin(phase)+.64*np.sin(phase*2)+.40*np.sin(phase*3)+.23*np.sin(phase*4)
  body+=.2*np.sin(phase*1.503)
  breath=filt(rng.normal(0,.06,len(v)),1100)
  x[valid]=(body+breath)*envelope*(.92+.08*np.sin(2*np.pi*.8*v))
 return filt(filt(np.tanh(x*1.15),55,'highpass'),1600)
def save(p,x):
 x/=max(np.max(np.abs(x)),1e-10);x*=.75
 edge=min(441,len(x)//100);x[:edge]*=np.linspace(0,1,edge);x[-edge:]*=np.linspace(1,0,edge)
 p.parent.mkdir(parents=True,exist_ok=True)
 with wave.open(str(p),'wb')as w:w.setparams((1,2,SR,0,'NONE','not compressed'));w.writeframes((x*32767).astype('<i2').tobytes())
 return {'file':p.name,'seconds':len(x)/SR,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'peak':float(np.max(np.abs(x))),'rms':float(np.sqrt(np.mean(x*x)))}
if __name__=='__main__':
 import sys
 out=Path(sys.argv[1]) if len(sys.argv)>1 else Path('estate_build/audio')
 reports=[save(out/'whittaker_radio.wav',guitar()),save(out/'trc_horn.wav',horn())]
 (out/'estate_audio_manifest.json').write_text(json.dumps(reports,indent=2));print(json.dumps(reports))
