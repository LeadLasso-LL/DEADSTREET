"""Publish only this pass's source, seven icons, applied menu delta and owned notes."""
from pathlib import Path
import subprocess,json,hashlib
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def g(*a,input=None):return subprocess.check_output(['git',*a],cwd=R,input=input)
def t(*a):return g(*a).decode().strip()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
plan=json.loads((O/'publication_plan.json').read_text());deltas=json.loads((O/'owned_doc_deltas.json').read_text())
assert not t('diff','--cached','--name-only'),'Other staged work; stop'
assert t('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert t('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert sha(R/'gameplay/sandbox_menu_music.gd')==plan['live_music_hash']
assert all(sha(R/p)==h for p,h in plan['hashes'].items())
head=t('rev-parse','HEAD');scope=plan['scope']+['tools/menu_polish_20260915/publication_plan.json','tools/menu_polish_20260915/publish.py']
g('add','--pathspec-from-file=-','--pathspec-file-nul',input=b'\0'.join(p.encode() for p in scope)+b'\0')
for rel,row in deltas.items():
 old=g('show','HEAD:'+rel).decode('utf-8-sig');block=row['block'];assert block.splitlines()[0] not in old
 new=block+'\n'+old if row['prepend'] else old.rstrip()+'\n\n\n'+block
 blob=g('hash-object','-w','--stdin',input=new.encode()).decode().strip();g('update-index','--add','--cacheinfo','100644',blob,rel)
staged=t('diff','--cached','--name-only').splitlines();assert set(staged)<=set(scope)|set(deltas)
assert t('rev-parse','HEAD')==head,'Concurrent commit; stop'
g('diff','--cached','--check');g('-c','gc.auto=0','commit','-m','Polish sandbox emblems, precision guns and shuffle controls')
commit=t('rev-parse','HEAD')
receipt={'state':'committed locally; push pending','commit':commit,'parent':head,'native_checks':249,'scope_files':len(staged),'music_source':'live original opening source preserved; exact applied delta checkpointed','destination':t('remote','get-url','origin')}
(O/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
g('push','origin','HEAD:refs/heads/build/arsenal-checkpoint-20260911')
remote=t('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').split()[0];assert remote==commit
receipt.update(state='pushed and remote verified',remote=remote);(O/'publication_receipt.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt),flush=True)
