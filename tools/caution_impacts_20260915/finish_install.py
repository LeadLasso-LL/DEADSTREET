from pathlib import Path
import subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/caution_impacts_20260915';p=o/'prepare.py'
s=p.read_text();old='[3:v]trim=duration=8,setpts=PTS-STARTPTS,fps=30,setsar=1,format=yuv420p[v3]';new='[3:v]setpts=PTS-STARTPTS,fps=30,tpad=stop_mode=clone:stop_duration=0.1,trim=duration=8,setsar=1,format=yuv420p[v3]'
assert s.count(old)==1;s=s.replace(old,new);p.write_text(s,encoding='utf-8',newline='\n')
(o/'prepare_first_attempt.log').write_bytes((o/'prepare_worker.log').read_bytes())
py=r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe'
with (o/'prepare_worker.log').open('wb') as log: subprocess.run([py,str(p)],cwd=r,stdout=log,stderr=subprocess.STDOUT,check=True)
with (o/'capture_worker.log').open('wb') as log:
 worker=subprocess.Popen([py,str(o/'capture.py')],cwd=r,stdout=log,stderr=subprocess.STDOUT)
 print('CAPTURE_WORKER_PID',worker.pid)