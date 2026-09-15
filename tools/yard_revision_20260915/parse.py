from pathlib import Path
import subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
p=subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--headless','--path',str(r),'--check-only','--script','res://gameplay/doble_ocho_art.gd'],capture_output=True,timeout=30)
print(p.stdout.decode(errors='replace'));print(p.stderr.decode(errors='replace'));print('EXIT',p.returncode)
