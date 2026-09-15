from pathlib import Path
R=Path(__file__).resolve().parents[2]
p=R/'battle/combat/battle_defend_position_service.gd';s=p.read_text().replace(' < current_range - 0.75', ' <= weapon.max_range');p.write_text(s)
p=R/'battle/combat/battle_combat_behavior_service.gd';s=p.read_text()
start=s.index('static func _update_defend_position_behavior(')
idx=s.index('\tvar sample: Vector2 =',start)
s=s[:idx]+'''\t# Range alone never sends a defender out into the open.
\t# If no protected local firing slot exists, preserve the defensive position.
\tif target != null:
\t\tvar eligibility = BattleFireControlService.evaluate_participant_target_eligibility(battle_state, participant.participant_id, target.participant_id)
\t\tif eligibility != null and eligibility.rejection_code == "out_of_range":
\t\t\t_clear_owned_combat_navigation(participant)
\t\t\treturn DEFEND_HOLD
'''+s[idx:]
p.write_text(s)
