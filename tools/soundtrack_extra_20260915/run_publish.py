from pathlib import Path
import runpy
out=Path(__file__).resolve().parent;root=out.parents[1]
entry='\n\n## 20260915-soundtrack-extra-04 - Owner explicitly approved three-track publication\n\nBrandon replied "approved" to the explicit request to publish Glock, Keys and Ripper to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the automatic-review publication block in soundtrack-extra-03. Authorized scope: six new audio assets, shared catalogue, this batch source/evidence and owned records on build/arsenal-checkpoint-20260911. Proceed with the prepared publisher and fresh branch/index/source/asset checks; preserve concurrent work. All processing and 25 native checks already passed; do not rerun absent a changed protected source. Verify remote hash and record final receipt.\n'
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:
    path=root/'docs'/name
    if '## 20260915-soundtrack-extra-04' not in path.read_text(encoding='utf-8'):
        with path.open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in path.read_text(encoding='utf-8')
print('EXPLICIT_PUBLICATION_APPROVAL_RECORDED',flush=True)
runpy.run_path(str(out/'publish.py'),run_name='__main__')
