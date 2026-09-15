"""Create only a local commit; no push or network operation. Preserve concurrent docs."""
from pathlib import Path
import hashlib, json, re, subprocess
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/sandbox_tutorial_20260914'
def git(*args,input=None):
    return subprocess.check_output(['git',*args],cwd=repo,input=input).decode('utf-8').strip()
assert git('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert not git('diff','--cached','--name-only'),'Concurrent staged work: preserve it.'
assert json.loads((out/'smoke.json').read_text())['errors']==[]
assert json.loads((out/'record.json').read_text())['errors']==[]
hashes=json.loads((out/'source_hashes.json').read_text())
for path in ['gameplay/arsenal_review.gd','gameplay/sandbox_tutorial_panel.gd']:
    assert hashlib.sha256((repo/path).read_bytes()).hexdigest()==hashes[path], 'Source changed after validation: '+path
before=git('rev-parse','HEAD')
docs={}
for path in ['docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    current=(repo/path).read_text(encoding='utf-8')
    base=git('show','HEAD:'+path)
    sections=re.split(r'(?m)(?=^## )',current)
    for section in sections:
        title=section.splitlines()[0] if section else ''
        own=('sandbox-tutorial-' in title) if 'JOURNAL' in path else ('Sandbox Tutorial' in title)
        if own and title not in base:base+='\n\n'+section.strip()
    docs[path]=base+'\n'
path='docs/DEAD_STREET_HIVE_MIND.md'
current=(repo/path).read_text(encoding='utf-8')
row=next(line for line in current.splitlines() if line.startswith('| Parallel assignment chat 3ca0ac6a33c3 |'))
base=git('show','HEAD:'+path)
pattern=r'(?m)^\| Parallel assignment chat 3ca0ac6a33c3 \|.*$'
if re.search(pattern,base):base=re.sub(pattern,lambda m:row,base)
else:base+='\n\n## Parallel Tutorial checkpoint\n\n| Chat / owner | Scope | Last verified state / next action |\n| --- | --- | --- |\n'+row
docs[path]=base+'\n'
owned=['gameplay/arsenal_review.gd','gameplay/sandbox_tutorial_panel.gd','assets/tutorial/harold/harold.png','assets/tutorial/harold/harold.json']
owned+=['tools/sandbox_tutorial_20260914/'+name for name in ['README.md','capture.gd','run_capture.py','validate.gd','encode_video.py','source_hashes.json','snapshot.json','smoke.json','record.json','delivery.json']]
git('add','--',*owned)
for path,text in docs.items():
    blob=git('hash-object','-w','--stdin',input=text.encode())
    git('update-index','--cacheinfo','100644,'+blob+','+path)
staged=git('diff','--cached','--name-only').splitlines()
assert set(staged)==set(owned)|set(docs),(staged,owned)
assert git('rev-parse','HEAD')==before,'HEAD changed during scoped staging.'
git('diff','--cached','--check')
print(git('diff','--cached','--stat'),flush=True)
print(git('commit','-m','Add interactive Harold battle tutorial to sandbox'),flush=True)
head=git('rev-parse','HEAD')
receipt=dict(status='LOCAL COMMIT COMPLETE / PUSH BLOCKED',commit=head,branch='build/arsenal-checkpoint-20260911',files=staged,checks=73,errors=[],shared_release_runtime_modified=False,preview_library_id='libfile_d56b156bea7c81919ef35265ee17c7a9',publication_blocker='Automatic approval requires a user-authored message authorizing disclosure to https://github.com/LeadLasso-LL/DEADSTREET.git; repository-file authorization was rejected as untrusted. No push attempted by this local-only script.')
(out/'checkpoint_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt),flush=True)
