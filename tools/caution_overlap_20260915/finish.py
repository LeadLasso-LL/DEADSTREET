from pathlib import Path
import json,hashlib,shutil,ctypes,os
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent
d=json.loads((o/'delivery.json').read_text());n=d['native']
assert n['status']=='PASS' and d['full_decode']=='PASS' and not d['concurrent_changes']
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
hashes=json.loads((o/'capture_hashes.json').read_text())
assert all(digest(r/name)==sha for name,sha in hashes.items()),'Source changed since capture'
video=Path(d['file']);assert digest(video)==d['sha256']
buf=ctypes.create_unicode_buffer(32768);assert ctypes.windll.shell32.SHGetFolderPathW(None,0,None,0,buf)==0
dest=Path(buf.value)/video.name
if dest.exists():assert digest(dest)==d['sha256'],'Desktop filename occupied'
else:shutil.copy2(video,dest)
assert digest(dest)==d['sha256'];os.startfile(str(dest))
note=f"\n\n## 20260915-caution-overlap-02 - Distributed hits and slower zoom complete\nIMPLEMENTED / NATIVE-VALIDATED / LOCAL VIDEO DELIVERED / OWNER REVIEW. Brandon rejected side-only bullet placements and 2.85s zoom speed. Five impacts now span CAUTION lettering, central text and lower/sprayed areas at (366,256),(968,366),(635,391),(420,463),(780,535). Timed stagger remains7.2-8.566667s; no gunshot players. One continuous zoom now6.85-11.8s (4.95s, previously2.85s), overlaps all impacts, keeps the same smooth projected focus with no reversal. Credits2.5s/3s and sign/blackout endpoint11.8, original title sequence, title21s and button27s retained.\nOnly production edit gameplay/sandbox_caution.gd; backup before_caution.gd in tools/caution_overlap_20260915. Current montage-action-03 media included in the isolated native recording; no montage edits. Native{n['checks']} checks PASS, including595-sample motion path, all five hits visible during zoom, zero sound players, full black maximum{n['black_max']}, title{n['title_at']:.6f}/button{n['button_at']:.6f}, actual sandbox entry{n['sandbox_at']:.6f}, signature play_count1. Native impact and zoom frames reviewed. No concurrent source changes.\nDelivered {video.name} to actual Windows Desktop and opened in default player; SHA256{d['sha256']}, {d['bytes']}bytes, {d['seconds']:.6f}s, {d['frames']}frames at1280x720/60fps H264/AAC. Full decode PASS, audio peak{d['audio_peak']:.6f}, no clipping. Source MovieWriter MJPEG0.95/PCM. Previous desktop recording preserved. No ChatGPT-only links.\nReproduction: capture.py creates isolated source/menu snapshot and runs review.gd against actual opening; use a fresh output directory because raw AVI must not exist. Evidence: capture_hashes.json, capture_command.json, native_review.json, native_intro.avi, capture.log, worker.log, delivery.json and native/encoded frames in tools/caution_overlap_20260915. Existing raw-image export warnings and ObjectDB shutdown warnings retained; no standalone-export or unrelated battle regression claim. Local uncommitted work, no stage/commit/push; HEAD35e0db12aae4d114364c911a69ae2136de30ee4e. Next: Brandon reviews local MP4; previous speed/layout review superseded, visual acceptance pending.\n"
(o/'README.md').write_text(note.lstrip(),encoding='utf-8')
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write(note)
short="\n\n## Current intro revision - 20260915-caution-overlap-02\nCOMPLETE / NATIVE-VALIDATED / OWNER REVIEW. Bullet hits distributed across lettering/middle/lower sign. Silent smooth zoom now4.95s (6.85-11.8), overlaps impacts; all section endpoints and title21/button27 preserved.37 native checks PASS; full34.58s720p60 MP4 through actual sandbox copied/verified to Desktop and opened: DEAD_STREET_Intro_Slower_Zoom.mp4. Includes current action montage without editing it. Source scope sandbox_caution.gd plus tools/caution_overlap_20260915. See its README and journal caution-overlap-02 for exact evidence, reproduction and limitations. Previous2.85s speed/side placements superseded. No commit/push; next owner local review.\n"
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:
 with (r/'docs'/name).open('a',encoding='utf-8') as f:f.write(short)
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:assert '20260915-caution-overlap-02' in (r/'docs'/name).read_text(encoding='utf-8')
(o/'desktop_delivery.json').write_text(json.dumps({'file':str(dest),'sha256':digest(dest),'player_launched':True,'records_verified':True},indent=2))
print(json.dumps({'desktop':str(dest),'sha256':digest(dest),'player_launched':True,'records_verified':True}),flush=True)
