from pathlib import Path
import subprocess,sys,json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/whittaker_estate/resume_20260914';g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
for mode in ['line_checks','line_native']:
 cmd=[g]+(['--headless'] if mode=='line_checks' else [])+['--','--check='+mode]
 p=subprocess.run(cmd,cwd=r,capture_output=True,timeout=120);text=(p.stdout+p.stderr).decode('utf-8',errors='replace');(out/(mode+'.log')).write_text(text,encoding='utf-8');print(mode,p.returncode,text[-2500:],flush=True)
 assert p.returncode==0 and 'SCRIPT ERROR' not in text
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write('\n\n### 20260914-active-resume-03 validation correction\nThe first pre-capture runner selected historical checks.gd and failed its obsolete fixed-position Push badge assertion (62/63 passed). The current controls README explicitly supersedes that fixture with line_checks/line_native. No gameplay change made to satisfy the obsolete expectation. Current line suites were run before capture; exact results are in resume_20260914/line_checks.log and line_native.log.\n')
old=r/'tools/whittaker_estate/estate_raw.avi'
if old.exists():
 target=out/'inherited_estate_raw.avi';assert not target.exists();old.rename(target)
print('CAPTURE_START',flush=True)
p=subprocess.run([sys.executable,str(r/'tools/whittaker_estate/record_worker.py')],cwd=r,timeout=800)
print('FINAL_WORKER_EXIT',p.returncode,flush=True);sys.exit(p.returncode)
