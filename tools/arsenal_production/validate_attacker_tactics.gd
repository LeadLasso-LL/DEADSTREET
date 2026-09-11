extends SceneTree
const State = preload("res://battle/core/battle_state.gd")
const Side = preload("res://battle/core/battle_side.gd")
const Unit = preload("res://battle/core/battle_participant.gd")
const Geometry = preload("res://battle/geometry/battlefield_geometry.gd")
const Obstacle = preload("res://battle/geometry/battle_obstacle.gd")
const CoverObject = preload("res://battle/geometry/battle_cover_object.gd")
const CoverSlot = preload("res://battle/geometry/battle_cover_slot.gd")
const Cover = preload("res://battle/geometry/battle_cover_service.gd")
const Posture = preload("res://battle/combat/battle_cover_posture_service.gd")
const Fire = preload("res://battle/combat/battle_fire_control_service.gd")
const Targets = preload("res://battle/combat/battle_target_selection_service.gd")
const Behavior = preload("res://battle/combat/battle_combat_behavior_service.gd")
const Orders = preload("res://battle/core/battle_force_command_service.gd")
var checks: int = 0
var failures: Array = []

func _initialize(): call_deferred("run")
func verify(ok: bool, message: String):
	checks += 1
	if not ok: failures.append(message)
func fixture():
	var b = State.new("assault_contract", "skirmish", "test", "test", "a", "d")
	b.battlefield_geometry = Geometry.new()
	var g = b.battlefield_geometry
	g.width = 100; g.height = 60
	g.attacker_deployment_rect = Rect2(0, 0, 49, 60); g.defender_deployment_rect = Rect2(51, 0, 49, 60)
	b.add_side(Side.new("a", "a", "fa", true)); b.add_side(Side.new("d", "d", "fd", false))
	Orders.register_force(b, "fa", "a"); Orders.register_force(b, "fd", "d")
	return b
func unit(b, id: String, side: String, at: Vector2):
	var p = Unit.new(id, id, side, side, "rifle", true, false, "", "fa" if side == "a" else "fd")
	b.add_participant(p); b.get_side(side).add_participant_id(id)
	p.has_battle_position = true; p.battle_position = at; p.movement_speed = 3.6
	return p
func cover(b, p, facing: Vector2):
	var id: String = p.participant_id + "_cover"
	var object = CoverObject.new(id)
	var slot = CoverSlot.new(id + "_slot", id, p.battle_position, facing)
	b.battlefield_geometry.add_cover_object(object)
	b.battlefield_geometry.add_cover_slot(slot)
	verify(Cover.occupy_slot(b, p.participant_id, slot.cover_slot_id).success, "fixture cover occupied")
	return slot
func run():
	var b = fixture(); var a = unit(b, "a1", "a", Vector2(10, 30)); var d = unit(b, "d1", "d", Vector2(36, 30))
	var a_slot = cover(b, a, Vector2.RIGHT); cover(b, d, Vector2.LEFT)
	b.battle_phase = "active"; a.set_target_participant("d1"); d.set_target_participant("a1")
	verify(Fire.evaluate_participant_target_eligibility(b, "a1", "d1", true).rejection_code == "target_tucked_protected", "tucked enemy remains protected from shots")
	Posture.update_for_combat(b, a, 0.05, true); Posture.update_for_combat(b, d, 0.05, true)
	verify(a.cover_posture_phase == "exposing" and d.cover_posture_phase == "exposing", "both units can begin peeking while enemy is tucked")
	for i in range(4):
		Posture.update_for_combat(b, a, 0.05, true); Posture.update_for_combat(b, d, 0.05, true)
	verify(a.is_cover_exposed() and d.is_cover_exposed(), "peek transitions complete")
	verify(Fire.evaluate_participant_target_eligibility(b, "a1", "d1").can_fire, "peek cycle restores a legal firing opportunity")
	Orders.set_command(b, "fa", "push")
	b.elapsed_time_seconds = 30
	b.cover_recovery[a.participant_id] = {"time": 0.0, "position": a.battle_position, "check": 0.0}
	Behavior._recover_stalled_cover(b, a, {})
	verify(a.occupied_cover_slot_id == a_slot.cover_slot_id and not a.has_active_navigation_path(), "useful cover is not abandoned by stationary recovery")
	d.battle_position = Vector2(46, 30); b.clear_los_cache()
	verify(Behavior._healthy_occupied_cover_should_persist(b, a, d, "rifle"), "protected in-range rifle position survives preferred-band difference")
	d.battle_position = Vector2(36, 30); b.clear_los_cache()
	Posture.enter_tucked(a); Posture.enter_tucked(d)
	b.battlefield_geometry.add_obstacle(Obstacle.new("wall", Rect2(22, 20, 2, 20), true, true)); b.clear_los_cache()
	Posture.update_for_combat(b, a, 0.2, true)
	verify(a.cover_posture_phase == "", "hard wall prevents peeking at blocked target")
	verify(not Fire.evaluate_participant_target_eligibility(b, "a1", "d1", true).can_fire, "hard wall continues to block shots")
	b = fixture(); a = unit(b, "a1", "a", Vector2(10, 30)); d = unit(b, "near", "d", Vector2(25, 30))
	unit(b, "visible", "d", Vector2(35, 10))
	b.battlefield_geometry.add_obstacle(Obstacle.new("wall", Rect2(20, 28, 2, 4), true, true)); b.battle_phase = "active"
	Orders.set_command(b, "fa", "push"); Targets.advance(b)
	verify(a.target_participant_id == "visible", "assault selects visible in-range enemy over blocked nearest")
	a.set_player_target_intent("near"); Targets.advance(b)
	verify(a.target_participant_id == "near", "explicit player target remains authoritative")
	var report = {"checks": checks, "failures": failures}
	FileAccess.open("res://tools/arsenal_production/attacker_tactics_validation.json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	print("ATTACKER_TACTICS_VALIDATION ", JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
