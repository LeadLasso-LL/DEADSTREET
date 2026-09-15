from pathlib import Path
import json,hashlib,subprocess,re
O=Path(__file__).resolve().parent;R=O.parents[1];plan=json.loads((O/'publication_plan.json').read_text())
def git(*a):return subprocess.check_output(['git',*a],cwd=R,text=True,encoding='utf-8').strip()
assert git('remote','get-url','origin')==plan['origin'] and git('branch','--show-current')==plan['branch']
assert not git('diff','--cached','--name-only')
editable={'tools/weapon_card_refresh_20260915/README.md','tools/weapon_card_refresh_20260915/owned_doc_deltas.json'}
mismatch=[p for p,h in plan['hashes'].items() if p not in editable and hashlib.sha256((R/p).read_bytes()).hexdigest()!=h]
assert not mismatch,mismatch
for p,h in json.loads((O/'protected_hashes.json').read_text()).items():assert hashlib.sha256((R/p).read_bytes()).hexdigest()==h,p
assert not json.loads((O/'native_validation.json').read_text())['failures']
entry='\n\n## 20260915-weapon-cards-06 - Owner explicitly approved artwork publication\n\nBrandon replied "Approved" to this chat\'s request to push the new shotgun/Mini-14/AUG trigger improvements and all 691 current-weapon card portraits to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the automatic-review publication block in weapon-cards-05. Existing 3,578 native checks and both-angle framing checks remain valid; all non-documentation owned file hashes and protected source hashes are unchanged. Proceed with the prepared scoped publisher on build/arsenal-checkpoint-20260911, preserving concurrent Harold cover/stair work and previously published comparison UI. Record remote verification; no repeated art generation or optional validation is needed.\n'
docs=['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md']
for p in docs:
 with (R/p).open('a',encoding='utf-8') as f:f.write(entry)
with (O/'README.md').open('a',encoding='utf-8') as f:f.write('\nOwner explicitly approved this artwork batch for GitHub publication in the following turn. The prior approval-review blocker is resolved; final publication_receipt.json records verified completion.\n')
deltas={}
for p in docs:
 base=git('show','HEAD:'+p);sections=[]
 for section in re.split(r'(?m)(?=^## )',(R/p).read_text(encoding='utf-8')):
  title=section.splitlines()[0] if section else ''
  if ('weapon-cards-' in title or 'radio-interior-05' in title) and title not in base:sections.append(section.strip())
 if sections:deltas[p]='\n\n'.join(sections)+'\n'
(O/'owned_doc_deltas.json').write_text(json.dumps(deltas,indent=2),encoding='utf-8')
plan.update(head=git('rev-parse','HEAD'),docs=list(deltas),hashes={p:hashlib.sha256((R/p).read_bytes()).hexdigest() for p in plan['owned']})
(O/'publication_plan.json').write_text(json.dumps(plan,indent=2),encoding='utf-8')
p=O/'publish_payload.json';data=json.loads(p.read_text());data['publish']=data['publish'].replace('weapon-cards-04 - Published','weapon-cards-07 - Published');p.write_text(json.dumps(data),encoding='utf-8')
print('APPROVED_PREFLIGHT',len(plan['owned']),'OWNED_FILES','HEAD',plan['head'],'UNCHANGED_VALIDATED_ASSETS',flush=True)
