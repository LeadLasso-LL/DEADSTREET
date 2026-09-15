from pathlib import Path
import subprocess, difflib, shutil
root = Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
def git(*args, **kwargs): return subprocess.run(['git', *args], cwd=root, check=True, **kwargs)
assert not git('diff', '--cached', '--name-only', capture_output=True).stdout.strip(), 'Index has unrelated changes'
rel = 'docs/DEAD_STREET_PROJECT_CONTROL.md'
base = git('show', 'HEAD:' + rel, capture_output=True).stdout.decode('utf-8')
current = (root / rel).read_text(encoding='utf-8')
header = '# Dead Street — Project Control\n\n'
notice = "> **2026-09-10 approved map baseline — latest:** Brandon visually accepted the complete Harold Ave. street pass and final arrival-car correction through `139d10c`, and directed that it become the reusable standard for future maps. The accepted drawn/pixel-art map and units supersede the older DAZ/source-style gates below as the active visual baseline. Read [MAP_BUILDING_STANDARD.md](MAP_BUILDING_STANDARD.md) for consolidated art/cover rules, workflow and versioned reference captures, and [HAROLD_AVE_IMPLEMENTATION.md](HAROLD_AVE_IMPLEMENTATION.md) for technical evidence. The street is visually accepted; deployment/arrival/HUD and broader combat work retain their separate status. Await Brandon's next requested scope. Earlier tracker entries are historical and do not revoke this acceptance.\n\n"
assert base.startswith(header) and current.startswith(header)
new_base = header + notice + base[len(header):]
patch = ''.join(difflib.unified_diff(base.splitlines(True), new_base.splitlines(True), fromfile='a/' + rel, tofile='b/' + rel)).encode('utf-8')
git('apply', '--cached', '--check', '-', input=patch)
(root / rel).write_text(header + notice + current[len(header):], encoding='utf-8', newline='\n')
git('apply', '--cached', '-', input=patch)
dest = root / 'docs/references/harold_approved'
dest.mkdir(parents=True, exist_ok=True)
names = ['battle_02.png','frontage_detail.png','alley_detail.png','north_bins_detail.png','south_bins_detail.png','arrival_car_detail.png']
for name in names: shutil.copy2(root / 'tools/dusk_review/frontage_results' / name, dest / name)
print('Added current acceptance without staging prior tracker edits; saved six visual references.')
