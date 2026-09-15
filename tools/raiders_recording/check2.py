from pathlib import Path
import subprocess,sys,urllib.request,concurrent.futures,json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/raiders_recording';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
p=r/'tools/tactical_controls/raiders_director.gd';s=p.read_text();assert 'row.tier=3 if side=="attacker" else 2;'in s;s=s.replace('row.tier=3 if side=="attacker" else 2;','row.tier=3 if side=="attacker" else 1;').replace('if held and not released and t>24.0:','if held and t>24.0:');p.write_bytes(s.encode())
def download(i):
 u=f'https://cdn.freesound.org/previews/{i//1000}/{i}_4162634-hq.mp3'
 try:
  data=urllib.request.urlopen(u,timeout=15).read();(o/f'music_{i}.mp3').write_bytes(data);print('MUSIC_DOWNLOADED',i,len(data),flush=True)
 except Exception as e:print('MUSIC_ERROR',i,repr(e),flush=True)
with concurrent.futures.ThreadPoolExecutor()as ex:
 jobs=[ex.submit(download,i)for i in [367876,340087]]
 subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
 with(o/'probe_revised_2.log').open('wb')as f:subprocess.run([str(base/'godot.exe'),'--headless','--','--check=raiders_probe'],cwd=r,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=90)
 print('PROBE_FINAL', (o/'probe.json').read_text(),flush=True)
 for j in jobs:j.result()
print('SECOND_CHECK_COMPLETE',flush=True)
