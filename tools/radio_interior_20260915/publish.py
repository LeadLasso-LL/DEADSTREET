from pathlib import Path
import json,hashlib,subprocess
out=Path(__file__).resolve().parent;root=out.parents[1]
plan=json.loads((out/'publication_plan.json').read_text());deltas=json.loads((out/'owned_doc_deltas.json').read_text(encoding='utf-8'))
def run(*args,input=None):return subprocess.check_output(['git',*args],cwd=root,input=input)
def git(*args):return run(*args).decode('utf-8').strip()
assert git('remote','get-url','origin')==plan['origin']
assert git('branch','--show-current')==plan['branch']
assert git('rev-parse','HEAD')==plan['head']
assert not git('diff','--cached','--name-only')
for p,sha in plan['hashes'].items():assert hashlib.sha256((root/p).read_bytes()).hexdigest()==sha,p
for p,sha in json.loads((out/'protected_hashes.json').read_text()).items():assert hashlib.sha256((root/p).read_bytes()).hexdigest()==sha,p
assert json.loads((out/'native_validation.json').read_text())['failures']==[]
assert json.loads((out/'measured_response.json').read_text())['failures']==[]
run('add','--',*plan['owned'])
for p,addition in deltas.items():
 base=run('show','HEAD:'+p).decode('utf-8')
 merged=base.rstrip()+'\n\n'+addition
 blob=run('hash-object','-w','--stdin',input=merged.encode('utf-8')).decode().strip()
 run('update-index','--add','--cacheinfo','100644',blob,p)
expected=set(plan['owned'])|set(deltas)
actual=set(git('diff','--cached','--name-only').splitlines());assert actual==expected,(len(actual),len(expected))
assert git('rev-parse','HEAD')==plan['head']
run('diff','--cached','--check')
print(run('commit','-m','Add restrained vehicle and building filtering for faction radios').decode('utf-8'),flush=True)
head=git('rev-parse','HEAD')
print(run('push','origin','HEAD:refs/heads/'+plan['branch']).decode('utf-8'),flush=True)
remote=git('ls-remote','origin','refs/heads/'+plan['branch']).split()[0];assert remote==head
receipt={'status':'pushed_and_verified','commit':head,'origin':plan['origin'],'branch':plan['branch'],'native_checks':141,'signal_and_protected_checks':8}
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
entry='\n\n## 20260915-radio-interior-05 - Published and verified\n\nScoped interior-radio filtering checkpoint pushed and remote branch verified at '+head+'. Final restrained FILTER_6DB configuration, vehicle/building placement and gain preservation, smooth winner clarity, unchanged menu/sirens, and 149 passing native/measured checks are recorded in tools/radio_interior_20260915/. All pre-existing unstaged work preserved; only owned record sections checkpointed. Reopen normal Sandbox launcher for owner listening review. No remaining implementation task in this scope.\n'
for p in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
 with (root/p).open('a',encoding='utf-8') as f:f.write(entry)
print(json.dumps(receipt),flush=True)
