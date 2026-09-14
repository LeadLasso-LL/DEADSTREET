"""Original Drop-C groove-metal radio cue. No recordings, samples or third-party music.
Plucked-string waveguides -> driven amplifier -> cabinet -> distant vehicle radio.
All guitar/bass/drum parts and excitation signals are authored/generated here.
"""
from pathlib import Path
import numpy as np
import wave,hashlib,json,time
SR=44100;BPM=102.;BEAT=60./BPM;BARS=8;N=round(BARS*4*BEAT*SR)
def filter_audio(a,hz,high=False,order=2,sr=SR):
 f=np.fft.rfftfreq(len(a),1/sr);g=1/np.sqrt(1+(f/hz)**(2*order))
 if high:g=np.sqrt(np.maximum(0.,1-g*g))
 return np.fft.irfft(np.fft.rfft(a)*g,n=len(a))
def cabinet(a):
 f=np.fft.rfftfreq(len(a),1/SR)
 # Closed-back speaker response: chest, aggressive midrange, soft high-frequency rolloff.
 response=(1+.38*np.exp(-.5*((f-170)/75)**2)+.40*np.exp(-.5*((f-1450)/650)**2))
 response*=1-.34*np.exp(-.5*((f-3800)/430)**2)
 response*=1/np.sqrt(1+(f/4700)**8)
 response*=np.sqrt(1-1/(1+(f/78)**4))
 return np.fft.irfft(np.fft.rfft(a)*response,n=len(a))
def string(freq,seconds,palm,rng):
 delay=round(SR/freq-.5);buf=rng.uniform(-1,1,delay)
 # Pick-position comb shapes the excitation, instead of an oscillator waveform.
 buf-=np.roll(buf,max(1,round(delay*.19)))*.65
 buf-=buf.mean();out=np.empty(round(seconds*SR));pos=0
 feedback=.990 if palm else .9988
 for i in range(len(out)):
  sample=buf[pos];nxt=(pos+1)%delay
  buf[pos]=feedback*(.51*sample+.49*buf[nxt]);out[i]=sample;pos=nxt
 t=np.arange(len(out))/SR
 out*=np.minimum(t/.0015,1.)
 out*=np.exp(-t/(.14 if palm else 1.1))
 return out

def amplifier(raw):
 pre=filter_audio(raw,82,True)
 pre+=.6*(filter_audio(pre,700)-filter_audio(pre,170))
 # Oversampled asymmetric clipping, interstage filtering and cabinet response.
 x=np.interp(np.arange(len(pre)*2)*.5,np.arange(len(pre)),pre)
 x=np.tanh(x*22.+.10)-np.tanh(.10)
 x=filter_audio(x,6400,order=2,sr=SR*2)
 x=np.tanh(x*2.4)
 x=filter_audio(x,6200,order=3,sr=SR*2)[::2]
 return cabinet(x)

def put(dst,a,start,gain=1.):
 i=round(start*SR)
 if i<0:a=a[-i:];i=0
 n=min(len(a),len(dst)-i)
 if n>0:dst[i:i+n]+=a[:n]*gain

def metal():
 rng=np.random.default_rng(2026091407);guitars=[]
 # Original syncopated low-C power-chord pattern; rests give the groove its weight.
 patterns=[[(0,0,.39,1),(.75,0,.20,1),(1.25,0,.25,1),(2,3,.58,0),(2.9,0,.20,1),(3.5,10,.44,0)],
 [(0,0,.32,1),(.5,0,.24,1),(1.3,0,.26,1),(2,6,.39,0),(2.75,5,.28,0),(3.35,3,.58,0)],
 [(0,0,.40,1),(.85,0,.19,1),(1.5,0,.22,1),(2.25,3,.43,0),(3,5,.43,0),(3.6,3,.28,0)],
 [(0,0,.30,1),(.55,0,.23,1),(1.25,0,.20,1),(2,10,.49,0),(2.85,6,.32,0),(3.45,0,.36,1)]]
 events=[]
 for bar in range(BARS):
  for beat,semitone,length,palm in patterns[bar%4]:events.append(((bar*4+beat)*BEAT,semitone,length*BEAT,bool(palm)))
 for track in range(2):
  raw=np.zeros(N);cache={};detune=.9984 if track==0 else 1.0016
  for start,semitone,length,palm in events:
   key=(semitone,palm)
   if key not in cache:
    chord=np.zeros(round(1.6*SR));f=65.4064*2**(semitone/12)*detune
    for interval,weight,delay in [(1.,1.,0.),(1.4983,.73,.004),(2.,.34,.008)]:
     put(chord,string(f*interval,1.5,palm,rng),delay,weight)
    cache[key]=chord*.36
   clip=cache[key].copy();end=round((length+.065)*SR);clip=clip[:end]
   # A left-hand choke after the written duration prevents the amplifier from sustaining rests.
   edge=min(round(.027*SR),len(clip));clip[-edge:]*=np.linspace(1.,0.,edge)
   put(raw,clip,start+(.009 if track else 0.)+rng.uniform(-.002,.002),rng.uniform(.89,1.05))
  amp=amplifier(raw)
  # Noise gate follows string energy before distortion; silence stays silent.
  env=np.sqrt(np.convolve(raw*raw,np.ones(220)/220,mode='same')+1e-12)
  gate=np.minimum(1.,env/.0018)
  guitars.append(amp*gate)
 bass=np.zeros(N);drums=np.zeros(N)
 for start,semitone,length,palm in events:
  t=np.arange(round((length+.07)*SR))/SR;f=32.7032*2**(semitone/12)
  a=np.sin(2*np.pi*f*t)+.33*np.sin(2*np.pi*f*2*t)+.13*np.sin(2*np.pi*f*3*t)
  a=np.tanh(a*1.3)*np.exp(-t/(.19 if palm else .65))*np.minimum(t/.004,1.)
  a[-min(900,len(a)):]*=np.linspace(1.,0.,min(900,len(a)));put(bass,a,start,.62)
 def kick():
  t=np.arange(round(.40*SR))/SR
  phase=2*np.pi*(48*t+72*.022*(1-np.exp(-t/.022)))
  body=np.sin(phase)*np.exp(-t/.105)
  click=filter_audio(rng.normal(0,1,len(t)),1300,True)*np.exp(-t/.007)
  return np.tanh((body+click*.20)*1.6)*.85
 def snare():
  t=np.arange(round(.33*SR))/SR
  wire=filter_audio(filter_audio(rng.normal(0,1,len(t)),850,True),8700)
  body=(np.sin(2*np.pi*178*t)+.38*np.sin(2*np.pi*329*t))*np.exp(-t/.064)
  a=body*.66+wire*(np.exp(-t/.068)*.94+np.exp(-t/.17)*.15)
  return np.tanh(a*1.35)*.7
 def cymbal(opened=False):
  t=np.arange(round((.75 if opened else .15)*SR))/SR;a=np.zeros(len(t))
  for freq in [431,613,881,1237,1789,2357]:a+=np.sign(np.sin(2*np.pi*freq*t+rng.uniform(0,6.28)))
  a=filter_audio(a+rng.normal(0,1,len(t)),5100,True)
  return a*np.exp(-t/(.20 if opened else .035))*.047
 for bar in range(BARS):
  for beat in [0,.75,1.5,2.75,3.5] if bar%2==0 else [0,.5,1.5,2.5]:put(drums,kick(),(bar*4+beat)*BEAT,.95)
  for beat in [1,3]:put(drums,snare(),(bar*4+beat)*BEAT+.006,1.)
  for beat in np.arange(0,4,.5):put(drums,cymbal(bar%4==3 and beat==3.5),(bar*4+beat)*BEAT,.95 if beat%1==0 else .65)
  if bar%4==0:put(drums,cymbal(True),(bar*4)*BEAT,1.3)
 # The guitar remains the dominant source. Drums provide a slow, heavy backbeat.
 dry=(guitars[0]+guitars[1])*.50+bass*.27+drums*.50
 dry=np.tanh(dry*1.05)
 radio=filter_audio(filter_audio(dry,145,True,order=2),2850,order=2)
 radio/=max(float(np.max(np.abs(radio))),1e-9);radio*=.78
 return radio,dry

def siren():
 t=np.arange(12*SR)/SR;freq=760+260*np.sin(2*np.pi*t/4.-np.pi/2);phase=2*np.pi*np.cumsum(freq)/SR
 a=np.sin(phase)+.26*np.sin(3*phase)+.12*np.sin(5*phase)
 a=filter_audio(a,1450,order=3)*(.84+.16*np.sin(2*np.pi*t/.19))
 return a/np.max(np.abs(a))*.6

def save(path,a):
 path.parent.mkdir(parents=True,exist_ok=True);a=a.copy();edge=min(round(.012*SR),len(a)//2)
 a[:edge]*=np.linspace(0,1,edge);a[-edge:]*=np.linspace(1,0,edge)
 assert np.isfinite(a).all() and np.max(np.abs(a))<=1.0001
 with wave.open(str(path),'wb')as w:
  w.setparams((1,2,SR,len(a),'NONE','not compressed'));w.writeframes(np.rint(a*32767).astype('<i2').tobytes())
if __name__=='__main__':
 import argparse
 ap=argparse.ArgumentParser();ap.add_argument('--out');args=ap.parse_args()
 out=Path(args.out) if args.out else Path(__file__).resolve().parents[2]/'assets/audio/convoy'
 start=time.monotonic();radio,dry=metal();save(out/'raiders_radio.wav',radio);save(out/'police_siren.wav',siren())
 report={'origin':'Original procedural composition; no third-party recordings or samples','tempo_bpm':BPM,'bars':BARS,'seconds':len(radio)/SR,'peak_dbfs':20*np.log10(np.max(np.abs(radio))),'rms_dbfs':20*np.log10(np.sqrt(np.mean(radio**2))),'sha256':hashlib.sha256((out/'raiders_radio.wav').read_bytes()).hexdigest()}
 (out/'original_radio.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print('ORIGINAL_RADIO_READY',report,'build_seconds',time.monotonic()-start,flush=True)
