from pathlib import Path
import subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915'
for mode,script in [('review','review.gd'),('approach','approach_review.gd'),('integration','integration_review.gd')]:
 subprocess.run([sys.executable,str(o/'run_native.py'),mode,script],check=True)
print('ALL_REVISION_CHECKS_PASSED',flush=True)
