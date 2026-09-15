from pathlib import Path
import subprocess
root=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
entry='\n\n## 20260915-soundtrack-extra-03 - Complete locally; three-track publication blocked\n\nAll three full songs and exact loops are implemented and validated locally: 22 menu songs, 21 loops, 25 native checks and four integrity checks passed. Automatic approval review rejected tools/soundtrack_extra_20260915/publish.py because the visible preceding publication approval covered the earlier 17-track batch, not this later three-track private audio/code payload to GitHub. No bypass/retry performed. Target: https://github.com/LeadLasso-LL/DEADSTREET.git on build/arsenal-checkpoint-20260911. Unaffected processing, catalogue integration, evidence, README and shared records are complete.\n\nRemaining action: request explicit owner approval to publish Glock, Keys and Ripper (six new audio assets, catalogue, batch source/evidence and owned records) to the established repository. After approval run the prepared publish.py, which checks current branch/origin/index, source/asset hashes and validation, stages only owned changes, commits/pushes and verifies remote hash. No retrieval or processing rerun needed unless protected hashes changed. Faction associations remain pending. Live-source sandbox already reads the local 22-track catalogue.\n'
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:
    p=root/'docs'/name
    if '## 20260915-soundtrack-extra-03' not in p.read_text(encoding='utf-8'):
        with p.open('a',encoding='utf-8') as f:f.write(entry)
    assert entry in p.read_text(encoding='utf-8')
print('PUBLICATION_BLOCK_RECORDED',flush=True)
print('HEAD',subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip())
print('STAGED',subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).strip() or '(empty)')
