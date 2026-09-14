"""Original deterministic radio riff and siren; no sampled/commercial recording."""
from pathlib import Path
import numpy as np
import wave,json
SR=44100;BPM=112;BEAT=60/BPM;LENGTH=BEAT*32
rng=np.random.default_rng(9142026)
def filt(a,hz,kind='lowpass',order=3):
 f=np.fft.rfftfreq(len(a),1/SR);response=1/np.sqrt(1+(f/hz)**(2*order))
 if kind=='highpass':response=np.sqrt(np.maximum(0,1-response**2))
 return np.fft.irfft(np.fft.rfft(a)*response,n=len(a))
def pluck(freq,duration,palm):
 n=int(duration*SR);t=np.arange(n)/SR
 # Stiff-string harmonics and pick noise through a driven, cabinet-filtered amp.
 signal=np.zeros(n)
 for h in range(1,19):
  decay=(.14 if palm else .68)/(1+.055*h)
  signal+=np.sin(2*np.pi*freq*h*(1+.000035*h*h)*t+rng.uniform(-.15,.15))*np.exp(-t/decay)/(h**.88)
 signal+=filt(rng.normal(0,1,n),3500)*np.exp(-t/.018)*.32
 signal*=np.minimum(t/.002,1)
 signal=np.tanh(signal*3.8)+.22*np.tanh(signal*12)
 return filt(filt(signal,90,'highpass'),4700)
def add(dst,clip,start,gain=1):
 i=int(start*SR);end=min(len(dst),i+len(clip))
 if i<end:dst[i:end]+=clip[:end-i]*gain

def metal():
 n=int(LENGTH*SR);guitar=np.zeros(n);bass=np.zeros(n);drums=np.zeros(n)
 patterns=[[(0,0,.45),(.75,0,.2),(1,0,.2),(1.5,3,.5),(2.25,0,.2),(2.5,0,.2),(3,5,.5),(3.5,3,.45)],[(0,0,.6),(1,0,.22),(1.5,0,.22),(2,6,.45),(2.75,5,.2),(3,3,.6)]]
 for bar in range(8):
  for beat,semitone,dur in patterns[bar%2]:
   start=(bar*4+beat)*BEAT;f=73.416*2**(semitone/12);length=max(.22,dur*BEAT+.12);palm=dur<.5
   for detune,delay,gain in [(1.,0,.72),(1.004,.012,.44)]:
    for ratio,weight in [(1,1),(1.498,.7),(2,.35)]:add(guitar,pluck(f*ratio*detune,length,palm),start+delay,gain*weight)
   t=np.arange(int(length*SR))/SR;add(bass,(np.sin(2*np.pi*f*.5*t)+.22*np.sin(2*np.pi*f*t))*np.exp(-t/.21),start,.7)
  for beat in [0,1.5,2,2.75]:
   t=np.arange(int(.25*SR))/SR;phase=2*np.pi*(46*t+45*.023*(1-np.exp(-t/.023)))
   add(drums,np.sin(phase)*np.exp(-t/.07)+rng.normal(0,.08,len(t))*np.exp(-t/.004),(bar*4+beat)*BEAT,.9)
  for beat in [1,3]:
   t=np.arange(int(.23*SR))/SR;snare=filt(rng.normal(0,1,len(t)),1600,'highpass')*np.exp(-t/.045)+.4*np.sin(2*np.pi*180*t)*np.exp(-t/.045)
   add(drums,snare,(bar*4+beat)*BEAT,.45)
  for beat in np.arange(0,4,.5):
   t=np.arange(int(.1*SR))/SR;hat=filt(rng.normal(0,1,len(t)),6200,'highpass')*np.exp(-t/.025)
   add(drums,hat,(bar*4+beat)*BEAT,.085 if beat%1 else .12)
 mix=guitar*.23+bass*.35+drums*.6
 # A radio heard through the vehicle body, not a soundtrack on the master bus.
 mix=filt(filt(np.tanh(mix*1.4),180,'highpass',2),1850,'lowpass',3)
 return mix/max(np.max(np.abs(mix)),1e-9)*.78

def siren():
 seconds=12.;t=np.arange(int(seconds*SR))/SR
 freq=760+260*np.sin(2*np.pi*t/4.-np.pi/2);phase=2*np.pi*np.cumsum(freq)/SR
 wave=np.sin(phase)+.26*np.sin(3*phase)+.12*np.sin(5*phase)
 wave=filt(wave,1450)*(.84+.16*np.sin(2*np.pi*t/.19))
 return wave/max(np.max(np.abs(wave)),1e-9)*.6

def save(path,a):
 path.parent.mkdir(parents=True,exist_ok=True)
 # Short edge ramps eliminate clicks when a source starts/stops or loops.
 edge=min(int(.035*SR),len(a)//2);a[:edge]*=np.linspace(0,1,edge);a[-edge:]*=np.linspace(1,0,edge)
 with wave.open(str(path),'wb')as w:w.setparams((1,2,SR,len(a),'NONE','not compressed'));w.writeframes(np.rint(np.clip(a,-1,1)*32767).astype('<i2').tobytes())
if __name__=='__main__':
 repo=Path(__file__).resolve().parents[2];out=repo/'assets/audio/convoy'
 save(out/'raiders_radio.wav',metal());save(out/'police_siren.wav',siren())
 print('AUDIO_READY',out,flush=True)
