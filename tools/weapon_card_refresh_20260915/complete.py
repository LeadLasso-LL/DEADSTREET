from pathlib import Path
import subprocess,sys
O=Path(__file__).resolve().parent
for name in ['join_guards.py','run_install.py']:
 print('RUNNING',name,flush=True)
 subprocess.run([sys.executable,str(O/name)],check=True)
