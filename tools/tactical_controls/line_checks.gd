extends SceneTree
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime = preload("res://battle/runtime/battle_runtime_service.gd")
const Orders = preload("res://gameplay/tactical_orders_controller.gd")
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
const Commands = preload("res://battle/combat/battle_player_command_service.gd")
const Behavior = preload("res://battle/combat/battle_combat_behavior_service.gd")
const Cover = preload("res://battle/geometry/battle_cover_service.gd")
const Eval = preload("res://battle/combat/battle_combat_cover_evaluation_service.gd")
class View extends Node2D:
	var _dusk_zoom = 1.3
	var _dusk_pan = Vector2.ZERO
	var deployment_controller
	func _frame_camera(): pass
	func _is_dusk_street(): return false
	func _to_view(point): return point * Vector2(8, 6)
var errors: Array = []
var checks: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		errors.append(label)
		printerr("CONTROLS_FAIL ", label)

func make_fixture() -> Dictionary:
	var r = load("res://gameplay/gameplay_runtime.gd").new()
	r.game_state = load("res://gameplay/starter_world_service.gd").create()
	r.game_flow_controller = load("res://core/game_flow_controller.gd").create(r.game_state).controller
	var view = View.new()
	view.name = "TacticalBattleView"
	r.add_child(view)
	var config = Cases.make(12, 12, ["aegis", "vigil", "aegis"])
	config.map_id = "river_bridge"
	config.defender.vehicles = ["bulwark", "interceptor", "bulwark"]
	var setup = Fixture.setup(r, config, false, 734, true)
	if not setup.has("battle"):
		return {}
	var b = setup.battle
	var begin = Fixture.begin_review(r, b)
	if begin == null or not begin.success:
		return {}
	var orders = Orders.new()
	orders.bind_session(r.get_current_session())
	return {"runtime":r, "battle":b, "orders":orders, "view":view}

func snapshot(b) -> Array:
	var rows = [b.battle_phase, b.elapsed_time_seconds, b.combat_random.snapshot_state()]
	for id in b.participants:
		var p = b.participants[id]
		rows.append([id,p.is_alive,p.is_wounded,p.vitality,p.battle_position,p.velocity,p.target_participant_id,p.occupied_cover_slot_id,p.reserved_cover_slot_id,p.navigation_waypoints.duplicate(),p.weapon_state.ammo_in_magazine,p.weapon_state.cooldown_remaining_seconds,p.weapon_state.reload_remaining_seconds])
	return rows

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var f = make_fixture()
	check(not f.is_empty(), "bridge command fixture")
	if f.is_empty(): quit(1); return
	var b = f.battle
	var c = f.orders
	c.select_class()
	var ids: Array = c.selected_participant_ids.duplicate()
	var p = b.get_participant(ids[0])
	var before_slot: String = p.occupied_cover_slot_id
	c.command_selected("hold")
	var assigned = {}
	var held = []
	for id in ids:
		var unit = b.get_participant(id)
		if unit.current_player_group_command() != "hold": continue
		held.append(id)
		var slot = b.battlefield_geometry.get_cover_slot(unit.player_cover_slot_id)
		check(slot != null, "Hold assigns real cover")
		check(Commands._protected(unit, slot, Eval.relevant_cover_threat(b, unit)), "Hold cover protects against relevant threat")
		check(not assigned.has(slot.cover_slot_id), "group reserves distinct cover slots")
		assigned[slot.cover_slot_id] = true
	check(held.size() >= 8, "most full-force units acquire useful Hold cover")
	if not before_slot.is_empty() and Commands._protected(p, b.battlefield_geometry.get_cover_slot(before_slot), Eval.relevant_cover_threat(b,p)):
		check(p.player_cover_slot_id == before_slot, "Hold keeps existing useful cover")
	var direction = Commands.advance_direction(b, b.attacker_side_id)
	check(direction == -Commands.advance_direction(b, b.defender_side_id), "opposing teams have mirrored advance direction")
	var g = b.battlefield_geometry
	var old_a = g.attacker_deployment_rect
	g.attacker_deployment_rect = g.defender_deployment_rect
	g.defender_deployment_rect = old_a
	check(Commands.advance_direction(b, b.attacker_side_id) == -direction, "reversed map deployment flips command direction")
	g.defender_deployment_rect = g.attacker_deployment_rect
	g.attacker_deployment_rect = old_a
	check(Commands.role_progress("shotgun") > Commands.role_progress("sniper"), "sniper advances less aggressively than shotgun")
	var at = p.battle_position
	Cover.release_all_for_participant(b,p.participant_id)
	p.clear_player_tactical_intent()
	for offset in [Vector2(2,0),Vector2(-2,0),Vector2(0,2),Vector2(0,-2)]:
		var point = at+offset
		if g.contains_point(point) and g.get_movement_blocking_obstacle_id_at(point).is_empty() and Commands.Body.blocking_vehicle_id_at(b,point).is_empty():
			p.battle_position = point
			break
	var exposed = p.battle_position
	var held_result = Commands.issue(b,[p.participant_id],"hold")
	check(held_result.accepted.size() == 1, "exposed unit can seek protective Hold cover")
	check(p.player_cover_slot_id != "" and g.get_cover_slot(p.player_cover_slot_id).position.distance_to(exposed) > .1, "Hold moves exposed unit rather than freezing it")
	c.select_class()
	var before_orders = snapshot(b)
	c.command_selected("push")
	c.set_line_x(82.0,true)
	check(snapshot(b) == before_orders, "placing line leaves simulation unchanged")
	check(not c.line_spans.is_empty(), "line has traversable ground segments")
	for span in c.line_spans:
		var middle = Vector2(c.line_x,(span.x+span.y)*.5)
		check(g.get_movement_blocking_obstacle_id_at(middle).is_empty(), "line excludes impassable ground")
	var pushed = c.commit_line()
	check(pushed.accepted.size() >= 6, "role-aware Push accepted across force")
	check(c.pending_command_id.is_empty() and not c.confirmation.is_empty(), "commit detaches line and creates confirmation")
	var push_id = ""
	for id in pushed.accepted:
		var unit = b.get_participant(id)
		var context = unit.player_command_context
		check(context.goal.x <= 82.05, "Push destination stays before limit")
		check((context.goal.x-context.start.x)*context.direction >= 1.0, "each Push recipient makes meaningful progress")
		for point in unit.navigation_waypoints:
			check(point.x <= 82.05, "Push route never overshoots boundary")
		if push_id.is_empty():push_id=id
	check(not push_id.is_empty(), "Push completion fixture")
	if not push_id.is_empty():
		var unit = b.get_participant(push_id)
		var goal = g.get_cover_slot(unit.player_command_context.goal_slot)
		Cover.release_all_for_participant(b,push_id)
		unit.battle_position = goal.position
		unit.set_player_cover_intent(goal.cover_object_id,goal.cover_slot_id)
		Cover.occupy_slot(b,push_id,goal.cover_slot_id)
		unit.clear_navigation_path()
		Commands.advance(b,unit,.1)
		check(unit.current_player_group_command().is_empty() and unit.current_player_intent().is_empty(), "Push completion returns individual unit to normal AI")
		check(unit.occupied_cover_slot_id == goal.cover_slot_id, "Push completion preserves occupied cover")
		c.select_participant(push_id)
		c.command_selected("fall_back")
		c.set_line_x(unit.battle_position.x-8.0,true)
		var retreat_line = c.line_x
		var retreat = c.commit_line()
		check(retreat.accepted.size()==1,"Fall Back finds cover behind line")
		if retreat.accepted.size()==1:
			var goal_slot = g.get_cover_slot(unit.player_command_context.goal_slot)
			check(goal_slot.position.x<=retreat_line,"Fall Back final cover is on friendly side")
			Cover.release_all_for_participant(b,push_id)
			unit.battle_position=goal_slot.position
			unit.set_player_cover_intent(goal_slot.cover_object_id,goal_slot.cover_slot_id)
			Cover.occupy_slot(b,push_id,goal_slot.cover_slot_id)
			unit.clear_navigation_path()
			Commands.advance(b,unit,.1)
			check(unit.current_player_group_command()=="hold","Fall Back completion becomes Holding")
			check(not unit.player_command_context.is_empty(),"defensive boundary remains owned after retreat")
			unit.is_wounded=true
			check(unit.current_player_group_command().is_empty(),"wound hides command immediately")
			Commands.advance(b,unit,.1)
			check(unit.player_command_context.is_empty(),"wound releases order authority")
			unit.is_wounded=false
	c.select_class()
	c.command_selected("hold")
	var controlled = []
	for id in ids:
		if b.get_participant(id).current_player_group_command()=="hold":controlled.append(id)
	if controlled.size()>1:
		c.select_participant(controlled[0])
		c.command_selected("clear")
		check(b.get_participant(controlled[0]).player_command_context.is_empty(),"Clear Orders releases selected recipient")
		check(b.get_participant(controlled[1]).current_player_group_command()=="hold","Clear Orders preserves other recipients")
	b.tactical_paused=true
	var frozen=snapshot(b)
	Runtime.advance(b,.5)
	check(snapshot(b)==frozen,"pause freezes command travel and combat")
	b.tactical_paused=false
	for i in range(60):
		var result=Runtime.advance(b,.05)
		if not result.success:check(false,"native runtime accepts command states");break
	check(b.elapsed_time_seconds>2.0,"runtime advances with new commands")
	# Exercise real navigation and staged cover hops through completion, with weapons
	# cooling down to isolate order travel from casualties. No position teleporting.
	var travel = make_fixture()
	var tb = travel.battle
	var tc = travel.orders
	tc.select_class()
	tc.command_selected("hold")
	for unit in tb.participants.values():
		unit.weapon_state.cooldown_remaining_seconds=1000.0
	var walker = tb.get_participant(tc.selected_participant_ids[0])
	var origin_x = walker.battle_position.x
	var walk = Commands.issue(tb,[walker.participant_id],"push",origin_x+24.0)
	check(walk.accepted.size()==1,"travel fixture accepts forward cover goal")
	if walk.accepted.size()==1:
		for i in range(1200):
			Runtime.advance(tb,.05)
			if walker.current_player_group_command().is_empty():break
		check(walker.battle_position.x>origin_x+1.0,"Push makes real navigation progress")
		check(walker.current_player_group_command().is_empty(),"Push completes through runtime without teleporting")
		var retreat_edge = walker.battle_position.x-8.0
		var withdrawing=Commands.issue(tb,[walker.participant_id],"fall_back",retreat_edge)
		check(withdrawing.accepted.size()==1,"travel fixture accepts defensive cover goal")
		if withdrawing.accepted.size()==1:
			for i in range(1200):
				Runtime.advance(tb,.05)
				if walker.current_player_group_command()=="hold":break
			check(walker.battle_position.x<=retreat_edge+.05,"Fall Back really crosses to friendly side")
			check(walker.current_player_group_command()=="hold","Fall Back becomes Holding through runtime without teleporting")
	travel.runtime.free()
	var report={"checks":checks,"errors":errors,"push_accepted":pushed.accepted.size(),"hold_accepted":held.size()}
	FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/line_checks.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("LINE_COMMANDS ",JSON.stringify(report))
	f.runtime.free()
	quit(0 if errors.is_empty() else 1)
