from pathlib import Path
import subprocess,sys,json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/raiders_recording';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
for name,args,limit in [('raiders_probe',['--headless'],90),('convoy_native',['--resolution','1920x1080','--fixed-fps','30','--disable-vsync'],90)]:
 with (o/(name+'_revised.log')).open('wb')as f:
  p=subprocess.run([str(base/'godot.exe'),*args,'--','--check='+name],cwd=r,stdout=f,stderr=subprocess.STDOUT,timeout=limit)
 s=(o/(name+'_revised.log')).read_text(encoding='utf-8',errors='replace');print(name,p.returncode,s[-5000:],flush=True)
 assert p.returncode==0 and 'SCRIPT ERROR'not in s and '\nERROR:'not in s
print('REVISED_CHECKS_COMPLETE',flush=True)
