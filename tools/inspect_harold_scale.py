from pathlib import Path
import re,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(__file__).resolve().parents[1]
for name,pattern in [('gameplay/tactical_deployment_controller.gd',r'func choose_arrival|func _ensure_attacker_vehicles|ARRIVAL|Vector2\(.+,28'),('gameplay/arsenal_review.gd',r'func _process'),('gameplay/harold_street_art.gd',r'func _draw'),('gameplay/tactical_battle_presentation.gd',r'28|harold|arrival_center')]:
 p=r/name
 if not p.exists():continue
 lines=p.read_text(encoding='utf-8-sig').splitlines()
 for i,s in enumerate(lines):
  if re.search(pattern,s):
   print(name,i+1)
   print('\n'.join(f'{j+1}: {lines[j]}' for j in range(max(0,i-2),min(i+45,len(lines)))))
print('ARRIVAL FILES',*[str(p.relative_to(r)) for p in (r/'gameplay').glob('*arrival*')])
