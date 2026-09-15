from pathlib import Path
import json,hashlib,subprocess,re
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=root/'tools/soundtrack_import_20260914'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input).decode('utf-8').strip()
branch='build/arsenal-checkpoint-20260911'
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert git('branch','--show-current')==branch
assert not git('diff','--cached','--name-only'),'Preserve concurrent index'
head=git('rev-parse','HEAD')
report=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert not report['failures'] and len(report['observations'])==36
receipt=json.loads((out/'change_receipt.json').read_text(encoding='utf-8'))
assert hashlib.sha256((root/'gameplay/sandbox_menu_music.gd').read_bytes()).hexdigest()==receipt['source_sha256'],'Changed validated music source'
assets=json.loads((out/'audio_validation.json').read_text(encoding='utf-8'))
for file,key in [('OB_Bond.mp3','menu_sha256'),('OB_Bond_battle_21_51.wav','battle_sha256')]:
    assert hashlib.sha256((root/'assets/audio/music'/file).read_bytes()).hexdigest()==assets[key]
receipt['status']='IMPLEMENTED / NATIVE-VALIDATED; OWNER-APPROVED FOR PUBLICATION'
receipt['publication']='Brandon explicitly approved this code/audio upload to LeadLasso-LL/DEADSTREET on2026-09-15 UTC; scoped publication follows.'
(out/'change_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
readme=out/'README.md';s=readme.read_text(encoding='utf-8').split('\nPublication: automatic approval review')[0]
readme.write_text(s+'\nPublication authorized explicitly by Brandon on2026-09-15 UTC for these code/audio changes to https://github.com/LeadLasso-LL/DEADSTREET.git. This supersedes the prior automatic-review block.\n',encoding='utf-8')
entry='## 20260915-bond-playlist-03 - Explicit upload approval received\n\nBrandon replied "approved. report back quickly please." to the exact request to push the Bond code/audio changes to https://github.com/LeadLasso-LL/DEADSTREET. This supersedes the earlier publication blocker. Proceed with only the validated Bond assets, shared catalogue/loader, already-applied music delta/evidence and owned records on build/arsenal-checkpoint-20260911. No gameplay/audio rework or test rerun needed; native36 checks and asset/source hashes remain verified. Existing opening-source ownership and all unrelated work preserved. Publication result will be recorded in tools/soundtrack_import_20260914/publication_receipt.json and the live hive/journal.\n'
paths=['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']
for path in paths:
    p=root/path
    if entry.splitlines()[0] not in p.read_text(encoding='utf-8'):
        with p.open('a',encoding='utf-8') as f:f.write('\n\n'+entry)
docs={}
for path in paths:
    base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',(root/path).read_text(encoding='utf-8')):
        title=section.splitlines()[0] if section else ''
        if any(marker in title for marker in ['bond-playlist-','soundcloud-ob-test-','music-import-readiness-','music-import-title-rule-']) and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
owned=['gameplay/music_catalog.gd','assets/data/music_catalog.json','assets/audio/music/OB_Bond.mp3','assets/audio/music/OB_Bond_battle_21_51.wav']+['tools/soundtrack_import_20260914/'+name for name in ['README.md','build_assets.py','check_native.gd','audio_validation.json','native_validation.json','change_receipt.json','music_playlist.patch','playlist.png']]
git('apply','--reverse','--check','tools/soundtrack_import_20260914/music_playlist.patch')
git('add','--',*owned)
for path,value in docs.items():
    blob=git('hash-object','-w','--stdin',input=value.encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
assert git('rev-parse','HEAD')==head
git('diff','--cached','--check','--','.',':(exclude)tools/soundtrack_import_20260914/music_playlist.patch')
print(git('commit','-m','Add Bond soundtrack catalogue and looping battle excerpt'),flush=True)
head=git('rev-parse','HEAD')
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=root,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
(out/'publication_receipt.json').write_text(json.dumps({'commit':head,'branch':branch,'remote_verified':True,'owned_paths':owned,'docs':paths},indent=2)+'\n',encoding='utf-8')
done='\n\n## 20260915-bond-playlist-04 - Publication verified\n\nPUSHED / VERIFIED: '+head+' on origin/'+branch+'. Scoped new Bond assets/shared catalogue/loader/applied music delta, evidence and owned records published under explicit owner approval. Native36 checks already passed; source/audio hashes reverified before publishing, no rework or test rerun. Local live-source launcher loads the two-song menu; Bond30-second21-51 battle loop ready, faction assignment open. Original opening/music source and unrelated work remain separately owned/uncommitted. Next: owner bulk track submission and explicit faction associations. Receipt: tools/soundtrack_import_20260914/publication_receipt.json.\n'
for path in paths:
    with (root/path).open('a',encoding='utf-8') as f:f.write(done)
    assert done in (root/path).read_text(encoding='utf-8')
print('PUSHED_VERIFIED '+head,flush=True)
