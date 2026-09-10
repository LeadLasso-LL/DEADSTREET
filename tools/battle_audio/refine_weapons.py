"""Weapon-only revision. Preserve every ambience, music and heartbeat/start asset."""
from pathlib import Path
import numpy as np, wave, json
R=Path(__file__).resolve().parents[2]/'assets/audio/harold'; SR=48000
rng=np.random.default_rng(20260910)
def band(a,lo,hi):
 f=np.fft.rfftfreq(len(a),1/SR)
 h=(1-np.exp(-(f/max(lo,1))**4))*np.exp(-(f/hi)**4)
 return np.fft.irfft(np.fft.rfft(a)*h,n=len(a))
report={}
for kind,decay,low,high,body_gain,tail in [('smg',.022,180,10500,.48,.17),('rifle',.036,90,14500,.75,.25),('pistol',.026,130,12000,.52,.19),('shotgun',.065,48,9000,1.,.33)]:
 for i in range(3):
  t=np.arange(int(SR*.85))/SR
  # Short broadband pressure impulse, irregular low body, then diffuse street reflections.
  crack=band(rng.normal(size=len(t)),1600,high)*np.exp(-t/(.0018+rng.uniform(0,.0007)))
  blast=band(rng.normal(size=len(t)),low,high*.65)*np.exp(-t/decay)
  body=band(rng.normal(size=len(t)),low*.55,650)*np.exp(-t/(decay*1.7))*body_gain*2.4
  dry=crack*1.9+blast*.7+body
  dry/=max(abs(dry))
  out=dry.copy()
  # Reflections are filtered and diffuse, avoiding identical, evenly spaced laser-like echoes.
  for delay,gain in [(.043,.12),(.086,.08),(.137,.06),(.213,.035)]:
   n=int((delay+rng.uniform(-.004,.004))*SR)
   reflected=band(dry,180,3100)
   out[n:]+=reflected[:-n]*gain
  out+=band(rng.normal(size=len(t)),280,3600)*(.024 if kind!='shotgun' else .037)*np.exp(-t/tail)*(1-np.exp(-t/.025))
  # Restrained mechanical bolt / slide detail follows the report.
  n=int((.07 if kind!='shotgun' else .23)*SR)
  click=band(rng.normal(size=len(t)-n),1100,5500)*np.exp(-np.arange(len(t)-n)/SR/.009)*.026
  out[n:]+=click
  out[:12]*=np.linspace(0,1,12);out[-240:]*=np.linspace(1,0,240)
  out*=.88/max(abs(out))
  data=(out*32767).astype('<i2')
  path=R/f'{kind}_{i}.wav'
  with wave.open(str(path),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(data.tobytes())
  report[path.name]={'peak_dbfs':float(20*np.log10(max(abs(out)))),'rms_dbfs':float(20*np.log10(np.sqrt(np.mean(out*out)))),'seconds':len(out)/SR}
(R/'WEAPON_REVISION.json').write_text(json.dumps({'revision':2,'source':'Original procedural waveforms; no external samples','seed':20260910,'assets':report},indent=2))
print(json.dumps(report))
