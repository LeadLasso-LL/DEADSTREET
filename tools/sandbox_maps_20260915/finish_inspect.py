from pathlib import Path
import hashlib,json,subprocess,datetime
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
b=json.loads((out/'baseline.json').read_text());owned=json.loads((out/'installed.json').read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
changed={p:sha(r/p) for p,h in b['hashes'].items() if not (r/p).exists() or sha(r/p)!=h}
protected={p:h for p,h in changed.items() if p not in owned}
owned_drift={p:sha(r/p) for p,h in owned.items() if sha(r/p)!=h}
git=lambda *args:subprocess.check_output(['git','-C',str(r),*args],text=True).strip()
result={'timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':git('rev-parse','HEAD'),'branch':git('branch','--show-current'),'index':git('diff','--cached','--name-only'),'baseline_count':len(b['hashes']),'protected_unchanged_count':len([p for p in b['hashes'] if p not in owned and p not in protected]),'concurrent_protected_changes':protected,'concurrent_owned_merges':owned_drift,'current_owned_hashes':{p:sha(r/p) for p in owned},'status':git('status','--short'),'checks':json.loads((out/'check.json').read_text()),'groups':json.loads((out/'groups.json').read_text()),'clicks':json.loads((out/'clicks.json').read_text())}
(out/'completion_receipt.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in result.items() if k not in ['current_owned_hashes','status','checks','groups']},indent=2))
