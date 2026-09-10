from pathlib import Path
import json,shutil,subprocess,hashlib
r=Path(__file__).resolve().parents[2];ref=r/'docs/references/battle_polish';ref.mkdir(parents=True,exist_ok=True)
results=r/'tools/battle_polish/results'
for name in ['checks.json','handoff.json','variants.json','sweep.json','seed_2011.json','video_integrity.json','audio_mix_validation.json','video_arrival.png','video_combat.png','video_results.png']:
 shutil.copy2(results/name,ref/name)
baseline=[]
raw=(r/'tools/battle_polish/baseline.log').read_bytes()
for line in raw.decode('utf-16' if raw[:2] in [b'\xff\xfe',b'\xfe\xff'] else 'utf-8-sig').splitlines():
 if line.startswith('SWEEP '):baseline.append(json.loads(line[6:]))
(ref/'baseline.json').write_text(json.dumps(baseline,indent=2))
# Preserve the approved non-weapon sounds, and verify exact identity against the previous commit.
unchanged={}
for name in ['city','apartment_beat','engine','door','impact','reload','start','step_0','step_1','step_2','step_3']:
 path=f'assets/audio/harold/{name}.wav';old=subprocess.check_output(['git','show','32920aa:'+path],cwd=r);current=(r/path).read_bytes();assert current==old,path;unchanged[name]=hashlib.sha256(current).hexdigest()
(ref/'preserved_audio.json').write_text(json.dumps(unchanged,indent=2))
print('Saved review evidence; all eleven non-weapon assets preserved exactly')
