from pathlib import Path
import subprocess,json
R=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');O=R/'tools/pistol_portrait_20260914'
def git(*a,**kw):return subprocess.check_output(['git',*a],cwd=R,stderr=subprocess.STDOUT,**kw)
assert not git('diff','--cached','--name-only').strip()
receipt=json.loads((O/'checkpoint_receipt.json').read_text());head=receipt['art_commit']
assert git('rev-parse','HEAD').decode().strip()==head
entry='\n\n## 20260914-pistol-portrait-04 - Published and remote-verified\n\nArt/source/evidence checkpoint '+head+' pushed to origin/build/arsenal-checkpoint-20260911 and independently verified with git ls-remote. 138 regular pistol portraits corrected, both SW/SE standing views reviewed; 139 native catalog entries pass 556 checks with zero failures. Checkpoint receipt saved in tools/pistol_portrait_20260914/checkpoint_receipt.json. No build/capture/repair process remains running. Owner visual review is next. Unrelated inherited work and parallel title/menu/sandbox journal entries remain in the working tree and were deliberately excluded from this scoped commit. Generated jobs/renders/candidates and one-off preparation scripts are local intermediate work; committed README/source/baseline reproduce the repair.\n'
p=R/'docs/DEAD_STREET_JOURNAL.md'
with p.open('a',encoding='utf-8') as f:f.write(entry)
def hive(s):
 a=s.index('**Checkpoint / publication:**');b=s.index('\n\n',a)
 return s[:a]+'**Checkpoint / publication:** PUSHED / VERIFIED: pistol art/source checkpoint '+head+' on origin/build/arsenal-checkpoint-20260911. Publication receipt and documentation follow-up accompany this checkpoint. See tools/pistol_portrait_20260914/checkpoint_receipt.json and journal pistol-portrait-04. Estate presentation remains version 6.'+s[b:]
p=R/'docs/DEAD_STREET_HIVE_MIND.md';p.write_text(hive(p.read_text(encoding='utf-8')),encoding='utf-8')
for path,text in [('docs/DEAD_STREET_JOURNAL.md',git('show','HEAD:docs/DEAD_STREET_JOURNAL.md').decode()+entry),('docs/DEAD_STREET_HIVE_MIND.md',hive(git('show','HEAD:docs/DEAD_STREET_HIVE_MIND.md').decode()))]:
 h=git('hash-object','-w','--stdin',input=text.encode()).decode().strip();git('update-index','--add','--cacheinfo','100644,'+h+','+path)
git('add','--','tools/pistol_portrait_20260914/checkpoint_receipt.json')
assert len(git('diff','--cached','--name-only').splitlines())==3
git('diff','--cached','--check');print(git('commit','-m','Record verified pistol portrait publication').decode().splitlines()[0],flush=True)
print(git('push','origin','HEAD:refs/heads/build/arsenal-checkpoint-20260911').decode(),flush=True)
final=git('rev-parse','HEAD').decode().strip();remote=git('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').decode().split()[0];assert final==remote
assert not git('diff','--cached','--name-only').strip()
print('FINAL_REMOTE_VERIFIED',final,'ART',head,'UNRELATED_WORKING_FILES',len(git('diff','--name-only').splitlines()),flush=True)
