"""Commit only this chat's validated changes and publish to the approved repository."""
from pathlib import Path
import hashlib,json,re,subprocess
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/sandbox_glossaries_20260914'
branch='build/arsenal-checkpoint-20260911'
def git(*args,input=None):
    return subprocess.check_output(['git',*args],cwd=repo,input=input).decode('utf-8').strip()
assert git('branch','--show-current')==branch
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert not git('diff','--cached','--name-only'),'Concurrent staged work; preserve it.'
for name in ['smoke.json','record.json']:
    report=json.loads((out/name).read_text());assert report['checks']==3684 and not report['errors']
assert json.loads((out/'delivery.json').read_text())['full_decode_passed']
source=['gameplay/arsenal_review.gd','gameplay/sandbox_force_builder.gd','gameplay/sandbox_menu_panels.gd','gameplay/sandbox_glossary_panel.gd']
hashes=json.loads((out/'source_hashes.json').read_text())
for path in source:assert hashlib.sha256((repo/path).read_bytes()).hexdigest()==hashes[path], 'Source changed after validation: '+path
before=git('rev-parse','HEAD')
docs={}
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    current=(repo/path).read_text(encoding='utf-8');base=git('show','HEAD:'+path)
    for section in re.split(r'(?m)(?=^## )',current):
        title=section.splitlines()[0] if section else ''
        own='sandbox-glossaries-' in title if 'JOURNAL' in path else 'Sandbox Glossary Panels' in title
        if own and title not in base:base+='\n\n'+section.strip()
    docs[path]=base.rstrip()+'\n'
path='docs/DEAD_STREET_HIVE_MIND.md'
current=(repo/path).read_text(encoding='utf-8');base=git('show','HEAD:'+path)
pattern=r'(?m)^\| Parallel assignment chat 3ca0ac6a33c3 \|.*$'
row=re.search(pattern,current).group()
assert re.search(pattern,base)
docs[path]=re.sub(pattern,lambda m:row,base).rstrip()+'\n'
owned=source+['assets/data/faction_glossary.json']
owned+=['tools/sandbox_glossaries_20260914/'+n for n in ['README.md','run_capture.py','validate.gd','encode_video.py','source_hashes.json','snapshot.json','smoke.json','record.json','delivery.json','library_receipt.json']]
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=text.encode());git('update-index','--cacheinfo','100644,'+blob+','+path)
staged=git('diff','--cached','--name-only').splitlines()
assert set(staged)==set(owned)|set(docs),(staged,owned)
assert git('rev-parse','HEAD')==before,'HEAD changed during scoped staging.'
git('diff','--cached','--check')
print(git('diff','--cached','--stat'),flush=True)
print(git('commit','-m','Add sandbox navigation and illustrated faction arsenal vehicle glossaries'),flush=True)
head=git('rev-parse','HEAD')
subprocess.run(['git','push','origin',head+':refs/heads/'+branch],cwd=repo,check=True)
remote=git('ls-remote','origin','refs/heads/'+branch).split()[0]
assert remote==head,(head,remote)
receipt=dict(status='PUSHED / VERIFIED',commit=head,remote=remote,branch=branch,origin='https://github.com/LeadLasso-LL/DEADSTREET.git',files=staged,checks=3684,errors=[],shared_release_runtime_modified=False,owner_visual_acceptance='PENDING')
(out/'checkpoint_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(receipt),flush=True)
