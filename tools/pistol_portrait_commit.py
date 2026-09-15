from pathlib import Path
import subprocess,json
R=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');O=R/'tools/pistol_portrait_20260914'
def git(*a):return subprocess.check_output(['git',*a],cwd=R,stderr=subprocess.STDOUT,text=True,encoding='utf-8')
assert git('branch','--show-current').strip()=='build/arsenal-checkpoint-20260911'
assert git('remote','get-url','origin').strip()=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert len(git('diff','--cached','--name-only').splitlines())==162
git('diff','--cached','--check')
output=git('commit','-m','Fix pistol card forearms and shoulder joins across faction roster')
head=git('rev-parse','HEAD').strip()
print(output.splitlines()[0],flush=True)
print(git('push','origin','HEAD:refs/heads/build/arsenal-checkpoint-20260911'),flush=True)
remote=git('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').split()[0]
assert remote==head,(remote,head)
(O/'checkpoint_receipt.json').write_text(json.dumps({'art_commit':head,'verified_remote_art_commit':remote,'branch':'build/arsenal-checkpoint-20260911','portraits_fixed':138,'native_checks':556,'native_failures':0,'protected_files':415},indent=2)+'\n')
print('PUSH_VERIFIED',head,flush=True)
