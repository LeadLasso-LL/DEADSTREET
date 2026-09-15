from pathlib import Path
import subprocess,json,hashlib,shutil,time
r=Path(__file__).resolve().parents[2];d=Path(__file__).resolve().parent;python=r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe'
with (d/'render_installed.log').open('w') as log:subprocess.run([python,str(d/'render.py')],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
record=json.loads((d/'render.json').read_text());assert record['frames']==720
with (d/'native_installed.log').open('w') as log:subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--resolution','1280x720','--position','2000,0','--fixed-fps','30','--disable-vsync','--script','res://tools/montage_action_20260915/native_review.gd'],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=100)
native=json.loads((d/'native_validation.json').read_text());assert native['passed'] and native['max_position']>23.9
baseline=json.loads((d/'baseline.json').read_text());target=r/'assets/menu/opening/montage.ogv'
assert hashlib.sha256(target.read_bytes()).hexdigest()==baseline['assets/menu/opening/montage.ogv'],'Montage changed concurrently'
other=['assets/menu/opening/approved_title.png','assets/menu/opening/camera_ui.png','assets/menu/opening/B-22_Dead_Street.mp3']
assert all(hashlib.sha256((r/n).read_bytes()).hexdigest()==baseline[n] for n in other),'Title/music/UI changed concurrently'
shutil.copy2(target,d/'montage_before.ogv')
shutil.copy2(d/'montage_candidate.ogv',target)
assert hashlib.sha256(target.read_bytes()).hexdigest()==record['candidate_sha256']
receipt={'installed_sha256':record['candidate_sha256'],'preview_sha256':record['sha256'],'preview_bytes':record['bytes'],'native':native,'title_music_camera_unchanged':True,'production_files_changed':['assets/menu/opening/montage.ogv'],'preview_type':record['review_type']}
(d/'installation.json').write_text(json.dumps(receipt,indent=2))
entry='''\n\n## 20260915-montage-action-02 - Action montage installed and validated
Replaced only assets/menu/opening/montage.ogv. Exactly720frames/24s at1280x720/30fps;12hard-cut shots across all5sandbox maps. Added3 final Ravicci/Doble Ocho cuts and3 corrected Freight-stability cuts;2Harold,2Bridge and2Whittaker (including convoy already in frame atsource7.5s). Tight varied static crops use2.0-3.33x display scaling; native pixel sampling, monochrome/vignette treatment and approved title/music/UI retained. Freight receives a small pre-grade lift. No artificial shake, optical oscillation, freeze padding, movement-only filler or empty convoy lead-in intended. Shot in/out/count/crop/source hashes are recorded in tools/montage_action_20260915/shots.json and render.json.
Editorial checks inspected six samples per initial shot and full-size revised closing composition; selected clear firing/hits/casualty sequences. Rejected Freight movement-heavy windows and a lower closing crop that hid the action behind the title; final closing crop places fighters below lettering. Initial concat-demuxer assembly dropped9frames; replaced with filter concat and contiguous timestamps, preserving all720frames without padding. Original and rejected media retained.
Full video/audio decode PASS. Native Godot video test plays the exact final candidate through its24-second seam:1loop,6non-black frame samples,1280x720texture, no reported script errors. Guarded installation hash equals tested candidate. Approved title, camera UI and signature asset hashes unchanged. Concurrent caution-impacts work (startup video, sign/credits, sandbox_opening.gd) untouched. This is not full-intro/packed-export certification.
Review MP4 DEAD_STREET_Action_Montage.mp4 is a24-second edited preview of the exact installed loop with native title/UI placement, button at6seconds and existing signature section starting21seconds. It is not a new full intro capture. Preview saving pending; no owner acceptance, staging/commit/push. Next: save preview and owner reviews on reopening Sandbox. Full handoff: docs/handoffs/INTRO_ACTION_MONTAGE_20260915.md.
'''
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
 with (r/name).open('a',encoding='utf-8') as f:f.write(entry)
(r/'docs/handoffs/INTRO_ACTION_MONTAGE_20260915.md').write_text('# Intro action montage\n'+entry+'\nInstalled SHA256: '+record['candidate_sha256']+'\nPreview SHA256: '+record['sha256']+'\n',encoding='utf-8')
print('INSTALLED',json.dumps(receipt),flush=True)
