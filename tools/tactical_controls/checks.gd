extends SceneTree
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime = preload("res://battle/runtime/battle_runtime_service.gd")
const Orders = preload("res://gameplay/tactical_orders_controller.gd")
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
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
	check(not f.is_empty(), "fixture created")
	if f.is_empty():
		quit(1)
		return
	var b = f.battle
	var c = f.orders
	c.select_class()
	check(c.selected_participant_ids.size() == 12, "select all includes full living force")
	var roster: Array[String] = c.selected_participant_ids.duplicate()
	var a = b.get_participant(roster[0])
	var other = b.get_participant(roster[1])
	var hostile
	for p in b.participants.values():
		if p.side_id != b.attacker_side_id:
			hostile = p
			break
	c.command_selected("hold")
	for id in roster:
		check(b.get_participant(id).current_player_group_command() == "hold", "hold owns " + id)
	a.is_wounded = true
	check(Query.living_first_ids(b, roster) == roster, "wounds do not reorder roster")
	check(Query.card_for(a, a.participant_id).can_select, "wounded card remains selectable")
	check(a.current_player_group_command().is_empty(), "wound immediately hides badge")
	a.is_wounded = false
	a.is_alive = false
	var reordered = Query.living_first_ids(b, roster)
	check(reordered.back() == a.participant_id and reordered[0] == other.participant_id, "eliminated moves behind living, stable order")
	check(a.current_player_group_command().is_empty(), "elimination immediately hides badge")
	a.is_alive = true
	c.select_participant(a.participant_id)
	c.select_participant(other.participant_id, true)
	check(c.selected_participant_ids.size() == 2, "shift adds unit")
	c.select_participant(other.participant_id, true)
	check(c.selected_participant_ids == [a.participant_id], "shift toggles only clicked unit")
	c.select_class(a.weapon_type)
	for id in c.selected_participant_ids:
		check(b.get_participant(id).weapon_type == a.weapon_type, "class shortcut matches class")
	c.select_participant(a.participant_id)
	b.tactical_paused = true
	var before = snapshot(b)
	for i in range(8):
		check(Runtime.advance(b, .1).success, "paused runtime returns success")
	check(snapshot(b) == before, "pause freezes RNG, clock, movement, weapon and target state")
	var order = c.issue_move(a.battle_position + Vector2(0, .5))
	check(order.success, "movement order accepted while paused")
	check(a.current_player_group_command().is_empty(), "individual move removes only its group marker")
	check(other.current_player_group_command() == "hold", "other selected-group marker survives")
	var at = a.battle_position
	Runtime.advance(b, .5)
	check(a.battle_position == at, "paused movement waits for resume")
	order = c.issue_target(hostile.participant_id)
	check(order.success and a.player_priority_target_id == hostile.participant_id, "target priority accepted")
	check(a.current_player_intent() == a.PLAYER_INTENT_MOVE, "target preserves move ownership")
	c.command_selected("hold")
	check(a.player_priority_target_id == hostile.participant_id, "hold preserves target priority")
	b.tactical_paused = false
	for i in range(5):
		Runtime.advance(b, .02)
	check(a.battle_position == at, "hold resists routine AI and target chase")
	c.command_selected("clear")
	check(a.current_player_intent().is_empty() and a.player_priority_target_id.is_empty() and a.current_player_group_command().is_empty(), "Clear Orders releases position, priority and badge")
	check(other.current_player_group_command() == "hold", "clear affects selected only")
	a.set_player_move_intent()
	a.player_order_position = a.battle_position + Vector2(100,0)
	a.has_player_order_position = true
	a.player_group_command_id = "push"
	a.clear_navigation_path()
	a.finish_player_move()
	check(a.current_player_group_command().is_empty() and a.current_player_intent().is_empty(), "interrupted route releases group ownership")
	# Push/Fall Back remain owned at the assigned position; a replacement clears them.
	c.command_selected("push")
	check(c.pending_command_id == "push" and a.current_player_group_command().is_empty(), "pending command does not claim a badge")
	order = c.issue_move(a.battle_position)
	check(order.success and a.current_player_group_command() == "push", "push destination assigns current badge")
	c.command_selected("fall_back")
	order = c.issue_move(a.battle_position)
	check(order.success and a.current_player_group_command() == "fall_back", "fall back replaces push ownership")
	# A genuine cover order retains priority; multiple recipients cannot own one slot.
	c.select_participant(a.participant_id)
	c.select_participant(other.participant_id, true)
	var cover_ids = b.battlefield_geometry.get_sorted_cover_object_ids()
	var chosen = ""
	for id in cover_ids:
		if Eval.rank_legal_slots_on_cover_object(b,a,id,hostile).size() >= 2:
			chosen = id
			break
	check(not chosen.is_empty(), "multi-slot cover fixture available")
	if not chosen.is_empty():
		c.issue_target(hostile.participant_id)
		order = c.issue_cover(chosen)
		check(order.success, "group cover accepts available slots")
		var assigned = []
		for p in [a, other]:
			if p.has_player_cover_intent():
				check(p.player_priority_target_id == hostile.participant_id, "cover preserves priority")
				check(p.current_player_group_command().is_empty(), "individual cover replaces group marker")
				check(p.player_cover_slot_id not in assigned, "cover slots are exclusive")
				assigned.append(p.player_cover_slot_id)
		check(assigned.size() == 2, "two selected units distributed to distinct cover slots")
	# Input shortcuts use battle-local pause, never SceneTree.pause.
	var key = InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	var was_paused = b.tactical_paused
	check(c.handle_input(f.view,key) and b.tactical_paused != was_paused and not paused, "Space toggles tactical pause with UI tree live")
	for rate in [.5, 1.0, 1.5]:
		var elapsed = b.elapsed_time_seconds
		b.set_tactical_speed(rate)
		check(not b.tactical_paused, "speed choice resumes")
		var result = Runtime.advance(b, .02)
		check(result.success and is_equal_approx(b.elapsed_time_seconds - elapsed, .02 * rate), "runtime clock scales " + str(rate))
	f.runtime.free()
	var report = {"checks":checks, "errors":errors}
	var path = "C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/checks.json"
	FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CONTROLS_RESULT ",JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
