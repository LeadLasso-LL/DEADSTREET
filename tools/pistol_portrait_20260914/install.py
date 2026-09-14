"""Install only reviewed, hash-verified portrait files; safe to repeat."""
from pathlib import Path
import hashlib,json,shutil,sys
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((O/'validation.json').read_text())
protected=json.loads((O/'protected_hashes.json').read_text())
if '--require-protected' in sys.argv:
 assert all(sha(R/p)==h for p,h in protected.items()),'Protected source changed; reconcile before installation'
for item in report['items']:
 candidate=O/'candidates'/(item['variant']+'.png');target=R/item['portrait']
 assert sha(candidate)==item['candidate_sha256'],item['variant']
 assert sha(target) in [item['before_sha256'],item['candidate_sha256']],item['variant']
for item in report['items']:shutil.copyfile(O/'candidates'/(item['variant']+'.png'),R/item['portrait'])
if '--require-protected' in sys.argv:assert all(sha(R/p)==h for p,h in protected.items())
print('INSTALLED',len(report['items']),'PROTECTED',len(protected),flush=True)
