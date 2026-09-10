from pathlib import Path
import json,shutil,subprocess,hashlib
r=Path(__file__).resolve().parents[2];ref=r/'docs/references/battle_finish';ref.mkdir(parents=True,exist_ok=True)
results=r/'tools/battle_finish/results'
for name in ['checks.json','selection.json','video_integrity.json','audio_mix_validation.json','video_arrival.png','video_combat.png','video_results.png','check_comrades_settled.png','regroup_settled.png','enter_objective_settled.png']:
 shutil.copy2(results/name,ref/name)
for name in results.glob('seed_*.json'):shutil.copy2(name,ref/name.name)
for name in ['presentation_checks.json','checks.json']:
 src=r/'tools/battle_showcase/results'/name
 if src.exists():shutil.copy2(src,ref/('showcase_'+name))
unchanged={}
for name in ['city','engine','door','impact','reload','start','step_0','step_1','step_2','step_3']:
 path=f'assets/audio/harold/{name}.wav';old=subprocess.check_output(['git','show','aed913a:'+path],cwd=r);current=(r/path).read_bytes();assert current==old,path;unchanged[name]=hashlib.sha256(current).hexdigest()
(ref/'preserved_audio.json').write_text(json.dumps(unchanged,indent=2))
for log in ['validation','presentation','showcase','sample','capture']:
 p=r/f'tools/battle_finish/{log}.log'
 if not p.exists():continue
 raw=p.read_bytes();text=raw.decode('utf-16' if raw[:2] in [b'\xff\xfe',b'\xfe\xff'] else 'utf-8-sig',errors='replace')
 assert 'SCRIPT ERROR' not in text and 'problems=["' not in text,log
 (ref/(log+'_summary.txt')).write_text('\n'.join(line for line in text.splitlines() if any(x in line for x in ['VALIDATION','SHOWCASE_RESULT','MovieWriter'])))
print('Saved review evidence; heartbeat and nine other ambience/foley assets preserved exactly')
