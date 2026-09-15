from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate'
subprocess.run([sys.executable,'-X','utf8','-u',str(out/'encode.py')],cwd=r,check=True,timeout=420)
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
subprocess.run([g,'--headless','--','--check=estate_geometry'],cwd=r,check=True,timeout=60)
print('DELIVERY_READY',flush=True)
