from pathlib import Path
import json,zlib,base64
r=Path(__file__).resolve().parents[2]
files=["battle/runtime/battle_runtime_service.gd","battle/core/battle_force_command_service.gd","battle/core/battle_force_command_catalog.gd","battle/core/battle_state.gd","battle/combat/battle_combat_behavior_service.gd","battle/core/battle_tactical_force.gd","battle/combat/battle_combat_pressure_service.gd","battle/combat/battle_weapon_catalog.gd","battle/combat/battle_weapon_definition.gd","battle/combat/battle_weapon_state.gd","battle/core/battle_participant.gd","battle/combat/battle_combat_pressure_snapshot.gd","gameplay/tactical_unit_hud_query.gd","gameplay/tactical_command_hud.gd","tools/battle_showcase/scenario.gd","tools/battle_showcase/review.gd"]
data={f:(r/f).read_text(encoding='utf-8-sig') for f in files}
p=Path(__file__).parent/'source_strength.txt'
p.write_text(base64.b64encode(zlib.compress(json.dumps(data).encode())).decode(),encoding='ascii')
print(p.stat().st_size)
