from pathlib import Path
import subprocess,sys,json,tempfile,os,hashlib
sys.stdout.reconfigure(encoding='utf-8');r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/raiders_recording'
def git(*a,env=None):
 p=subprocess.run(['git',*a],cwd=r,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90);assert p.returncode==0,(a,p.stdout,p.stderr);return p.stdout.strip()
assert git('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
m=json.loads((out/'mobile.json').read_text());assert hashlib.sha256((out/m['filename']).read_bytes()).hexdigest()==m['sha256']
p=out/'README.md';s=p.read_text(encoding='utf-8');s+='\nPhone sharing: `python tools/raiders_recording/mobile_export.py` creates the 1280×720\nH.264 copy with the verified AAC audio unchanged. `mobile.json` records its exact\nsize/hash and the full-HD master hash. The September 14 recording is 112.64 seconds;\nthe mobile copy is 15.52 MiB. Full-HD master retained on the build machine.\n';p.write_bytes(s.encode())
p=out/'.gitignore';s=p.read_text(encoding='utf-8');s+='transfer_mobile/\n';p.write_bytes(s.encode())
p=r/'docs/DEAD_STREET_JOURNAL.md'
with p.open('a',encoding='utf-8') as f:f.write('\n\n## 2026-09-14 — Compact mobile battle export (VALIDATED)\n\nThe full-HD master is 74.43 MiB, so a separate 1280x720 H.264 copy was made for phone sharing, preserving the complete 112.64-second recording and its AAC audio. Mobile export decoding passed; file size is 16,269,495 bytes (15.52 MiB); SHA256 `'+m['sha256']+'`. The full-HD master is retained. Convoy/arrival/audio implementation and records were committed and pushed as `7638a0915f0e1b3f1542d716e9401f6ce0f25937`. Mobile export source/metadata are a separate scoped checkpoint. The next owner task is to review the delivered battle, particularly the arrival, audio and command feel.\n')
paths=['tools/raiders_recording/mobile_export.py','tools/raiders_recording/mobile.json','tools/raiders_recording/README.md','tools/raiders_recording/.gitignore','docs/DEAD_STREET_JOURNAL.md']
index=Path(tempfile.gettempdir())/'dead_street_mobile_export_index';index.unlink(missing_ok=True);env=os.environ.copy();env['GIT_INDEX_FILE']=str(index)
git('read-tree','HEAD',env=env);git('add','--',*paths,env=env);git('diff','--cached','--check',env=env);git('commit','-m','Add compact mobile export of Raiders bridge battle',env=env);git('reset','-q','HEAD','--',*paths)
head=git('rev-parse','HEAD');print('COMMITTED',head,flush=True);git('push','origin','build/arsenal-checkpoint-20260911');remote=git('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').split()[0];assert remote==head
(out/'mobile_commit_receipt.json').write_text(json.dumps({'head':head,'remote':remote,'mobile_sha256':m['sha256']}));print('PUSH_VERIFIED',head,flush=True)
