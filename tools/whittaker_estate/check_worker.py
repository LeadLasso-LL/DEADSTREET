from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parents[2]
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
p=subprocess.run([g,'--headless','--','--check=estate_probe'],cwd=r,capture_output=True,timeout=180)
log=(p.stdout+p.stderr).decode('utf-8',errors='replace');(r/'tools/whittaker_estate/probe.log').write_text(log,encoding='utf-8');print(log,flush=True)
