extends SceneTree

var runtime: Node
var elapsed := 0.0
var frames := 0
var samples: Array[float] = []
var active_samples: Array[float] = []
var clips: Dictionary = {}
var shots: Dictionary = {}
var captured: Dictionary = {}
var active := false
var out_dir := "res://tools/pixel_integration/results"

func _initialize() -> void:
	call_deferred("start")

func start() -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	runtime = load("res://gameplay/gameplay_runtime.tscn").instantiate()
	root.add_child(runtime)
	await process_frame
	var launch = runtime.debug_launch_test_hq_assault()
	if launch == null or not launch.success:
		fail("launch")
		return
	for i in range(20):
		runtime.advance_campaign_turn()
		var result = runtime.enter_battle()
		if result != null and result.success:
			break
	var session = runtime.get_current_session()
	if session == null or session.battle_state == null:
		fail("session")
		return
	var battle = session.battle_state
	var occupied: Array[Vector2] = []
	var controller = runtime.tactical_deployment_controller
	for p in battle.participants.values():
		if p.side_id != battle.attacker_side_id:
			continue
		controller.select_participant(p.participant_id)
		var placed := false
		var area: Rect2 = battle.battlefield_geometry.attacker_deployment_rect
		for y in range(int(area.position.y)+1, int(area.end.y)):
			if placed: break
			for x in range(int(area.position.x)+1, int(area.end.x)):
				var point := Vector2(x,y)
				var crowded := false
				for used in occupied:
					if used.distance_to(point) < 1.8: crowded = true
				if crowded: continue
				var attempt = controller.try_place_selected(point)
				if attempt != null and attempt.success:
					occupied.append(point)
					placed = true
					break
		if not placed:
			fail("attacker placement")
			return
	var committed = controller.try_commit_attacker()
	if committed == null or not committed.success:
		fail("attacker commit")
		return
	var ai = load("res://battle/ai/battle_deployment_ai_service.gd")
	for side in [battle.attacker_side_id, battle.defender_side_id]:
		if not battle.is_side_deployment_committed(side):
			var other = battle.defender_side_id if side == battle.attacker_side_id else battle.attacker_side_id
			var deployed = ai.apply_and_commit_side(battle, side, other)
			if not deployed.success:
				fail("deployment: " + deployed.error_code)
				return
	var begin = runtime.begin_current_battle()
	if begin == null or not begin.success:
		fail("begin")
		return
	runtime.set_process(false)
	active = true
	if not OS.get_cmdline_user_args().has("--before"):
		verify_cache(battle)
	print("PIXEL_REVIEW_ACTIVE participants=", battle.participants.size())

func _process(_delta: float) -> bool:
	if not active: return false
	var battle = runtime.get_current_session().battle_state
	var service = load("res://tools/slowdown_profile/runtime.gd") if OS.get_cmdline_user_args().has("--before") else load("res://battle/runtime/battle_runtime_service.gd")
	service.advance(battle, 1.0/60.0)
	frames += 1
	for event in battle.combat_feedback_events:
		shots[event.sequence_id] = {"source":event.source_participant_id,"target":event.target_participant_id}
	if battle.battle_phase != "active" or frames > 1800:
		var units: Dictionary = {}
		for id in battle.participants:
			var p = battle.participants[id]
			units[id] = {"alive":p.is_alive,"wounded":p.is_wounded,"position":[p.battle_position.x,p.battle_position.y],"target":p.target_participant_id}
		var report = {"ticks":frames,"phase":battle.battle_phase,"shots":shots,"units":units}
		var label = "before" if OS.get_cmdline_user_args().has("--before") else "after"
		FileAccess.open("res://tools/slowdown_profile/fixed_"+label+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
		print("FIXED_REVIEW ",label," ticks=",frames," shots=",shots.size())
		quit()
	return false

func verify_cache(battle) -> void:
	var geom = battle.battlefield_geometry
	var width = geom.width
	battle.begin_geometry_validation_scope()
	assert(battle.has_valid_geometry())
	battle.end_geometry_validation_scope()
	geom.width = -1.0
	assert(not battle.has_valid_geometry())
	battle.begin_geometry_validation_scope()
	assert(not battle.has_valid_geometry())
	battle.end_geometry_validation_scope()
	geom.width = width
	battle.begin_geometry_validation_scope()
	assert(battle.has_valid_geometry())
	geom.width = -1.0
	geom.content_revision += 1
	assert(not battle.has_valid_geometry())
	geom.width = width
	geom.content_revision += 1
	assert(battle.has_valid_geometry())
	var slot = geom.cover_slots.values()[0]
	var facing = slot.facing_direction
	slot.facing_direction = Vector2.ZERO
	geom.cover_slot_revision += 1
	assert(not battle.has_valid_geometry())
	slot.facing_direction = facing
	geom.cover_slot_revision += 1
	assert(battle.has_valid_geometry())
	battle.end_geometry_validation_scope()
	var service = load("res://battle/runtime/battle_runtime_service.gd")
	service.advance(battle, -1.0)
	assert(not battle._geometry_validation_scope)
	geom.width = -1.0
	var los = load("res://battle/combat/battle_line_of_sight_service.gd").check_segment(battle,Vector2.ZERO,Vector2.ONE)
	assert(not los.success and los.error_code == "invalid_battlefield_geometry")
	geom.width = width
	print("CACHE_BOUNDARY_CHECKS PASS")

func fail(reason: String) -> void:
	push_error(reason)
	quit(1)
