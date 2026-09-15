from pathlib import Path
import subprocess,json
r=Path(__file__).resolve().parents[2]; out=Path(__file__).parent
message="\n\n## 20260915-selected-range-03 — Complete locally; publication blocked\n\nIMPLEMENTED / NATIVE-VALIDATED: selected-unit range feature, 234 native checks, final visual review, screenshot and all handoff records are complete. Automatic approval review rejected execution of tools/selected_range_20260915/publish.py before staging/commit/push. Stated reason: the GitHub destination was not established as a trusted organization-owned destination and earlier generic push approval did not explicitly authorize this particular private source/documentation transfer. Target is the established https://github.com/LeadLasso-LL/DEADSTREET.git, branch build/arsenal-checkpoint-20260911. Standing project authorization was read; it does not override the tool rejection. No bypass or retry performed.\n\nCurrent live-source sandbox loads the feature after reopening; user visual acceptance pending. Exact remaining publication action: obtain explicit owner approval to push this selected-unit firing-range code, native evidence and owned documentation to that destination. Then use the prepared scoped publisher after fresh source/branch/index checks; no native rerun needed unless validated source changed. It reconstructs only owned documentation changes in the index and preserves unrelated working text. Final native source hashes, source delta, README, 18 captures and publication_receipt.json are in tools/selected_range_20260915/. Parallel portrait/Arsenal/music work remains untouched.\n"
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
    p=r/'docs'/name; before=p.read_bytes(); text=before.decode('utf-8')
    if message.strip() not in text:
        assert p.read_bytes()==before,'Concurrent record change'
        p.write_text(text+message,encoding='utf-8',newline='\n')
    assert message.strip() in p.read_text(encoding='utf-8')
p=out/'README.md'; text=p.read_text(encoding='utf-8')
p.write_text(text+'\nPublication: BLOCKED by automatic approval review before staging/commit/push; explicit approval for the range-feature payload to the established GitHub origin is required. See journal selected-range-03.\n',encoding='utf-8')
def git(*args): return subprocess.check_output(['git','-C',str(r),*args],text=True).strip()
receipt={'status':'blocked_before_execution','reason':'Automatic approval review requires explicit permission for this private range-feature payload to the GitHub destination','destination':'https://github.com/LeadLasso-LL/DEADSTREET.git','branch':git('branch','--show-current'),'head':git('rev-parse','HEAD'),'index':git('diff','--cached','--name-only'),'feature':'implemented_native_validated','checks':234,'preview_library_file_id':'libfile_5a697f4ecb308191a828e57f40a34f36'}
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt)); print('Blocker, handoff and receipt saved and verified.')
