from pathlib import Path
import json,re,subprocess
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=repo/'tools/sandbox_glossaries_20260914'
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=repo,input=input).decode('utf-8').strip()
r=json.loads((out/'checkpoint_receipt.json').read_text());source=r['commit'];branch=r['branch']
assert r['status']=='PUSHED / VERIFIED' and git('rev-parse','HEAD')==source
assert not git('diff','--cached','--name-only')
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==source
entry=f'''## 20260914-sandbox-glossaries-05 - Source publication verified

PUSHED / VERIFIED: {source} on origin/{branch}, using Brandon's direct push authorization. Remote returned the exact source commit. All four menu sources, faction glossary data, validation/preview evidence and only this chat's shared-record sections were published. Shared release runtime and other chats' source/assets/uncommitted work remain preserved.

Preview remains libfile_5979eacadd048191b4f35b665e6defc4 v0, 79.63s / 2,365,809 bytes, SHA256 a0c550be3815f8fcc045d6dfa17a35f2c3138590dee248205260c9eeb71d5522. Both native runs passed 3,684 checks. No further code changes or test reruns. IMPLEMENTED / VALIDATED; owner visual acceptance pending. Opening chat must use the current menu/data/assets in its pack; native opening/music/launcher integration remains its separate active scope. Next: owner reviews this preview and the completed opening build. No unresolved defect found in this menu scope.
'''
docs={};path='docs/DEAD_STREET_JOURNAL.md';p=repo/path
assert entry.splitlines()[0] not in p.read_text(encoding='utf-8')
with p.open('a',encoding='utf-8') as f:f.write('\n\n'+entry)
docs[path]=git('show','HEAD:'+path).rstrip()+'\n\n'+entry
path='docs/DEAD_STREET_HIVE_MIND.md';p=repo/path;s=p.read_text(encoding='utf-8');pattern=r'(?m)^\| Parallel assignment chat 3ca0ac6a33c3 \|.*$';row=re.search(pattern,s).group()
old='Scoped publication underway (journal sandbox-glossaries-04).';assert old in row
row=row.replace(old,'PUSHED / VERIFIED: '+source[:7]+' (journal sandbox-glossaries-05).')
p.write_text(re.sub(pattern,lambda m:row,s),encoding='utf-8')
docs[path]=re.sub(pattern,lambda m:row,git('show','HEAD:'+path)).rstrip()+'\n'
path='docs/DEAD_STREET_PROJECT_CONTROL.md';p=repo/path;s=p.read_text(encoding='utf-8');pattern=r'(?ms)^## 2026-09-14 - Sandbox Glossary Panels\n.*?(?=^## |\Z)';section=re.search(pattern,s).group().rstrip()
section+='\n\nPublication: source '+source+' is PUSHED / VERIFIED on origin/'+branch+'. Owner visual acceptance remains pending. See journal sandbox-glossaries-05.\n\n'
p.write_text(re.sub(pattern,lambda m:section,s),encoding='utf-8')
docs[path]=re.sub(pattern,lambda m:section,git('show','HEAD:'+path)).rstrip()+'\n'
owned=['tools/sandbox_glossaries_20260914/checkpoint_receipt.json']
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=(text.rstrip()+'\n').encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
assert set(git('diff','--cached','--name-only').splitlines())==set(owned)|set(docs)
git('diff','--cached','--check');print(git('commit','-m','Record glossary publication and opening build handoff'),flush=True)
head=git('rev-parse','HEAD');subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=repo,check=True)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head
print('GLOSSARY_SOURCE_AND_RECORDS_PUBLISHED '+head,flush=True)
