"""Original deterministic Dead Street sound design. No third-party recordings or music."""
from pathlib import Path
import numpy as np,wave,json
R=Path(__file__).resolve().parents[2]/'assets/audio/harold';R.mkdir(parents=True,exist_ok=True)
SR=48000;rng=np.random.default_rng(90117)
def noise(n):return rng.normal(0,1,n)
def filt(a,cut,high=False):
 f=np.fft.rfftfreq(len(a),1/SR);h=1/(1+(f/cut)**6)
 return np.fft.irfft(np.fft.rfft(a)*((1-h) if high else h),n=len(a))
def write(name,a,peak=None):
 if peak:a=a*peak/max(np.max(abs(a)),1e-8)
 a=np.clip(a,-.95,.95);a[:min(90,len(a))]*=np.linspace(0,1,min(90,len(a))).reshape((-1,)+(1,)*(a.ndim-1))
 with wave.open(str(R/(name+'.wav')),'wb') as w:
  w.setnchannels(1 if a.ndim==1 else a.shape[1]);w.setsampwidth(2);w.setframerate(SR);w.writeframes((a*32767).astype('<i2').tobytes())
def gun(kind,i):
 t=np.arange(int(SR*.72))/SR
 decay,body,cut={'smg':(.031,115,6200),'rifle':(.054,82,8300),'pistol':(.027,155,7100),'shotgun':(.083,64,5100)}[kind]
 blast=filt(noise(len(t)),cut)*(np.exp(-t/decay)+.18*np.exp(-t/.12))
 crack=filt(noise(len(t)),1800,True)*np.exp(-t/.006)*1.35
 thump=np.sin(2*np.pi*(body*t+35*.024*(1-np.exp(-t/.024))))*np.exp(-t/.065)*1.8
 dry=np.tanh((blast+crack+thump)*1.3)
 dry*=np.exp(-t/.22)
 out=dry.copy()
 for delay,gain in [(.071,.17),(.113,.11),(.179,.07),(.247,.035)]:
  n=int(delay*SR);out[n:]+=filt(dry,2600)[:-n]*gain
 return out
for kind in ['smg','rifle','pistol','shotgun']:
 for i in range(3):write(f'{kind}_{i}',gun(kind,i),.83)
# Restrained shoe contact, mechanical handling and body/door impacts.
for i in range(4):
 t=np.arange(int(.16*SR))/SR;a=filt(noise(len(t)),1700)*np.exp(-t/.024)+.8*np.sin(2*np.pi*95*t)*np.exp(-t/.017)
 write('step_'+str(i),a,.38)
for name,decay,hz in [('door',.085,78),('impact',.048,125),('reload',.025,2200),('start',.18,82)]:
 t=np.arange(int(.6*SR))/SR;a=filt(noise(len(t)),3500)*np.exp(-t/decay)+np.sin(2*np.pi*hz*t)*np.exp(-t/(decay*.8))
 if name=='reload':
  n=int(.16*SR);a[n:]+=.65*a[:-n].copy()
 write(name,a,.55)
# Engine loop: low motor harmonics and soft tire texture; pitch is animated by the arrival.
t=np.arange(SR*4)/SR
engine=sum(np.sin(2*np.pi*(42*k*t+.06*np.sin(2*np.pi*1.5*t)))/k for k in range(1,8))*.12
engine+=filt(noise(len(t)),650)*.18;write('engine',engine,.45)
# Seamless city bed with slowly passing traffic and distant short horns.
duration=32;n=duration*SR;t=np.arange(n)/SR
bed=np.stack([filt(noise(n),1100),filt(noise(n),1100)],axis=1)*.026
bed+=np.sin(2*np.pi*60*t)[:,None]*.003
for center,side in [(5,-1),(16,1),(27,-1)]:
 env=np.exp(-((t-center)/2.6)**2);pan=np.tanh((t-center)/2)*side
 traffic=filt(noise(n),430)*.12+np.sin(2*np.pi*(75*t+7*np.sin(t*.22)))*.014
 bed[:,0]+=traffic*env*np.sqrt((1-pan)/2);bed[:,1]+=traffic*env*np.sqrt((1+pan)/2)
for start in [10.2,24.8]:
 tt=t-start;env=np.where((tt>=0)&(tt<.28),np.sin(np.clip(tt/.28,0,1)*np.pi)**2,0)
 horn=(np.sin(2*np.pi*310*t)+.6*np.sin(2*np.pi*390*t))*env*.013
 bed+=horn[:,None]*np.array([.7,.4])
# Cross-fade each loop's boundary without silence.
f=int(.2*SR)
for ch in range(2):
 blend=np.linspace(0,1,f);merged=bed[:f,ch]*blend+bed[-f:,ch]*(1-blend);bed[:f,ch]=merged;bed[-f:,ch]=merged
write('city',bed)
# Original 96 BPM four-bar minor-key hip-hop loop heard through an apartment wall.
beat=60/96;length=beat*16;n=round(length*SR);mix=np.zeros(n)
def put(a,at,gain=1):
 idx=(np.arange(len(a))+int(at*SR))%n;np.add.at(mix,idx,a*gain)
for bar in range(4):
 for beat_pos in [0,1.75,2.5]:
  tt=np.arange(int(.32*SR))/SR;k=np.sin(2*np.pi*(48*tt+85*.027*(1-np.exp(-tt/.027))))*np.exp(-tt/.12)
  put(k,(bar*4+beat_pos)*beat,.38)
 for beat_pos in [1,3]:
  tt=np.arange(int(.16*SR))/SR;sn=filt(noise(len(tt)),3600)*np.exp(-tt/.035)+np.sin(2*np.pi*175*tt)*np.exp(-tt/.022)*.3
  put(sn,(bar*4+beat_pos)*beat,.19)
 for sub in range(8):
  tt=np.arange(int(.07*SR))/SR;hat=filt(noise(len(tt)),4700,True)*np.exp(-tt/.011)
  put(hat,(bar*4+sub*.5+(.035 if sub%2 else 0))*beat,.08 if sub%2 else .12)
 for pos,note,dur in [(0,[41.2,41.2,32.7,36.7][bar],1.45),(2,49.,.7),(3,46.25,.6)]:
  tt=np.arange(int(beat*dur*SR))/SR;env=np.minimum(tt/.015,1)*np.minimum((tt[-1]-tt)/.08,1)
  bass=(np.sin(2*np.pi*note*tt)+.22*np.sin(2*np.pi*note*2*tt))*env
  put(bass,(bar*4+pos)*beat,.26)
 tt=np.arange(int(beat*3.8*SR))/SR
 chord=sum(np.sin(2*np.pi*h*tt) for h in [[164.8,196,246.9],[164.8,220,261.6],[130.8,164.8,196],[146.8,174.6,220]][bar])
 chord*=np.minimum(tt/.04,1)*np.exp(-tt/1.1);put(chord,bar*4*beat,.028)
mix=filt(mix,650);write('apartment_beat',mix,.58)
(R/'SOURCE.json').write_text(json.dumps({'creator':'Dead Street project / original procedural sound design','seed':90117,'sample_rate':SR,'music_bpm':96,'sources':'All waveforms synthesized by tools/battle_audio/build_audio.py. No external music, recordings or purchased assets.'},indent=2))
print('Built',len(list(R.glob('*.wav'))),'original WAV assets')

# Preserve the approved weapon and apartment revisions on a complete rebuild.
import subprocess,sys
for script in ['refine_weapons.py','build_apartment_trap.py']:
 subprocess.run([sys.executable,str(Path(__file__).with_name(script))],check=True)
metadata=json.loads((R/'SOURCE.json').read_text())
metadata.update(music_bpm=72,music_revision='APARTMENT_TRAP.json',weapon_revision='WEAPON_REVISION.json',sources='All waveforms are original synthesis. build_audio.py rebuilds the base ambience/foley and then applies refine_weapons.py and build_apartment_trap.py. No external recordings or music.')
(R/'SOURCE.json').write_text(json.dumps(metadata,indent=2))
