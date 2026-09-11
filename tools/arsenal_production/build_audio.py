"""Original procedural model reports. No outside samples or licensed recordings."""
from pathlib import Path
import sys,json,hashlib,wave
import numpy as np
R=Path(__file__).resolve().parents[2];sys.path.insert(0,str(R/'tools/battle_audio'))
import refine_weapons as W
D=R/'assets/audio/weapons';D.mkdir(parents=True,exist_ok=True)
MODELS=json.loads((R/'assets/data/weapon_models.json').read_text())['models']
SR=W.SR
# attack brightness, pressure width, body decay, action delay: authored game sound identities.
TIMBRES={
'glock_17':(6200,.0013,.012,.055),'m1911':(4800,.0019,.018,.069),'usp':(5500,.0016,.015,.057),'cz75':(6900,.0012,.012,.049),'desert_eagle':(8900,.0021,.032,.090),'five_seven':(11000,.0008,.009,.047),
'uzi':(4600,.0007,.009,.031),'mac10':(7200,.0005,.006,.023),'mp5':(5600,.0008,.008,.038),'mp5k':(8400,.0006,.005,.027),'vector':(5000,.001,.007,.020),'p90':(10500,.0004,.005,.026),
'ak47':(11500,.00065,.025,.081),'mini14':(9100,.0008,.017,.098),'m4a1':(14500,.00045,.018,.067),'g36c':(16300,.0004,.013,.059),'scar_h':(10200,.0011,.036,.094),'aug':(12900,.0006,.020,.073),
'rem870':(5700,.0024,.052,.230),'moss500':(8200,.0018,.041,.205),'spas12':(4900,.0028,.060,.120),'benelli_m2':(7700,.0020,.041,.095),'benelli_m4':(6900,.0026,.047,.110),'saiga12':(8700,.0021,.043,.072),
'rem700':(13400,.0007,.043,.290),'sks':(9300,.0008,.025,.106),'svd':(14900,.0006,.035,.087),'ssg69':(11200,.0008,.039,.315),'awm':(16500,.0011,.067,.355),'psg1':(12400,.0009,.045,.102)}
def sample(m,i):
 seed=int.from_bytes(hashlib.sha256((m['id']+str(i)).encode()).digest()[:8],'little');W.rng=np.random.default_rng(seed)
 t=np.arange(int(.7*SR))/SR;hi,width,decay,action=TIMBRES[m['id']];j=W.rng.uniform(.95,1.05)
 kind=m['weapon_class'];low={'pistol':240,'smg':650,'rifle':350,'shotgun':80,'sniper':170}[kind]
 pressure={'pistol':1.2,'smg':.25,'rifle':.55,'shotgun':1.15,'sniper':.8}[kind]
 out=pressure*W.pressure(t,width*j)+.78*W.texture(t,low,hi*.65,decay*j)
 out+=({'pistol':.23,'smg':.35,'rifle':.95,'shotgun':.35,'sniper':1.2}[kind])*W.texture(t,hi*.38,hi,.0015 if kind=='smg' else .0027)
 if kind in ['rifle','shotgun','sniper']:out+=.45*W.texture(t,60,1050,decay*1.25)
 # Pump/bolt mechanics happen after the report; automatic actions remain brief.
 out+=W.mechanical(t,action,.05 if kind!='sniper' else .07,.006 if action<.2 else .014,950,4200)
 if m['id'] in ['rem870','moss500','rem700','ssg69','awm']:out+=W.mechanical(t,action+.09,.037,.005,1600,5400)
 out=W.band(out,38,18000);out=np.tanh(out*.8);out[:8]*=np.linspace(0,1,8);out[-240:]*=np.linspace(1,0,240);out*=.87/max(abs(out))
 return out

def main():
 report={};preview=[]
 for m in MODELS.values():
  for i in range(3):
   a=sample(m,i);assert np.isfinite(a).all() and max(abs(a))<.9
   path=D/f'{m["id"]}_{i}.wav'
   with wave.open(str(path),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(SR);f.writeframes((a*32767).astype('<i2').tobytes())
   e=np.cumsum(a*a);sp=abs(np.fft.rfft(a))**2;freq=np.fft.rfftfreq(len(a),1/SR)
   report[path.name]={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'peak_dbfs':float(20*np.log10(max(abs(a)))),'energy_90_ms':float(np.searchsorted(e,e[-1]*.9)/SR*1000),'centroid_hz':float(sum(sp*freq)/sum(sp))}
   if i==0:preview.extend([a,np.zeros(int(.45*SR))])
 assert len({r['sha256'] for r in report.values()})==90
 (D/'manifest.json').write_text(json.dumps({'source':'Original procedural synthesis; no external samples','revision':1,'variations':3,'assets':report},indent=2)+'\n')
 with wave.open(str(Path(__file__).parent/'arsenal_audio_comparison.wav'),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(SR);f.writeframes((np.concatenate(preview)*32767).astype('<i2').tobytes())
 print('AUDIO_COMPLETE 90 distinct reports; peak -1.21 dBFS; 30-model comparison')
if __name__=='__main__':main()
