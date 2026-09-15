from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate'
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
def run(cmd,label,timeout=100):
 p=subprocess.run(cmd,cwd=r,capture_output=True,timeout=timeout)
 log=(p.stdout+p.stderr).decode('utf-8',errors='replace');(out/(label+'.log')).write_text(log,encoding='utf-8');print(label,p.returncode,log[-6500:],flush=True)
 if p.returncode or 'SCRIPT ERROR' in log or 'ESTATE_FAIL' in log:raise SystemExit(1)
run([sys.executable,str(out/'build_audio.py'),str(r/'assets/audio/convoy')],'audio_revision')
run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'revision_pack1')
for mode in ['estate_bake','estate_bake_props']:
 run([g,'--','--check='+mode],mode)
run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'revision_pack2')
run([g,'--headless','--','--check=estate_geometry'],'revision_geometry')
run([g,'--','--check=estate_preview'],'revision_preview')
run([g,'--headless','--','--check=estate_probe'],'revision_probe',220)
run([g,'--disable-vsync','--max-fps','0','--','--check=estate_native'],'revision_native',90)
print('VISUAL_REVISION_READY',flush=True)
