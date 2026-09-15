from pathlib import Path
import subprocess,sys,json,hashlib,os,tempfile
sys.stdout.reconfigure(encoding='utf-8')
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/raiders_recording'
def read(p):return p.read_text(encoding='utf-8')
def git(*args,env=None):
 p=subprocess.run(['git',*args],cwd=r,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90)
 assert p.returncode==0,(args,p.stdout,p.stderr)
 return p.stdout.strip()
assert git('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
movie=json.loads(read(o/'record.json'));mobile=json.loads(read(o/'mobile.json'));native=json.loads(read(o/'convoy_native.json'));video=json.loads(read(o/'video.json'));radio=json.loads(read(r/'assets/audio/convoy/original_radio.json'))
assert movie['phase']=='resolved' and movie['winner']=='attacker' and movie['radio_origin'].startswith('Original composition')
assert not movie['arrival_route_errors'] and not movie['outro_errors'] and movie['ambient_emitters']==3
assert native['checks']==102 and not native['errors']
assert mobile['filename']=='Dead_Street_Raiders_Victory_Mobile.mp4'
assert hashlib.sha256((o/mobile['filename']).read_bytes()).hexdigest()==mobile['sha256']
assert 'ORIGINAL_RECORDING_COMPLETE' in read(o/'record_original_job.log')
assert 'SCRIPT ERROR'not in read(o/'capture.log') and '\nERROR:'not in read(o/'capture.log')
assert hashlib.sha256((r/'assets/audio/convoy/raiders_radio.wav').read_bytes()).hexdigest()==radio['sha256']
assert not (r/'tools/convoy_arrival/sources/thrash_metal_thunderstorm10.mp3').exists()
assert 'credit_label'not in read(r/'tools/tactical_controls/raiders_record.gd')
for path,digest in json.loads(read(o/'original_source_hashes.json')).items():assert hashlib.sha256((r/path).read_bytes()).hexdigest()==digest,('Source changed since capture',path)
armor=movie['showcase_loadout']['attacker']['units'][0]['armor']
entry=f'''

## 2026-09-14 — Original-guitar Raiders victory recording (IMPLEMENTED / VALIDATED)

Brandon explicitly directed immediate completion after rejecting third-party music. The final radio is an original 102 BPM Drop-C groove-metal composition, built from plucked-string waveguides, a driven/cabinet-filtered amplifier, original bass and procedural drums. No recordings, borrowed samples or external music are used. The riff is filtered as a vehicle radio; police sirens are 3 dB quieter (-29 dB emitter gain). Source and deterministic asset metadata are in tools/convoy_arrival/build_audio.py and assets/audio/convoy/original_radio.json. The earlier additive riff and the removed third-party attempt are superseded. There is no outside-music credit overlay in the final video.

Corrected eastbound arrivals stay entirely within the lower carriageway, with no oncoming-lane overflow. The six-bike / Mesa formation, pillion and two bed occupants remain. Persistent selected-unit movement paths and target connector lines are hidden; brief command-placement/acknowledgement cues remain. The arrival camera keeps the formation clear of the banner.

The requested Raiders victory is staged through the recording fixture: tier-3 Raiders with {armor}, versus tier-1 unarmored NBPD. Global combat balance is unchanged; hits, casualties and contextual orders remain live. Seed {movie['seed']} resolves in an attacker victory after {movie['combat_seconds']:.2f} simulated combat seconds, with {movie['audio_shots']} shot events and {len(movie['commands'])} contextual commands. The director releases later stale Hold orders as support loses contact. This is showcase staging, not a faction-balance comparison.

Validation: the lane/arrival pass previously passed 102 native checks, including all seven east-facing bodies entirely within y=31..44, legal seating and dismounts. The final capture has zero arrival/outro route errors, three ambient emitters and no final script/engine errors. Full video decode and finite/unclipped audio checks passed. Final visual review checked arrival, combat and result frames. No performance campaign or exhaustive all-map regression was reopened. Audio quality remains subject to Brandon's listening review; numerical checks are not aesthetic approval.

Mobile file: {mobile['seconds']:.2f} seconds, 1280x720 at 30 FPS, H.264/AAC, {mobile['bytes']/1048576:.2f} MiB. SHA256 {mobile['sha256']}. Original radio SHA256 {radio['sha256']}. Source hashes captured before recording are checked before this commit. Earlier recordings are superseded. Commit/push uses standing approval and excludes unrelated work. Delivery/save status is reported in chat.

Next: Brandon reviews the completed original-audio Raiders-victory video. Performance and Whittaker Estate remain parked.
'''
p=r/'docs/DEAD_STREET_JOURNAL.md';s=read(p);assert 'Original-guitar Raiders victory recording (IMPLEMENTED / VALIDATED)'not in s;p.write_bytes((s+entry).encode())
p=r/'docs/DEAD_STREET_PROJECT_CONTROL.md';s=read(p);p.write_bytes(('''## Current milestone — original-audio Raiders victory video — 2026-09-14

IMPLEMENTED / VALIDATED; owner review pending. Correct eastbound arrivals, hidden
persistent unit paths and quieter sirens are included in the final mobile video.
The radio uses an original heavy guitar riff; no outside music or samples are used.
The requested Raiders win uses a disclosed veteran/equipment advantage in the
recording fixture. Global combat balance is unchanged. The lane/arrival pass had
102 native checks; final capture has zero route or script errors and passed video
decode/audio checks. Details, hashes and limits are in the latest journal.

Next: Brandon reviews the completed Raiders-victory video with original audio.
Performance and Whittaker remain parked. Earlier conflicting milestones are history.

'''+s).encode())
p=r/'docs/DEAD_STREET_HIVE_MIND.md';s=read(p);a=s.index('**Active objective:**');z=s.index('\n\n| Work',a);s=s[:a]+"**Active objective:** Deliver the completed original-audio Raiders-victory mobile video and obtain Brandon's review. Correct road side, original heavy guitar, quieter sirens and hidden unit paths are implemented and validated. The third-party music attempt was rejected and removed; it is excluded from the final build and video. Performance and Whittaker remain parked."+s[z:]
a=s.index('**Immediate next task:**');z=s.index('\n\n**Known gaps:**',a);s=s[:a]+"**Immediate next task:** Brandon reviews the completed Raiders-victory video with original audio. [Convoy details](../tools/convoy_arrival/README.md)."+s[z:]
rows=s.splitlines()
for i,row in enumerate(rows):
 if row.startswith('| Scripted battle recording |'):rows[i]='| Scripted battle recording | This receiving chat | Original-audio Raiders-victory video complete; corrected lane, hidden paths, quieter sirens; owner review next. |'
s='\n'.join(rows)+'\n';s=s.replace('Coordination last reconciled: 2026-09-14, after cover-aware line commands and native review.','Coordination last reconciled: 2026-09-14, after original-audio Raiders-victory recording.')
s=s.replace('This supersedes the owner-review next step above; performance and Whittaker remain parked.','This was completed by the original-audio revision above; owner review is next. Performance and Whittaker remain parked.')
p.write_bytes(s.encode())
p=r/'tools/convoy_arrival/README.md';s=read(p);a=s.index('The original distorted-guitar radio loop');z=s.index('\n## Reproduction',a)
s=s[:a]+'''West-approach bridge convoys face east on the lower carriageway, with every body
inside y=31..44. The oncoming road is not overflow parking; normal placement fails
if a convoy cannot fit. The arrival camera frames the formation below the banner.

The radio cue is an original 102 BPM Drop-C groove-metal riff, generated by
`build_audio.py`: plucked-string waveguides, driven amplifier/cabinet, original
bass and procedural drums. No borrowed recordings, samples or external music are
used. The prior additive riff and the removed third-party attempt are superseded.
The radio uses a 145–2850 Hz distant-vehicle response and -16 dB source gain.
Two localized NBPD sirens use -29 dB gain, 3 dB below the prior mix. Audio toggle,
source falloff and gunfire ducking remain enabled. Asset provenance/hash is in
`assets/audio/convoy/original_radio.json`.

Persistent unit route and target connectors are hidden; brief command placement
and Hold acknowledgements remain. The current recording intentionally favors
veteran, better-armored Raiders against regular unarmored NBPD to show the requested
Raiders victory. This changes the showcase fixture, not global gameplay balance.
'''+s[z:];p.write_bytes(s.encode())
p=o/'README.md';s=read(p);s+='''

## Final original-audio recording — 2026-09-14

Current deliverable: `Dead_Street_Raiders_Victory_Mobile.mp4`.
Master: `Dead_Street_Raiders_Victory.mp4`. Earlier videos are superseded.
Build the original radio with `python tools/convoy_arrival/build_audio.py`, then
run `record_worker.py` for capture, master encode, mobile export and pack restoration.
The encoder requires a resolved attacker victory and clean arrival/outro routes.
`record.json` contains the full disclosed showcase loadout, seed and original-radio
provenance. `original_source_hashes.json` records sources at capture. Lane/arrival
validation has 102 checks; the final capture validates runtime/audio/export separately.
No third-party music or credit overlay is part of this final recording.
''';p.write_bytes(s.encode())
p=r/'docs/TACTICAL_CONTROLS_2026-09-13.md';s=read(p);s+='''

## 2026-09-14 — Owner path-overlay correction
Persistent selected-unit movement routes and target connection lines are hidden.
Selection still uses the glowing emblem and yellow ring. Brief Push/Fall Back
placement lines and Hold acknowledgements remain. This supersedes earlier route-line
presentation rules; command behavior is preserved.
''';p.write_bytes(s.encode())
paths=list(json.loads(read(o/'original_source_hashes.json')))+['assets/audio/convoy/original_radio.json','tools/convoy_arrival/README.md','tools/raiders_recording/convoy_native.json','tools/raiders_recording/probe.json','tools/raiders_recording/record.json','tools/raiders_recording/video.json','tools/raiders_recording/mobile.json','tools/raiders_recording/original_source_hashes.json','tools/raiders_recording/README.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md','docs/TACTICAL_CONTROLS_2026-09-13.md']
index=Path(tempfile.gettempdir())/'dead_street_original_record_index';index.unlink(missing_ok=True);env=os.environ.copy();env['GIT_INDEX_FILE']=str(index)
git('read-tree','HEAD',env=env);git('add','--',*paths,env=env);git('diff','--cached','--check',env=env)
print(git('diff','--cached','--stat',env=env),flush=True)
git('commit','-m','Finish Raiders victory recording with original heavy guitar and corrected arrivals',env=env)
git('reset','-q','HEAD','--',*paths)
head=git('rev-parse','HEAD');print('COMMITTED',head,flush=True)
git('push','origin','build/arsenal-checkpoint-20260911')
remote=git('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').split()[0];assert head==remote
receipt={'head':head,'remote':remote,'files':paths,'mobile_sha256':mobile['sha256'],'radio_sha256':radio['sha256'],'native_checks':native['checks']};(o/'original_commit_receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8');print('PUSH_VERIFIED',head,flush=True)
