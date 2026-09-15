from pathlib import Path
import json,hashlib,difflib,re
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'record_payload.json').read_text(encoding='utf-8-sig'))
r=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert not r['failures'] and len(r['observations'])==36
source=root/'gameplay/sandbox_menu_music.gd'
assert source.read_text(encoding='utf-8')==json.loads((out/'final_payload.json').read_text(encoding='utf-8-sig'))['sandbox_menu_music.gd']
(out/'README.md').write_text(p['readme']+'\nPublication: automatic approval review rejected the scoped commit/push twice despite verified origin and standing workflow record. Local implementation/evidence are complete and uncommitted. Explicit fresh owner confirmation for uploading the code/assets to the exact GitHub destination is the only remaining publication step. No Git mutations or egress occurred in this pass.\n',encoding='utf-8')
builder=out/'build_assets.py';s=builder.read_text(encoding='utf-8')
s=s.replace("expected = 'b2e7","if not source.exists(): source = ROOT / 'assets/audio/music/OB_Bond.mp3'\nexpected = 'b2e7",1)
builder.write_text(s,encoding='utf-8')
old=(out/'music.before.gd').read_text(encoding='utf-8').rstrip('\n')+'\n';new=source.read_text(encoding='utf-8')
patch=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/gameplay/sandbox_menu_music.gd',tofile='b/gameplay/sandbox_menu_music.gd'))
(out/'music_playlist.patch').write_text(patch,encoding='utf-8',newline='\n')
receipt={'status':'IMPLEMENTED / NATIVE-VALIDATED; PUBLICATION BLOCKED','native_checks':36,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'baseline_sha256':hashlib.sha256((out/'music.before.gd').read_bytes()).hexdigest(),'faction_assignment':None,'publication':'No Git mutations; auto-review rejected commit/push as private code/assets egress lacking trusted payload/destination approval. Await explicit owner confirmation.','destination':'https://github.com/LeadLasso-LL/DEADSTREET.git','branch':'build/arsenal-checkpoint-20260911'}
(out/'change_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
blocked="\n\nPUBLICATION BLOCKED (2026-09-15 UTC): automatic approval review rejected the proposed scoped commit/push twice. Fresh remote check exactly matched https://github.com/LeadLasso-LL/DEADSTREET.git at ec7a60edaaa7d25493bdae523a6ab44d42148391 and the standing workflow authorization names that destination, but the review still requires trusted explicit user approval for this code/audio payload. No bypass, staging, commit or push performed. Current local implementation works through the existing live-source launcher. New files, patch, README and validation evidence saved. Next publication action: obtain explicit owner confirmation to push the Bond assets/catalogue/music delta and owned records to that GitHub repository, then scoped publish. Other chats' work remains untouched.\n"
for path,entry in p['entries'].items():
    dest=root/path;assert entry.splitlines()[0] not in dest.read_text(encoding='utf-8')
    entry=entry.replace('Scoped commit/push proceeding under standing owner authorization; publication receipt records exact hash.','Scoped publication blocked by automatic approval review; see status below.').replace('Own new files/assets and applied delta patch being scoped-published;','Own new files/assets and applied delta patch saved locally; publication blocked by automatic approval review;')
    with dest.open('a',encoding='utf-8') as f:f.write('\n\n'+entry+blocked)
    assert entry in dest.read_text(encoding='utf-8') and blocked in dest.read_text(encoding='utf-8')
print('LOCAL_WORK_AND_HANDOFF_SAVED_AND_VERIFIED; NO_GIT_ACTIONS',flush=True)
