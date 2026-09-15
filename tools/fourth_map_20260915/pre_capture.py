from pathlib import Path
import subprocess,sys
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street")
o=r/'tools/fourth_map_20260915'
subprocess.run([sys.executable,str(o/'install_checks.py')],check=True)
for mode,script in [('bake','review.gd'),('integration','integration_review.gd')]:
 subprocess.run([sys.executable,str(o/'run_native.py'),mode,script],check=True)
print('Pre-capture checks finished')
