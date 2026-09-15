from pathlib import Path
import re,sys
sys.stdout.reconfigure(encoding='utf-8')
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
for name,pat in [('gameplay/tactical_battle_view.gd',r'^func (_ensure_layers|_draw|_to_view|_process)|z_index|draw_.*layer'),('gameplay/tactical_orders_controller.gd',r'^func|selected_participant|can_select'),('battle/core/battle_participant.gd',r'attack_profile|range|is_alive|can_fight|position'),('battle/combat/battle_attack_profile.gd',r'^var|range'),('gameplay/tactical_battle_presentation.gd',r'^func|phase|selected|arrival|ready'),('gameplay/tactical_environment_presenter.gd',r'root|z_index')]:
    p=r/name; print('\n'+name)
    lines=p.read_text(encoding='utf-8').splitlines()
    for i,l in enumerate(lines):
        if re.search(pat,l):print(str(i+1)+': '+l)
