from pathlib import Path
import subprocess,json,shutil,hashlib
r=Path('C:/Users/brand/OneDrive/Documents/dead-street');out=r/'tools/whittaker_estate';j=json.loads((out/'owner_feedback_20260914/record.json').read_text())
assert j['phase']=='resolved' and not j['presentation_errors'] and not j['outro_errors'] and not j['arrival_route_errors'] and j['camera_safety_violations']==0
assert all(x['pitch_scale']==.5 for x in j['horn_gain_samples'])
assert {x['vehicle']:x['count'] for x in j['arrival_manifest']}=={'aegis':7,'watchdog':5,'vigil':4}
print('NATIVE_VERIFIED',json.dumps({k:j[k] for k in ['winner','combat_seconds','actor_frame_checks','max_outro_jump_pixels','result_camera_jump_pixels','seconds']}),flush=True)
p=r/'tools/tactical_controls/estate_record.gd';s=p.read_text();s=s.replace('  if presentation.stage=="ready" and presentation.ready_clock>.7:\n   for vehicle','  if presentation.stage=="ready" and presentation.ready_clock>.7:\n   capture("opening_cover")\n   for vehicle');p.write_text(s)
archive=out/'owner_feedback_20260914/prior_version2';archive.mkdir(exist_ok=True)
for name in ['estate_raw.avi','record.json','record_source_hashes.json','delivery.json','Dead_Street_Whittaker_Estate_Mobile.mp4','capture.log']:
 p=out/name
 if p.exists():
  assert not (archive/name).exists(),name
  shutil.move(str(p),str(archive/name)) if name=='estate_raw.avi' else shutil.copy2(p,archive/name)
p=r/'docs/DEAD_STREET_JOURNAL.md';s=p.read_text(encoding='utf-8');s+='\n\n## 20260914-active-resume-15 - Final native audit passed; capture starting\n\nExact Workhorse placement verified at 116,74. Native audit after this move resolved with '+j['winner']+' victory at '+str(round(j['combat_seconds'],3))+' seconds. '+str(j['actor_frame_checks'])+' actor-frame checks, zero presentation/arrival/outro errors, zero HUD camera violations, result camera jump '+str(j['result_camera_jump_pixels'])+' px. TRC pitch 0.5 and actual 7/5/4 dismount rows verified; all 16 covered and four Vigil flankers. This replaces the preceding intermediate geometry/outcome evidence. Capture pipeline accepts either natural winner, never forces it. Previous version-2 raw AVI and metadata preserved in owner_feedback_20260914/prior_version2. Final movie capture starting; do not repack while capture is running.\n';p.write_text(s,encoding='utf-8')
subprocess.run(['C:/Users/brand/AppData/Local/DeadStreetTools/python/python.exe',str(out/'record_worker.py')],cwd=r,check=True,timeout=900)
