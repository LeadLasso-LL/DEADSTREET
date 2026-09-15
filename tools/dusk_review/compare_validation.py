from pathlib import Path
import json
def result(p):
 for line in Path(p).read_text(errors='replace').splitlines():
  if line.startswith('QUEUE_VALIDATION '):return json.loads(line.split(' ',1)[1])
a=result(r'C:\Users\brand\AppData\Local\Temp\ds-baseline-validation.log')
b=result(Path(__file__).parent/'results/queue_validation_refined.log')
assert a and b,'validation still running'
new=sorted(set(b['failed'])-set(a['failed']));resolved=sorted(set(a['failed'])-set(b['failed']))
out={'checks':b['count'],'baseline_failed':len(a['failed']),'current_failed':len(b['failed']),'new_failures':new,'resolved':resolved}
(Path(__file__).parent/'results/queue_validation_comparison.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out))
