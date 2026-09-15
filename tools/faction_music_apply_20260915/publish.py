from pathlib import Path
import json,hashlib,subprocess,re
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=root/'tools/faction_music_apply_20260915'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input).decode('utf-8').strip()
branch='build/arsenal-checkpoint-20260911';destination='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert git('remote','get-url','origin')==destination and git('branch','--show-current')==branch
assert not git('diff','--cached','--name-only'),'Concurrent staging; preserve it'
head=git('rev-parse','HEAD')
v=json.loads((out/'native_validation.json').read_text());assert len(v['checks'])==115 and not v['failures'] and all(v['checks'].values())
c=json.loads((out/'correction_validation.json').read_text());assert len(c)==13 and all(c.values())
hashes=json.loads((out/'source_hashes.json').read_text())
for p,h in hashes.items():assert hashlib.sha256((root/p).read_bytes()).hexdigest()==h
catalog=json.loads((root/'assets/data/music_catalog.json').read_text(encoding='utf-8'))
a=json.loads((out/'approved_assignments.json').read_text(encoding='utf-8'))
assert a['status']=='owner_approved' and catalog['faction_tracks']==a['faction_tracks']
assert len(set(catalog['faction_tracks'].values()))==21 and catalog['faction_tracks']['calle_ocho']=='glock_b22' and catalog['faction_tracks']['union_sur']=='burn_b22'
owned=list(hashes)
owned += ['tools/faction_music_apply_20260915/'+p for p in ['README.md','approved_assignments.json','pre_correction_assignments.json','runtime.patch','native_validation.json','correction_validation.json','source_hashes.json','check_native.gd','check_correction.gd','before_tactical_convoy_audio.gd']]
owned += ['tools/faction_music_picker_20260915/'+p for p in ['README.md','picker.gd','Open-Faction-Music-Assignments.cmd','validation.json']]
docs={}
for path in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',(root/path).read_text(encoding='utf-8')):
        title=section.splitlines()[0] if section else ''
        if any(marker in title for marker in ['faction-music-apply-','faction-music-picker-','soundtrack-extra-05']) and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
(out/'publication_scope.json').write_text(json.dumps({'baseline_head':head,'owned':owned,'docs':list(docs),'destination':destination,'branch':branch},indent=2),encoding='utf-8')
git('add','--',*owned)
for p,s in docs.items():
    blob=git('hash-object','-w','--stdin',input=s.encode());git('update-index','--cacheinfo','100644,'+blob+','+p)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
assert git('rev-parse','HEAD')==head
git('diff','--cached','--check')
print(git('commit','-m','Assign approved faction soundtrack loops and preserve authority sirens'),flush=True)
head=git('rev-parse','HEAD');subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=root,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
(out/'publication_receipt.json').write_text(json.dumps({'status':'PUSHED / VERIFIED','commit':head,'branch':branch,'destination':destination,'factions':21,'distinct_loops':21,'wiring_checks':115,'correction_checks':13},indent=2)+'\n',encoding='utf-8')
entry='\n\n## 20260915-faction-music-apply-06 - Final faction soundtrack publication verified\n\nPUSHED / VERIFIED '+head+' on origin/'+branch+'. Final21 unique faction loops installed, including Calle Ocho=Glock and La Union del Sur=Burn; exact other20 screenshot choices retained. TRC/NBPD keep their prior sirens. Three audio source/catalogue files, owner mappings, assignment utility, native evidence and owned documentation only.115 wiring checks plus13 correction checks passed; source hashes verified. Reopen live-source sandbox for faction audio. No mapping decisions remain; subjective mix review can follow in normal play. Menu playlist and audio assets unchanged.\n'
for path in docs:
    with (root/path).open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in (root/path).read_text(encoding='utf-8')
print('FACTION_MUSIC_PUSHED_VERIFIED '+head,flush=True)
