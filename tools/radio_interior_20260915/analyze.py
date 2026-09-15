from pathlib import Path
import json,hashlib,subprocess
import numpy as np
out=Path(__file__).resolve().parent;root=out.parents[1]
native=json.loads((out/'native_validation.json').read_text());assert native['failures']==[]
rate=native['mix_rate'];freqs=[120,1000,4000,8000];amps={};peaks={}
for name in ['dry','vehicle','building','foreground']:
 raw=np.fromfile(out/('response_'+name+'.f32'),dtype='<f4').reshape(-1,2)
 y=raw.mean(axis=1)[4096:];t=np.arange(len(y))/rate
 design=np.column_stack([fun(2*np.pi*f*t) for f in freqs for fun in [np.cos,np.sin]])
 coeff=np.linalg.lstsq(design,y,rcond=None)[0].reshape(-1,2)
 amps[name]=np.linalg.norm(coeff,axis=1);peaks[name]=float(np.abs(raw).max())
assert min(amps['dry'])>.01
db={name:{str(f):round(float(20*np.log10(a/b)),2) for f,a,b in zip(freqs,amps[name],amps['dry'])} for name in amps if name!='dry'}
checks={
 'vehicle_preserves_bass':abs(db['vehicle']['120'])<1,
 'building_preserves_bass':abs(db['building']['120'])<1,
 'vehicle_softens_highs':db['vehicle']['4000']<-5 and db['vehicle']['8000']<-15,
 'building_is_more_enclosed':db['building']['4000']<db['vehicle']['4000']-1,
 'foreground_restores_detail':db['foreground']['4000']>db['vehicle']['4000']+4,
 'no_clipping':max(peaks.values())<.95,
 'no_resonant_boost':all(max(row.values())<1 for row in db.values()),
}
protected=json.loads((out/'protected_hashes.json').read_text())
checks['catalogue_menu_battle_audio_unchanged']=all(hashlib.sha256((root/p).read_bytes()).hexdigest()==sha for p,sha in protected.items())
report={'native_checks':native['checks'],'mix_rate':rate,'response_db_relative_to_dry':db,'peak_amplitudes':peaks,'checks':checks,'failures':[k for k,v in checks.items() if not v],'method':'Godot AudioEffectCapture after each private bus filter; four tone least-squares amplitude against dry reference. Native routing and transport validated separately. Not a subjective listening signoff.'}
(out/'measured_response.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2),flush=True);assert not report['failures']
