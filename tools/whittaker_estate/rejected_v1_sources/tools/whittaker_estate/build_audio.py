"""Original Whittaker porch guitar and TRC low warning horn. No external samples.
Deterministic plucked-string excitation, restrained amplifier, authored parts.
"""
from pathlib import Path
import numpy as np
import wave, json, hashlib
SR=44100;BEAT=60/92;N=round(32*BEAT*SR)
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
 i=round(beat*BEAT*SR);n=min(len(x),len(dst)-i)
 if n>0:dst[i:i+n]+=x[:n]*gain

def guitar():
 rhythm=np.zeros(N);lead=np.zeros(N);bass=np.zeros(N);drums=np.zeros(N)
 # Southern shuffle in D: open fifths, a measured blues phrase, space between answers.
 roots=[73.416,73.416,65.406,97.999,73.416,65.406,97.999,73.416]
 for bar,f in enumerate(roots):
  for beat,muted,gain in [(0,False,1.),(1.66,True,.60),(2,False,.85),(3.66,True,.52)]:
   for ratio,weight,offset in [(1,1.,0),(1.4983,.65,.008),(2,.37,.016)]:
    put(rhythm,note(f*ratio,1.8,muted),bar*4+beat+offset,gain*weight*.31)
  for beat,ratio in [(0,1),(1,1),(2,1.4983),(3,1.778)]:
   t=np.arange(round(.55*SR))/SR;hz=f/2*ratio
   x=(np.sin(2*np.pi*hz*t)+.2*np.sin(4*np.pi*hz*t))*np.exp(-t/.22)*np.minimum(t/.004,1)
   put(bass,x,bar*4+beat,.26)
  for beat in [0,2]:
   t=np.arange(round(.28*SR))/SR;phase=2*np.pi*(52*t+42*.02*(1-np.exp(-t/.02)))
   put(drums,np.sin(phase)*np.exp(-t/.075),bar*4+beat,.30)
  for beat in [1,3]:
   t=np.arange(round(.2*SR))/SR;noise=filt(rng.normal(0,1,len(t)),1500,'highpass')
   put(drums,(noise*.12+np.sin(2*np.pi*185*t)*.23)*np.exp(-t/.044),bar*4+beat,.32)
  for beat in [0,.66,1,1.66,2,2.66,3,3.66]:
   t=np.arange(round(.065*SR))/SR;x=filt(rng.normal(0,1,len(t)),5800,'highpass')*np.exp(-t/.013)
   put(drums,x,bar*4+beat,.022)
 for beat,semitone,duration in [(0,12,1.7),(2.66,10,.7),(4,7,1.4),(6.66,5,.75),(8,3,1.5),(10.66,0,.75),(12,7,1.5),(14.66,10,.7),(16,12,2.),(19,15,.6),(20,12,1.9),(23,10,.6),(24,7,1.8),(27,5,.6),(28,3,.6),(29,0,1.7)]:
  x=note(146.832*2**(semitone/12),duration*BEAT)
  # Gentle pitch sag and double tracking; no square/saw lead oscillator.
  phase=np.arange(len(x))+.0015*SR*np.sin(2*np.pi*4.8*np.arange(len(x))/SR)*np.minimum(np.arange(len(x))/(SR*.25),1)
  x=np.interp(phase,np.arange(len(x)),x,left=0,right=0)
  put(lead,x,beat,.20)
 rhythm=filt(np.tanh(filt(rhythm,90,'highpass')*2.8),3800)
 lead=filt(np.tanh(lead*2.2),4200)
 dry=rhythm*.58+lead*.42+bass+drums
 # Small porch reflections, then distance filtering from the house radio.
 echo=np.zeros(N)
 for seconds,g in [(.047,.13),(.089,.08)]:
  i=round(seconds*SR);echo[i:]+=dry[:-i]*g
 return filt(filt(dry+echo,85,'highpass'),2500)
def horn():
 t=np.arange(14*SR)/SR;x=np.zeros(len(t))
 for start,duration in [(1.,3.8),(8.0,2.7)]:
  u=t-start;valid=(u>=0)&(u<duration);v=u[valid]
  envelope=np.minimum(v/.48,1)*np.minimum((duration-v)/.8,1)
  frequency=98.-7.*np.minimum(v/1.3,1);phase=2*np.pi*np.cumsum(frequency)/SR
  body=np.sin(phase)+.35*np.sin(phase*1.503)+.20*np.sin(phase*2)+.09*np.sin(phase*3)
  breath=filt(rng.normal(0,.06,len(v)),420)
  x[valid]=(body+breath)*envelope*(.96+.04*np.sin(2*np.pi*.7*v))
 return filt(filt(x,45,'highpass'),900)
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
