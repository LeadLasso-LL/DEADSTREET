from pathlib import Path
import subprocess,json,sys,datetime
sys.stdout.reconfigure(encoding='utf-8')
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); out=root/'tools/faction_audio_preview_20260914'
def git(*args): return subprocess.run(['git',*args],cwd=root,check=True,capture_output=True,text=True,encoding='utf-8').stdout.strip()
branch=git('branch','--show-current'); before=git('rev-parse','HEAD')
assert branch=='build/arsenal-checkpoint-20260911'
assert not git('diff','--cached','--name-only'), 'Index occupied: leave source pending rather than include others work'
files=['compose.py','package_review.py','fetch_instruments.py','README.md','manifest.json','review_index.json','validation.json','delivery_receipt.json','source_transfer_receipt.json','dependencies/GeneralUser_LICENSE.txt','review/LISTENING_GUIDE.md']
paths=['tools/faction_audio_preview_20260914/'+p for p in files]+['docs/FACTION_AUDIO_DIRECTION_2026-09-14.md']
git('add','--',*paths)
assert set(git('diff','--cached','--name-only').splitlines())==set(paths)
print(git('commit','-m','Add 18 faction audio audition scores and review handoff'),flush=True)
head=git('rev-parse','HEAD')
print(git('push','origin','HEAD:refs/heads/'+branch),flush=True)
remote=git('ls-remote','origin','refs/heads/'+branch).split()[0]
assert remote==head
receipt={'status':'SOURCE_ONLY_PUSHED_VERIFIED','head':head,'parent_at_start':before,'branch':branch,'remote':remote,'owned_paths':paths,'audio_status':'PREVIEWS_SAVED_OWNER_APPROVAL_PENDING','runtime_audio_changes':False}
(out/'checkpoint_receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
with (root/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f: f.write('\n\nAudio audition source checkpoint '+head+' pushed and remote-verified on '+branch+'. Twelve explicitly owned source/evidence/topic files committed. Shared hive/journal/control and other chats mixed work preserved uncommitted. Rendered previews remain saved for owner listening; no game audio installation. See tools/faction_audio_preview_20260914/checkpoint_receipt.json.\n')
print(json.dumps(receipt),flush=True)
