"""Original reusable apartment trap loop. No recordings, samples, or licensed music."""
from pathlib import Path
import numpy as np,wave,json,hashlib
R=Path(__file__).resolve().parents[2]/'assets/audio/harold';SR=48000;BPM=72
rng=np.random.default_rng(104808);step=60/BPM/4;steps=64;n=round(step*steps*SR);mix=np.zeros(n)
def low(a,hz):
 f=np.fft.rfftfreq(len(a),1/SR);return np.fft.irfft(np.fft.rfft(a)/(1+(f/hz)**4),n=len(a))
def put(a,s,g=1):np.add.at(mix,(np.arange(len(a))+round(s*step*SR))%n,a*g)
def noise(n):return rng.normal(size=n)
# Eighth-note hats (every two grid steps); soft backbeat snares every eight.
for s in range(0,steps,2):
 t=np.arange(round(.08*SR))/SR;a=noise(len(t));a-=low(a,6000)
 put(a*np.exp(-t/.012),s,.026 if s%4 else .034)
for s in range(4,steps,8):
 t=np.arange(round(.20*SR))/SR
 sn=(noise(len(t))-low(noise(len(t)),900))*np.exp(-t/.030)
 sn+=np.sin(2*np.pi*185*t)*np.exp(-t/.035)*.35
 put(sn,s,.16)
# Sparse kick pattern plus pitched 808 sustain and slides, with variations across four bars.
notes=[41.203,36.708,32.703,38.891]
for bar,root in enumerate(notes):
 for pos,dur,shift in [(0,5,0),(6,2,7),(10,4,0),(14,2,-2)]:
  t=np.arange(round(dur*step*SR))/SR;hz=root*2**(shift/12)
  frequency=hz*(1+.08*np.exp(-t/.028))
  if pos==14:frequency*=1+.12*np.linspace(0,1,len(t))**3
  phase=2*np.pi*np.cumsum(frequency)/SR
  env=np.minimum(t/.006,1)*np.minimum((t[-1]-t)/.05,1)*np.exp(-t/1.8)
  bass=np.tanh(1.45*np.sin(phase))*.72+.12*np.sin(phase*2)
  put(bass*env,bar*16+pos,.38)
 for pos in [0,6,10]:
  t=np.arange(round(.15*SR))/SR;phase=2*np.pi*(48*t+80*.018*(1-np.exp(-t/.018)))
  put(np.sin(phase)*np.exp(-t/.052),bar*16+pos,.28)
 # Low, minor-key glassy motif, already subdued before wall filtering.
 for pos,ratio in [(2,4),(7,4.7568),(12,5.9932)]:
  t=np.arange(round(.7*SR))/SR
  a=(np.sin(2*np.pi*root*ratio*t)+.18*np.sin(2*np.pi*root*ratio*3*t))*np.exp(-t/.24)*np.minimum(t/.008,1)
  put(a,bar*16+pos,.027)
# The wall removes bright percussion while retaining the rhythm and 808 harmonics.
mix=low(mix,780);mix-=mix.mean();mix*=.66/max(abs(mix))
# Events wrap into the beginning; the periodic FFT filter preserves a continuous loop.
data=(mix*32767).astype('<i2')
with wave.open(str(R/'apartment_beat.wav'),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(data.tobytes())
report={'source':'Original synthesis, no external audio','seed':104808,'bpm':BPM,'grid':'16 steps per bar; hats every 2; snares every 8','bars':4,'wall_lowpass_hz':780,'seconds':n/SR,'peak_dbfs':float(20*np.log10(max(abs(mix)))),'loop_boundary_delta':float(abs(mix[0]-mix[-1])),'sha256':hashlib.sha256((R/'apartment_beat.wav').read_bytes()).hexdigest()}
assert report['loop_boundary_delta']<.02
(R/'APARTMENT_TRAP.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
