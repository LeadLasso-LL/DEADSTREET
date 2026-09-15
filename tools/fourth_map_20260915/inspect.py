from pathlib import Path
import subprocess,sys,json
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
for a in [['rev-parse','--abbrev-ref','HEAD'],['rev-parse','HEAD'],['status','--short'],['diff','--cached','--stat']]:
 print('GIT',a,subprocess.check_output(['git','-C',str(r)]+a,text=True,encoding='utf-8'))
for base in ['battle/geometry','tools/whittaker_estate','tools/bridge_map','docs','assets/data']:
 print('FILES',base,[str(p.relative_to(r)) for p in (r/base).glob('*') if p.is_file()])
for name in ['docs/DEAD_STREET_PROJECT_CONTROL.md','docs/DEAD_STREET_JOURNAL.md']:
 s=(r/name).read_text(encoding='utf-8');print(name,'TAIL',s[-6500:])
