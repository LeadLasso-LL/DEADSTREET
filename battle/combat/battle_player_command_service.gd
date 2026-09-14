extends RefCounted
# Group objectives use the same cover/navigation authority as individual orders.
const Cover = preload("res://battle/geometry/battle_cover_service.gd")
const Eval = preload("res://battle/combat/battle_combat_cover_evaluation_service.gd")
const Nav = preload("res://battle/navigation/battle_navigation_service.gd")
const Roles = preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const Body = preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const HOLD_RADIUS = 14.0
const HOP_RADIUS = 16.0
const MIN_ADVANCE = 1.0

static func advance_direction(b, side: String) -> float:
	# Stable deployment geometry, never the changing live unit centroid.
	var g = b.battlefield_geometry
	var own = g.attacker_deployment_rect.get_center().x
	var enemy = g.defender_deployment_rect.get_center().x
	var direction = 1.0 if enemy >= own else -1.0
	return direction if side == b.attacker_side_id else -direction

static func role_progress(role: String) -> float:
	return {"shotgun":1.0, "smg":.95, "pistol":.85, "rifle":.75, "sniper":.6}.get(role, .85)

static func issue(b, ids: Array, command: String, line_x: float = NAN) -> Dictionary:
	b.begin_geometry_validation_scope()
	var previous = Body.begin_runtime_collision_scope(b)
	var result = _issue(b, ids, command, line_x)
	Body.end_runtime_collision_scope(previous)
	b.end_geometry_validation_scope()
	return result

static func _issue(b, ids: Array, command: String, line_x: float) -> Dictionary:
	var result = {"accepted":[], "failed":[]}
	var booked = {}
	for id in ids:
		var p = b.get_participant(id)
		if p == null or not p.is_alive or p.is_wounded or not p.has_battle_position:
			result.failed.append(id)
			continue
		var d = advance_direction(b, p.side_id)
		var state = {"line":line_x, "direction":d, "start":p.battle_position, "goal":p.battle_position, "clock":0.0, "settle":0.0}
		if command == "push":
			var distance = (line_x - p.battle_position.x) * d
			if not is_finite(line_x) or distance < MIN_ADVANCE:
				p.player_order_feedback = "Push line must be ahead of this unit"
				result.failed.append(id)
				continue
			state.goal.x += d * distance * role_progress(p.weapon_type)
		elif command == "fall_back":
			if not is_finite(line_x):
				result.failed.append(id)
				continue
			state.goal.x = minf(p.battle_position.x * d, line_x * d - 1.0) * d
		var choice = _choose(b, p, command, state, booked, true)
		if choice.is_empty():
			p.player_order_feedback = "No reachable protective cover for this order"
			result.failed.append(id)
			continue
		state.goal = choice.slot.position
		state.goal_slot = choice.slot.cover_slot_id
		booked[state.goal_slot] = true
		# Stage long movement through protective cover when a useful intermediate exists.
		var step = choice
		if command != "hold" and p.battle_position.distance_to(state.goal) > HOP_RADIUS:
			var intermediate = _choose(b, p, command, state, {}, false)
			if not intermediate.is_empty():
				step = intermediate
		if not _assign(b, p, step):
			result.failed.append(id)
			continue
		p.player_group_command_id = command
		p.player_command_context = state
		p.player_order_feedback = {"hold":"Seeking protective cover", "push":"Advancing through cover", "fall_back":"Withdrawing through cover"}[command]
		result.accepted.append(id)
	return result

static func _protected(p, slot, threat) -> bool:
	if not Eval._slot_is_legal_for_participant(p, slot):
		return false
	return threat == null or Eval.slot_is_legal_and_protective(p, slot, threat)

static func _allowed(point: Vector2, command: String, state: Dictionary) -> bool:
	if not is_finite(state.line):
		return true
	var x = point.x * state.direction
	var edge = state.line * state.direction
	if command == "push" or command == "hold":
		return x <= edge + .05
	return x <= maxf(state.start.x * state.direction, edge) + .05

static func _route_allowed(path, command: String, state: Dictionary) -> bool:
	var crossed = state.start.x * state.direction <= state.line * state.direction
	for point in path.waypoints:
		if not _allowed(point, command, state):
			return false
		if command == "fall_back":
			var near_side = point.x * state.direction <= state.line * state.direction + .05
			if crossed and not near_side:
				return false
			crossed = crossed or near_side
	return true

static func _choose(b, p, command: String, state: Dictionary, booked: Dictionary, final: bool) -> Dictionary:
	var threat = Eval.relevant_cover_threat(b, p)
	var rows = []
	var direction: float = state.direction
	var goal: Vector2 = state.goal
	for slot in b.battlefield_geometry.cover_slots.values():
		if booked.has(slot.cover_slot_id) or not _protected(p, slot, threat):
			continue
		var distance = p.battle_position.distance_to(slot.position)
		if not _allowed(slot.position, command, state):
			continue
		if command == "hold":
			if slot.position.distance_to(state.goal) > HOLD_RADIUS:
				continue
			if slot.cover_slot_id == p.occupied_cover_slot_id:
				return {"slot":slot, "path":null, "final":true}
		elif command == "push":
			if (slot.position.x - state.start.x) * direction < MIN_ADVANCE:
				continue
		elif final and slot.position.x * direction > state.line * direction:
			continue
		if not final:
			if distance > HOP_RADIUS or distance < 1.0:
				continue
			if slot.position.distance_to(goal) >= p.battle_position.distance_to(goal) - 1.0:
				continue
		var score = distance if command == "hold" else absf(slot.position.x-goal.x)*3.0 + absf(slot.position.y-goal.y)*.8 + distance*.15
		# Rearward/sideways steps during retreat are preferable to approaching a threat.
		if threat != null and slot.position.distance_to(threat.battle_position) < p.battle_position.distance_to(threat.battle_position) - 2.0 and command != "push":
			score += 12.0
		rows.append([score, slot.cover_slot_id, slot])
	rows.sort_custom(func(a,z): return a[1] < z[1] if is_equal_approx(a[0],z[0]) else a[0] < z[0])
	var best = {}
	var best_score = INF
	# Bound path searches per decision; this does not run for each mouse movement.
	for i in range(mini(12, rows.size())):
		var slot = rows[i][2]
		if Cover.is_at_slot(p, slot):
			return {"slot":slot, "path":null, "final":final}
		var path = Nav.find_path(b, p.battle_position, slot.position)
		if path == null or not path.success or not _route_allowed(path, command, state):
			continue
		var cost = float(rows[i][0])
		var previous: Vector2 = p.battle_position
		for point in path.waypoints:
			var length = previous.distance_to(point)
			cost += length * .2
			if threat != null and point.distance_to(threat.battle_position) < p.battle_position.distance_to(threat.battle_position) - 3.0:
				cost += length * .3
			previous = point
		if cost < best_score:
			best_score = cost
			best = {"slot":slot, "path":path, "final":final}
	return best

static func _assign(b, p, choice: Dictionary) -> bool:
	var slot = choice.slot
	var path = choice.path
	if Cover.is_at_slot(p, slot):
		var occupied = Cover.occupy_slot(b, p.participant_id, slot.cover_slot_id)
		if occupied == null or not occupied.success:
			return false
		p.set_player_cover_intent(slot.cover_object_id, slot.cover_slot_id)
		p.clear_navigation_path()
		p.clear_movement_intent()
		p.velocity = Vector2.ZERO
		return true
	if path == null or not path.success:
		return false
	if p.occupied_cover_slot_id != slot.cover_slot_id:
		Cover.release_all_for_participant(b, p.participant_id)
	var reserved = Cover.reserve_slot(b, p.participant_id, slot.cover_slot_id)
	if reserved == null or not reserved.success:
		return false
	p.set_player_cover_intent(slot.cover_object_id, slot.cover_slot_id)
	if Cover.is_at_slot(p, slot):
		Cover.occupy_slot(b, p.participant_id, slot.cover_slot_id)
		p.clear_navigation_path()
		p.clear_movement_intent()
		p.velocity = Vector2.ZERO
	else:
		if not p.set_navigation_path(path.destination, path.waypoints, p.NAVIGATION_SOURCE_EXTERNAL):
			Cover.release_reservation(b, p.participant_id)
			return false
		if p.movement_speed <= 0.0:
			p.set_movement_speed(Roles.DEFAULT_COMBAT_MOVEMENT_SPEED)
	return true

static func advance(b, p, delta: float) -> void:
	if p.player_command_context.is_empty():
		return
	if not p.is_alive or p.is_wounded:
		Cover.release_reservation(b, p.participant_id)
		p.clear_navigation_path()
		p.clear_player_tactical_intent()
		return
	var state: Dictionary = p.player_command_context
	var command: String = p.player_group_command_id
	var slot = b.battlefield_geometry.get_cover_slot(p.player_cover_slot_id)
	var arrived = slot != null and Cover.is_at_slot(p, slot)
	if arrived:
		Cover.occupy_slot(b, p.participant_id, slot.cover_slot_id)
		p.clear_navigation_path()
		if command == "push" and p.battle_position.distance_to(state.goal) < 1.0:
			# Keep occupied protection and independent target priority; release positioning.
			p.clear_player_cover_intent()
			p.player_order_feedback = "Push complete"
			return
		if command == "fall_back" and p.battle_position.x * state.direction <= state.line * state.direction + .05:
			p.player_group_command_id = "hold"
			state.goal = p.battle_position
			command = "hold"
			p.player_order_feedback = "Holding defensive position"
	state.clock = float(state.clock) - delta
	if float(state.clock) > 0.0:
		return
	state.clock = 1.25
	var threat = Eval.relevant_cover_threat(b, p)
	var protective = slot != null and _protected(p, slot, threat) and _allowed(slot.position, command, state)
	if command == "hold" and protective:
		return
	if not arrived and protective and p.has_active_navigation_path():
		return
	if arrived and command != "hold":
		state.settle = float(state.settle) + 1.25
		if float(state.settle) < 1.5:
			return
		state.settle = 0.0
	var choice = _choose(b, p, command, state, {}, false if command != "hold" else true)
	if choice.is_empty():
		choice = _choose(b, p, command, state, {}, true)
	if not choice.is_empty() and _assign(b, p, choice):
		# A taken final slot can be replaced by another suitable position near the goal.
		if command == "push" and (choice.get("final",false) or choice.slot.position.distance_to(state.goal) < 1.0):
			state.goal = choice.slot.position
		return
	# Keep current protection and retry; do not silently resume an aggressive force AI.
	p.player_order_feedback = "Waiting for reachable protective cover"
	if not protective:
		Cover.release_reservation(b, p.participant_id)
		p.set_player_hold_intent()

static func line_segments(b, x: float) -> Array:
	var spans = []
	var start = -1.0
	var height = b.battlefield_geometry.height
	for i in range(ceili(height * 2.0) + 1):
		var y = minf(height, i * .5)
		var point = Vector2(x, y)
		var legal = y < height and b.battlefield_geometry.get_movement_blocking_obstacle_id_at(point).is_empty() and Body.blocking_vehicle_id_at(b, point).is_empty()
		if legal and start < 0.0:
			start = y
		elif not legal and start >= 0.0:
			spans.append(Vector2(start, y))
			start = -1.0
	return spans
