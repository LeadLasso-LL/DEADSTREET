from pathlib import Path
import json,hashlib,subprocess,re
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=root/'tools/soundtrack_extra_20260915'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input).decode('utf-8').strip()
branch='build/arsenal-checkpoint-20260911';destination='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert git('remote','get-url','origin')==destination
assert git('branch','--show-current')==branch
assert not git('diff','--cached','--name-only'),'Preserve concurrent staged work'
head=git('rev-parse','HEAD')
native=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert len(native['checks'])==25 and all(native['checks'].values()) and not native['failures']
audio=json.loads((out/'audio_validation.json').read_text(encoding='utf-8'));assert audio['count']==3 and not audio['failures']
assert all(json.loads((out/'integrity_validation.json').read_text()).values())
for path,digest in json.loads((out/'source_hashes.json').read_text(encoding='utf-8')).items():assert hashlib.sha256((root/path).read_bytes()).hexdigest()==digest,'Concurrent validated source change'
owned=['assets/data/music_catalog.json']
for t in audio['tracks']:
    for file,key in [('menu_file','menu_sha256'),('battle_file','battle_sha256')]:
        path=t[file].removeprefix('res://');assert path.startswith('assets/audio/music/')
        assert hashlib.sha256((root/path).read_bytes()).hexdigest()==t[key]
        owned.append(path)
owned += ['tools/soundtrack_extra_20260915/'+n for n in ['README.md','manifest.json','fetch_batch.mjs','build_batch.py','check_native.gd','download_report.json','audio_validation.json','native_validation.json','integrity_validation.json','source_hashes.json']]
docs={}
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',(root/path).read_text(encoding='utf-8')):
        title=section.splitlines()[0] if section else ''
        if ('soundtrack-extra-' in title or 'soundtrack-batch-06' in title) and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
(out/'publication_scope.json').write_text(json.dumps({'baseline_head':head,'owned_paths':owned,'docs':list(docs),'destination':destination,'branch':branch},indent=2)+'\n',encoding='utf-8')
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=text.encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
assert git('rev-parse','HEAD')==head,'Concurrent HEAD change'
git('diff','--cached','--check')
print(git('commit','-m','Add Glock Keys and Ripper menu songs and battle loops'),flush=True)
head=git('rev-parse','HEAD')
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=root,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
receipt={'status':'PUSHED / VERIFIED','commit':head,'branch':branch,'destination':destination,'new_tracks':3,'menu_total':22,'battle_loops':21,'native_checks':25,'owned_paths':owned,'docs':list(docs)}
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
entry='\n\n## 20260915-soundtrack-extra-05 - Glock, Keys and Ripper publication verified\n\nPUSHED / VERIFIED: '+head+' on origin/'+branch+'. Three full B-22 menu MP3s and three exact 30-second WAV loops published: Glock 30–60s, Keys 31–61s, Ripper 48–78s. Total 22 menu tracks / 21 battle loops. All audio validation, 25 native checks and four integrity checks passed; protected source and asset hashes verified before commit. Existing tracks, runtime sources, permissions and faction mapping unchanged. Scoped asset/catalogue/evidence and owned documentation only; concurrent work preserved. Next: reopen live-source sandbox to load all tracks; owner faction associations remain pending. Receipt and evidence: tools/soundtrack_extra_20260915/.\n'
for path in docs:
    with (root/path).open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in (root/path).read_text(encoding='utf-8')
print('EXTRA_PUSHED_VERIFIED '+head,flush=True)
