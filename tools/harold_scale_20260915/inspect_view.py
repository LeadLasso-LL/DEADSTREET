from pathlib import Path
r=Path(__file__).resolve().parents[2]
p=r/'gameplay/tactical_battle_view.gd'; lines=p.read_text(encoding='utf-8-sig').splitlines()
for i,s in enumerate(lines):
 if s.startswith('func _frame_camera') or s.startswith('func _dusk_camera') or s.startswith('func _dusk_bounds'):
  print('\n'.join(f'{j+1}: {lines[j]}' for j in range(i,min(len(lines),i+100))))
