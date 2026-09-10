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
var comparing := false
var out_dir := "res://tools/dusk_review/harold_results"

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
	var segment=preload("res://world/roads/road_segment.gd").new("street_test","a","b",12)
	segment.street_name=preload("res://world/harold_location.gd").STREET
	var restored=preload("res://world/roads/road_segment.gd").new()
	restored.from_dict(segment.to_dict())
	if restored.street_name!=segment.street_name:fail("street name serialization");return
	var occupied: Array[Vector2] = []
	var controller = runtime.tactical_deployment_controller
	for p in battle.participants.values():
		if p.side_id != battle.attacker_side_id:
			continue
		controller.select_participant(p.participant_id)
		var placed := false
		var preferred := Vector2(44 + occupied.size()*3,30)
		var first = controller.try_place_selected(preferred)
		if first != null and first.success:
			occupied.append(preferred)
			placed = true
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
	for unit in battle.participants.values():
		var expected="russian_organized_crime" if unit.side_id==battle.attacker_side_id else "local_street_gang"
		if unit.identity.gang_archetype_id!=expected:
			fail("faction identity");return
		if unit.side_id==battle.defender_side_id and not preload("res://battle/geometry/harold_street_catalog.gd").DEFENDER_ZONE.has_point(unit.battle_position):
			fail("defender zone");return
	# Validate real navigation with the arrival vehicle already placed.
	var g = battle.battlefield_geometry
	var problems: Array[String] = []
	var nav = load("res://battle/navigation/battle_navigation_service.gd")
	for slot_id in g.get_sorted_cover_slot_ids():
		var slot = g.get_cover_slot(slot_id)
		if not nav.is_reachable(battle,Vector2(49,30),slot.position):
			problems.append("unreachable "+slot_id)
	var threshold = g.get_cover_slot("cover_north_car_3_1").position
	var defensive = g.get_cover_slot("cover_stoop_west_2").position
	var range_distance: float = threshold.distance_to(defensive)
	if range_distance > 20: problems.append("SMG threshold out of range")
	var audit = {"geometry_valid":g.is_valid(),"cover_slots":g.get_sorted_cover_slot_ids().size(),"smg_threshold_distance":range_distance,"problems":problems}
	FileAccess.open(out_dir+"/layout_audit.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"  "))
	print("DUSK_LAYOUT_AUDIT ",JSON.stringify(audit))
	if not problems.is_empty():
		fail("layout audit")
		return
	var begin = runtime.begin_current_battle()
	if begin == null or not begin.success:
		fail("begin")
		return
	runtime.set_process(false)
	active = true
	print("PIXEL_REVIEW_ACTIVE participants=", battle.participants.size())

func _process(delta: float) -> bool:
	if not active or comparing:
		return false
	elapsed += delta
	frames += 1
	if elapsed > 3.0:
		samples.append(delta * 1000.0)
	var session = runtime.get_current_session()
	if session == null:
		return false
	var battle = session.battle_state
	if battle.battle_phase == "active":
		active_samples.append(delta * 1000.0)
		load("res://battle/runtime/battle_runtime_service.gd").advance(battle, delta)
	var view = runtime.get_node("TacticalBattleView")
	if view.actor_presenter != null:
		for id in battle.participants:
			var clip: String = view.actor_presenter.unit_clip_id(id)
			clips[clip] = int(clips.get(clip, 0)) + 1
	for event in battle.combat_feedback_events:
		shots[event.sequence_id] = true
	for second in [1, 2, 5, 10]:
		if elapsed >= second and not captured.has(second):
			captured[second] = true
			capture(second)
	if elapsed >= 15.0:
		var alive := 0
		var wounded := 0
		for p in battle.participants.values():
			if p.is_alive: alive += 1
			if p.is_wounded: wounded += 1
		samples.sort()
		var report := {"elapsed_real_seconds":elapsed,"simulation_seconds":battle.elapsed_time_seconds,"participants":battle.participants.size(),"alive":alive,"wounded":wounded,"observed_shots":shots.size(),"clips_observed":clips,"mean_fps":frames/elapsed,"p95_frame_ms":samples[int(samples.size()*.95)] if not samples.is_empty() else 0.0,"phase":battle.battle_phase}
		active_samples.sort()
		report["active_combat_p95_ms"] = active_samples[int(active_samples.size()*.95)] if not active_samples.is_empty() else 0.0
		var total_ms := 0.0
		for ms in active_samples: total_ms += ms
		report["active_combat_mean_fps"] = active_samples.size()*1000.0/maxf(total_ms, 1.0)
		FileAccess.open(out_dir + "/runtime_report.json", FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
		print("PIXEL_REVIEW_REPORT ",JSON.stringify(report))
		active = false
		quit()
	return false

func capture(second: int) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + "/battle_%02d.png" % second)
	if second == 2:
		comparing=true
		var view=runtime.get_node("TacticalBattleView")
		view._dusk_zoom=1.65
		view._dusk_pan=Vector2(-65,-10)
		view._frame_camera()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out_dir+"/harold_close.png")
		view._dusk_zoom=1.1
		view._dusk_pan=Vector2.ZERO
		view._frame_camera()
		comparing=false

func fail(reason: String) -> void:
	push_error("HAROLD_REVIEW_FAILED "+reason)
	quit(1)
