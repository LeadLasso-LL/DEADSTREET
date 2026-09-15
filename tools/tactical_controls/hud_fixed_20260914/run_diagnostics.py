from pathlib import Path
import subprocess,json,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');d=r/'tools/tactical_controls/hud_fixed_20260914';godot=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
for row in json.loads((d/'checks_payload.json').read_text()):(r/row['path']).write_bytes(row['updated'].encode())
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True)
for name,headless in [('estate_assault_checks',True),('hud_layout_review',False)]:
 p=subprocess.run([godot]+(['--headless'] if headless else [])+['--','--check='+name],cwd=r,capture_output=True,timeout=120);t=(p.stdout+p.stderr).decode('utf-8',errors='replace');(d/(name+'.log')).write_text(t);print(name,'EXIT',p.returncode,flush=True)
 for line in t.splitlines():
  if any(x in line for x in ['SCRIPT ERROR','ASSAULT_FAIL','HUD_FIELDS']):print(line,flush=True)
print('DIAGNOSTICS_COMPLETE',flush=True)
