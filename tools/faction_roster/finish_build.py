"""Wait for published variants, then run final asset/catalog gates."""
from pathlib import Path
import json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'assets/art/units/factions'
GODOT=ROOT.parent/'Godot/Godot_v4.7.2-stable_win64_console.exe'
def run():
    start=time.monotonic()
    while len(list((DEST/'validation').glob('*.json')))<636:
        if time.monotonic()-start>4*3600:raise RuntimeError('Animation build did not finish within the diagnostic observation window')
        time.sleep(10)
    for script in ['write_manifest.py','validate_assets.py']:
        subprocess.run([sys.executable,str(Path(__file__).parent/script)],check=True)
    for script in ['validate_rules.gd','validate_pack.gd']:
        subprocess.run([str(GODOT),'--headless','--path',str(ROOT),'--script','res://tools/faction_roster/'+script],check=True)
    subprocess.run([sys.executable,str(Path(__file__).parent/'render_review.py')],check=True)
    print('ROSTER_RELEASE_GATES_COMPLETE',flush=True)
if __name__=='__main__':run()
