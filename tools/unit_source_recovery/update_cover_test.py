from pathlib import Path
p=Path(__file__).resolve().parents[2]/'core/core_validation.gd';s=p.read_text();a=s.index('static func _defender_ai_cover_ok()');b=s.index('static func _defender_ai_los_ok()',a);part=s[a:b]
part=part.replace('and defender.occupied_cover_slot_id.is_empty()', 'and defender.occupied_cover_slot_id == "dai_cover_slot"').replace('and live_slot.is_available()', 'and live_slot.occupied_by_participant_id == defender.participant_id\n\t\tand BattleCoverService.occupancy_is_valid(with_cover, defender)')
s=s[:a]+part+s[b:];p.write_text(s)
