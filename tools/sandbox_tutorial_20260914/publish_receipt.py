from pathlib import Path
import json, re, subprocess
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/sandbox_tutorial_20260914'
source='04034d81fc1727bcefa3f261c59ee6bf91dac213'
branch='build/arsenal-checkpoint-20260911'
def git(*args,input=None):
    return subprocess.check_output(['git',*args],cwd=repo,input=input).decode('utf-8').strip()
assert git('branch','--show-current')==branch
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert git('rev-parse','HEAD')==source
assert not git('diff','--cached','--name-only'),'Preserve concurrent staged work'
remote=git('ls-remote','origin','refs/heads/'+branch).split()[0]
assert remote==source
entry='''## 20260914-sandbox-tutorial-06 - Push approved and publication verified
- Direct owner message in chat 3ca0ac6a33c3: "Approved push. Will review shortly". This explicitly approves the previously named source/assets destination https://github.com/LeadLasso-LL/DEADSTREET.git and resolves the automatic-approval blocker in entries -04/-05. It is publication authorization, not visual acceptance of the Tutorial.
- PUSHED / VERIFIED: tutorial source checkpoint 04034d81fc1727bcefa3f261c59ee6bf91dac213 on origin/build/arsenal-checkpoint-20260911. Push completed successfully and ls-remote returned the exact commit. No forced push, unrelated source, or shared release runtime changes.
- Updated checkpoint_receipt.json, Hive Mind row and feature records to clear the resolved block. This follow-up publishes only owned tutorial records; concurrent opening/audio/source work remains preserved.
- Native validation remains 73 checks / zero errors; no code changed and no redundant test rerun. Preview remains libfile_d56b156bea7c81919ef35265ee17c7a9 v0. Owner will review shortly; Tutorial remains IMPLEMENTED / VALIDATED, owner acceptance pending. Future normal release packaging must include both tutorial image and JSON.
'''
path='docs/DEAD_STREET_JOURNAL.md'
current=(repo/path).read_text(encoding='utf-8')
assert '## 20260914-sandbox-tutorial-06 ' not in current
(repo/path).write_text(current.rstrip()+'\n\n\n'+entry,encoding='utf-8')
docs={}
base=git('show','HEAD:'+path)
for section in re.split(r'(?m)(?=^## )',(repo/path).read_text(encoding='utf-8')):
    title=section.splitlines()[0] if section else ''
    if re.match(r'^## .*sandbox-tutorial-(05|06)\b',title) and title not in base:base+='\n\n'+section.strip()
docs[path]=base+'\n'
path='docs/DEAD_STREET_HIVE_MIND.md'
current=(repo/path).read_text(encoding='utf-8')
pattern=r'(?m)^\| Parallel assignment chat 3ca0ac6a33c3 \|.*$'
row=re.search(pattern,current).group()
old='GitHub publication BLOCKED by auto-review pending direct destination authorization (journal sandbox-tutorial-04); local receipt records checkpoint.'
assert old in row
new=row.replace(old,'PUSHED / VERIFIED: 04034d8; owner directly approved publication, visual review pending (journal sandbox-tutorial-06).')
(repo/path).write_text(re.sub(pattern,lambda m:new,current),encoding='utf-8')
docs[path]=re.sub(pattern,lambda m:new,git('show','HEAD:'+path))+'\n'
path='docs/DEAD_STREET_PROJECT_CONTROL.md'
current=(repo/path).read_text(encoding='utf-8')
pattern=r'(?ms)^## 2026-09-14 - Sandbox Tutorial\n.*?(?=^## |\Z)'
section=re.search(pattern,current).group().rstrip()
section+='\n\nPublication: owner explicitly approved the push; source 04034d81fc1727bcefa3f261c59ee6bf91dac213 is PUSHED / VERIFIED on origin/build/arsenal-checkpoint-20260911. Prior automatic-approval block resolved. Visual owner review remains pending; see journal sandbox-tutorial-06.\n\n\n'
(repo/path).write_text(re.sub(pattern,lambda m:section,current),encoding='utf-8')
docs[path]=re.sub(pattern,lambda m:section,git('show','HEAD:'+path))+'\n'
path=out/'checkpoint_receipt.json'
receipt=json.loads(path.read_text())
receipt['status']='PUSHED / VERIFIED'
receipt['remote_verified_commit']=source
receipt['origin']='https://github.com/LeadLasso-LL/DEADSTREET.git'
receipt['owner_message']='Approved push. Will review shortly'
receipt['owner_visual_acceptance']='PENDING'
receipt['prior_publication_blocker']=receipt.pop('publication_blocker')
receipt['publication_blocker']='RESOLVED by direct owner approval; source push succeeded and remote commit verified.'
path.write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
path=out/'README.md'
current=path.read_text(encoding='utf-8')
current+='\nPublication: source checkpoint `04034d81fc1727bcefa3f261c59ee6bf91dac213` is pushed and verified on `origin/build/arsenal-checkpoint-20260911` after Brandon\'s direct approval. The previous automatic-approval block is resolved. Visual review remains pending.\n'
path.write_text(current,encoding='utf-8')
owned=['tools/sandbox_tutorial_20260914/README.md','tools/sandbox_tutorial_20260914/checkpoint_receipt.json']
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=text.encode())
    git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
git('diff','--cached','--check')
print(git('diff','--cached','--stat'),flush=True)
print(git('commit','-m','Record approved tutorial publication and review status'),flush=True)
head=git('rev-parse','HEAD')
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=repo,check=True)
remote=git('ls-remote','origin','refs/heads/'+branch).split()[0]
assert remote==head,(remote,head)
print('PUBLICATION_AND_RECORDS_VERIFIED '+head,flush=True)
