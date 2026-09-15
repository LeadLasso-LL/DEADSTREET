from pathlib import Path
import difflib,hashlib,json,re,subprocess
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=repo/'tools/music_controls_20260914'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=repo,input=input).decode('utf-8').strip()
source=repo/'gameplay/sandbox_menu_music.gd';payload=json.loads((out/'payload.json').read_text(encoding='utf-8'))
assert source.read_text(encoding='utf-8')==payload['sandbox_menu_music.gd'],'Concurrent Music edit'
text=source.read_text(encoding='utf-8')
old='or dock.get_global_rect().has_point(event.position):return'
assert text.count(old)==1
text=text.replace(old,'or (dock.is_visible_in_tree() and dock.get_global_rect().has_point(event.position)):return')
source.write_bytes(text.encode())
exe=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
result=subprocess.run([exe,'--path',str(repo),'--script','res://tools/music_controls_20260914/check_native.gd','--log-file',str(out/'native.log')],capture_output=True,timeout=60)
assert result.returncode==0,result.stdout[-2000:]+result.stderr[-2000:]
report=json.loads((out/'native_observations.json').read_text());assert not report['failures']
before=(out/'music.before.gd').read_text(encoding='utf-8')
patch=''.join(difflib.unified_diff(before.splitlines(True),text.splitlines(True),fromfile='a/gameplay/sandbox_menu_music.gd',tofile='b/gameplay/sandbox_menu_music.gd'))
(out/'music_controls.patch').write_bytes(patch.encode())
receipt={'status':'IMPLEMENTED / NATIVE-VALIDATED','checks':len(report['observations']),'failures':[], 'baseline_sha256':payload['baseline_sha256'],'current_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'file':'gameplay/sandbox_menu_music.gd','existing_launcher_uses_live_source':True,'publication_scope':'Owned delta patch and records only; full music script remains part of the opening chat uncommitted source.'}
(out/'change_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
(out/'README.md').write_text('''# Music controls — 14 September 2026

Owner requested click-outside dismissal plus pause and next-track symbols. The live sandbox_menu_music.gd now closes on an outside left/right click or touch press, consumes the dismissing event, preserves clicks within the panel and visible dock, and keeps playback unchanged. Pause uses two bars; its paused state uses a play triangle; Next uses a right triangle ending at a vertical bar. Icons are native SVG textures with text tooltips. The one-track Next control remains disabled.

Native live-source Godot4.7.2 exercise passed15 observations: open/reopen/dock-close, inside controls, outside dismissal, no click-through, uninterrupted playback, icons, pause/resume without restart, volume and scaled-window dismissal. Screenshot music_controls.png inspected. Command: Godot --path <repo> --script res://tools/music_controls_20260914/check_native.gd. See native_observations.json and change_receipt.json. No opening timing, media, launcher or battle changes; owner visual acceptance pending.

The opening chat's full music source was untracked before this task. Preserve its ownership: this checkpoint publishes only the narrow delta patch and owned evidence/records, not the entire pre-existing opening work. music_controls.patch is already applied to the live source; do not apply twice. Its baseline and final SHA256 are in change_receipt.json. The normal desktop sandbox launcher reads the changed file on next launch. The opening chat can include the combined source in its eventual opening checkpoint.
''',encoding='utf-8')
entry='''## 20260914-music-controls-02 - Outside dismissal and icon controls complete

IMPLEMENTED / NATIVE-VALIDATED in live gameplay/sandbox_menu_music.gd. Outside left/right click or tap closes the open Music box while preserving playback and pause state; dismissal is consumed so it cannot trigger a menu action underneath. Inside controls and the visible Music dock retain their actions. Pause is two vertical bars, paused state is a Play triangle, Next is a right triangle with an end bar. Native vector icons avoid font-dependent symbols; hover labels remain. Next stays disabled with only one supplied track.

Live Godot4.7.2 exercise passed15 observations, zero failures: opening/reopening, outside/inside/dock clicks, no click-through, same player/play_count1 and uninterrupted playback, icon swapping, pause/resume, volume and scaled-window dismissal. Native screenshot inspected. Evidence/delta/baseline hash: tools/music_controls_20260914/README.md, music_controls.patch, change_receipt.json, native_observations.json and check_native.gd. This is a focused UI check, not an opening/battle regression run. Existing normal launcher uses live source; reopen it to load the changes. Owner visual acceptance pending.

The underlying opening/music files remain the opening chat's uncommitted work. Publish only our narrow patch/evidence and own record sections; do not stage the full pre-existing music file. Opening/portrait/audio work preserved. Next: owner reviews; opening chat includes the combined music source when publishing its larger checkpoint. No further implementation needed for these two requests.
'''
path='docs/DEAD_STREET_JOURNAL.md';p=repo/path;assert entry.splitlines()[0] not in p.read_text(encoding='utf-8')
with p.open('a',encoding='utf-8') as f:f.write('\n\n'+entry)
hive='''## Music controls current - 20260914-music-controls-02

Chat3ca0ac6a33c3 completed outside-click/tap dismissal and pause/play/next icons in the live sandbox_menu_music.gd. Native15 observations PASS; playback/state/inside controls preserved, no dismissal click-through. Existing desktop launcher loads the changes on restart. Full music source remains opening chat's uncommitted ownership; only the owned delta patch/evidence/records are published. Opening chat3438f1ea0e55 should include this already-applied delta in its later opening checkpoint; portrait/audio work unchanged. See journal music-controls-02 and tools/music_controls_20260914/README.md. Owner visual acceptance pending.
'''
with (repo/'docs/DEAD_STREET_HIVE_MIND.md').open('a',encoding='utf-8') as f:f.write('\n\n'+hive)
control='''## 2026-09-14 - Music panel dismissal and transport icons

IMPLEMENTED / NATIVE-VALIDATED: click/tap outside the Music box to close it without stopping music; two-bar pause, play when paused, right triangle/end-bar Next. Fifteen focused native observations passed; screenshot checked. Live-source desktop entry uses the changes on restart. Next remains disabled for the one-track catalogue. Full opening source remains uncommitted under opening chat ownership; this task records/publishes only its delta and evidence. See journal music-controls-02 and tools/music_controls_20260914/README.md. Owner visual acceptance pending.
'''
with (repo/'docs/DEAD_STREET_PROJECT_CONTROL.md').open('a',encoding='utf-8') as f:f.write('\n\n'+control)
assert git('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert not git('diff','--cached','--name-only'),'Preserve concurrent staged work'
head=git('rev-parse','HEAD');docs={}
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',(repo/path).read_text(encoding='utf-8')):
        title=section.splitlines()[0] if section else ''
        if ('music-controls-' in title or 'Music panel dismissal and transport icons' in title) and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
owned=['tools/music_controls_20260914/'+n for n in ['README.md','music_controls.patch','change_receipt.json','native_observations.json','check_native.gd']]
git('add','--',*owned)
for path,value in docs.items():
    blob=git('hash-object','-w','--stdin',input=value.encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
assert git('rev-parse','HEAD')==head
git('diff','--cached','--check');print(git('commit','-m','Record live music popup dismissal and transport icon patch'),flush=True)
head=git('rev-parse','HEAD');branch='build/arsenal-checkpoint-20260911'
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=repo,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
print('MUSIC_PATCH_AND_RECORDS_PUSHED '+head,flush=True)
