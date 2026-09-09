extends SceneTree
func _initialize(): call_deferred("check")
func check():
	var c=load("res://core/core_validation.gd")
	var service=load("res://battle/combat/battle_combat_behavior_service.gd")
	var cover=load("res://battle/geometry/battle_cover_service.gd")
	var pack=c._battledefend_engaged("side_src","side_tgt",Vector2(10,10),Vector2(20,10))
	var battle=pack.battle_state
	var unit=pack.source
	c._battlewounded_slot(battle.battlefield_geometry,"bad_obj","bad_slot",Vector2(10,10),Vector2.LEFT)
	c._battlewounded_slot(battle.battlefield_geometry,"good_obj","good_slot",Vector2(10,13),Vector2.RIGHT)
	var occupancy=cover.occupy_slot(battle,unit.participant_id,"bad_slot")
	if not occupancy.success: push_error("Fixture occupancy failed");quit(2);return
	var counts={"defend":0,"nav":0}
	var action=service._update_defend_position_behavior(battle,unit,counts)
	var ok=action=="reposition" and unit.reserved_cover_slot_id=="good_slot"
	print("DEFENDER_WRONG_SIDE ",JSON.stringify({"pass":ok,"action":action,"reserved":unit.reserved_cover_slot_id}))
	quit(0 if ok else 1)
