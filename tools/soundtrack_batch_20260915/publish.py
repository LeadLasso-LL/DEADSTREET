from pathlib import Path
import json,hashlib,subprocess,re
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=root/'tools/soundtrack_batch_20260915'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input).decode('utf-8').strip()
branch='build/arsenal-checkpoint-20260911';destination='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert git('remote','get-url','origin')==destination
assert git('branch','--show-current')==branch
assert not git('diff','--cached','--name-only'),'Preserve concurrent staged work'
head=git('rev-parse','HEAD')
native=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert len(native['checks'])==93 and not native['failures']
audio=json.loads((out/'audio_validation.json').read_text(encoding='utf-8'));assert audio['count']==17 and not audio['failures']
for path,digest in json.loads((out/'source_hashes.json').read_text(encoding='utf-8')).items():assert hashlib.sha256((root/path).read_bytes()).hexdigest()==digest,'Concurrent validated source change'
owned=['assets/data/music_catalog.json','tools/soundtrack_import_20260914/README.md']
for t in audio['tracks']:
    for file,key in [('menu_file','menu_sha256'),('battle_file','battle_sha256')]:
        path=t[file].removeprefix('res://');assert path.startswith('assets/audio/music/')
        assert hashlib.sha256((root/path).read_bytes()).hexdigest()==t[key]
        owned.append(path)
owned += ['tools/soundtrack_batch_20260915/'+n for n in ['README.md','manifest.json','fetch_batch.mjs','build_batch.py','check_native.gd','download_report.json','audio_validation.json','native_validation.json','source_hashes.json','playlist_top.png','playlist_bottom.png']]
# Record the new explicit owner approval before preparing the scoped index.
approval="## 20260915-soundtrack-batch-05 - Owner explicitly approved batch upload\n\nBrandon replied \"approved\" to the explicit request to upload the17-track batch to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the publication block in soundtrack-batch-04. Proceed with the validated34 new audio assets, catalogue, batch tools/evidence and owned records on build/arsenal-checkpoint-20260911; preserve other chats' work. No new processing or test reruns unless protected hashes changed. Publication receipt and final status follow.\n"
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    target=root/path
    if approval.splitlines()[0] not in target.read_text(encoding='utf-8'):
        with target.open('a',encoding='utf-8') as f:f.write('\n\n'+approval)

docs={}
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',(root/path).read_text(encoding='utf-8')):
        title=section.splitlines()[0] if section else ''
        if ('soundtrack-batch-' in title or 'bond-playlist-04' in title) and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
(out/'publication_scope.json').write_text(json.dumps({'baseline_head':head,'owned_paths':owned,'docs':list(docs),'destination':destination,'branch':branch},indent=2)+'\n',encoding='utf-8')
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=text.encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
assert git('rev-parse','HEAD')==head,'Concurrent HEAD change'
git('diff','--cached','--check')
print(git('commit','-m','Import 17 soundtrack songs and timed battle loops'),flush=True)
head=git('rev-parse','HEAD')
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=root,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
receipt={'status':'PUSHED / VERIFIED','commit':head,'branch':branch,'destination':destination,'new_tracks':17,'menu_total':19,'battle_loops':18,'native_checks':93,'owned_paths':owned,'docs':list(docs)}
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
entry='\n\n## 20260915-soundtrack-batch-06 - Seventeen-track publication verified\n\nPUSHED / VERIFIED: '+head+' on origin/'+branch+'. All17 full MP3s and17 exact30s WAV loops,19-song shared catalogue, batch source/mappings/evidence and owned records published.93 native checks passed; source/audio hashes reverified before commit. No permission changes, runtime code edits, faction mappings or unrelated-file staging. Earlier Bond/signature retained; current total19 menu songs/18 battle loops. Next: reopen normal live-source sandbox and provide faction associations when ready. Complete source/provenance/timing/processing and receipt in tools/soundtrack_batch_20260915/.\n'
for path in docs:
    with (root/path).open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in (root/path).read_text(encoding='utf-8')
print('BATCH_PUSHED_VERIFIED '+head,flush=True)
