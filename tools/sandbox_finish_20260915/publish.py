"""Scoped portrait/Arsenal checkpoint to the established DEADSTREET origin.

Run only with applicable owner authorization. Never stages music/BUILD/opening.
"""
from pathlib import Path
import subprocess,json,hashlib,os,datetime
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def run(*args,input=None):
 p=subprocess.run(['git',*args],cwd=R,input=input,capture_output=True)
 if p.returncode:raise RuntimeError(p.stderr.decode(errors='replace'))
 return p.stdout
def text(*a):return run(*a).decode().strip()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
plan=json.loads((O/'publication_plan.json').read_text())
native=json.loads((O/'smoke.json').read_text())
assert native['checks']==6178 and not native['errors']
assert text('branch','--show-current')=='build/arsenal-checkpoint-20260911'
assert text('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert not text('diff','--cached','--name-only'),'Another task has staged changes; stop.'
assert all(sha(R/p)==v for p,v in plan['hashes'].items()),'Validated source/evidence changed'
start=text('rev-parse','HEAD')
for rel in plan['baseline_differs_from_head']:
 head=run('show','HEAD:'+rel).decode('utf-8-sig').replace('\r\n','\n')
 before=(O/'before'/rel).read_text(encoding='utf-8-sig')
 assert head==before,('Unexpected inherited source edit',rel)
scope=plan['scope']+['tools/sandbox_finish_20260915/publication_plan.json','tools/sandbox_finish_20260915/publish.py']
raw=b'\0'.join(p.encode() for p in scope)+b'\0'
ignored=subprocess.run(['git','check-ignore','--stdin','-z'],cwd=R,input=raw,capture_output=True)
assert ignored.returncode in [0,1]
omitted=set(ignored.stdout.decode().strip('\0').split('\0')) if ignored.stdout else set()
scope=[p for p in scope if p not in omitted]
raw=b'\0'.join(p.encode() for p in scope)+b'\0'
run('add','--pathspec-from-file=-','--pathspec-file-nul',input=raw)
deltas=json.loads((O/'owned_doc_deltas.json').read_text())
for rel,row in deltas.items():
 head=run('show','HEAD:'+rel).decode('utf-8-sig');block=row['block']
 assert block.splitlines()[0] not in head,('Already published',rel)
 new=block+'\n'+head if row['prepend'] else head.rstrip()+'\n\n\n'+block
 blob=run('hash-object','-w','--stdin',input=new.encode()).decode().strip()
 run('update-index','--add','--cacheinfo','100644',blob,rel)
staged=text('diff','--cached','--name-only').splitlines()
assert set(staged)<=set(scope)|set(deltas),'Unrelated staged changes; stop.'
assert text('rev-parse','HEAD')==start,'Concurrent commit; stop before commit.'
run('diff','--cached','--check')
run('commit','-m','Finish faction portraits and balance sandbox firearm catalog')
commit=text('rev-parse','HEAD')
receipt={'state':'committed locally; push pending','commit':commit,'parent':start,'scope_files':len(staged),'native_checks':6178,'owner_art_acceptance':'pending','destination':text('remote','get-url','origin'),'branch':text('branch','--show-current')}
(O/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
run('push','origin','HEAD:refs/heads/build/arsenal-checkpoint-20260911')
remote=text('ls-remote','origin','refs/heads/build/arsenal-checkpoint-20260911').split()[0]
assert remote==commit,(remote,commit)
receipt.update(state='pushed and remote verified',remote=remote,utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
(O/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt),flush=True)
