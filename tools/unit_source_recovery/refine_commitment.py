from pathlib import Path
p=Path(__file__).resolve().parents[2]/'battle/combat/battle_combat_behavior_service.gd';s=p.read_text()
s=s.replace('if participant.combat_move_mode in [MOVE_CLOSE, MOVE_SEEK_ROLE_COVER] and target != null:', 'if participant.combat_move_mode == MOVE_CLOSE and target != null:')
s=s.replace('if same_command and committed_slot != null and _cheap_closing_slot_still_valid', 'if same_command and _combat_decision_matches(battle_state, participant, target.participant_id) and committed_slot != null and _cheap_closing_slot_still_valid')
p.write_text(s)
