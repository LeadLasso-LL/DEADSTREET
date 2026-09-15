import subprocess
from pathlib import Path
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
def git(*args,input=None):return subprocess.check_output(['git',*args],cwd=r,input=input).decode().strip()
expected={'docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md','tools/sandbox_tutorial_20260914/README.md','tools/sandbox_tutorial_20260914/checkpoint_receipt.json'}
assert set(git('diff','--cached','--name-only').splitlines())==expected
assert git('rev-parse','HEAD')=='04034d81fc1727bcefa3f261c59ee6bf91dac213'
p='docs/DEAD_STREET_PROJECT_CONTROL.md'
text=git('show',':'+p).rstrip()+'\n'
blob=git('hash-object','-w','--stdin',input=text.encode())
git('update-index','--cacheinfo','100644,'+blob+','+p)
git('diff','--cached','--check')
print(git('commit','-m','Record approved tutorial publication and review status'),flush=True)
head=git('rev-parse','HEAD')
branch='refs/heads/build/arsenal-checkpoint-20260911'
subprocess.run(['git','push','origin',head+':'+branch],cwd=r,check=True)
remote=git('ls-remote','origin',branch).split()[0]
assert remote==head
print('PUBLICATION_AND_RECORDS_VERIFIED '+head,flush=True)
