from pathlib import Path
import re
r=Path(__file__).resolve().parents[2]
for name in ['battle/core/battle_state.gd','battle/core/battle_side.gd','gameplay/arsenal_battle_fixture.gd']:
 lines=(r/name).read_text(encoding='utf-8-sig').splitlines()
 for i,s in enumerate(lines):
  if re.search(r'func .*commit|deployment_committed|func begin_review',s):
   print(name,'\n'+'\n'.join(f'{j+1}: {lines[j]}' for j in range(max(0,i-1),min(len(lines),i+15))))
