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
	print("PIXEL_REVIEW_ACTIVE participants=", battle.participants.size())

func _process(delta: float) -> bool:
	if not active:
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
	for second in [2, 10, 25, 40]:
		if elapsed >= second and not captured.has(second):
			captured[second] = true
			capture(second)
	if elapsed >= 45.0:
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

func fail(reason: String) -> void:
	push_error("PIXEL_REVIEW_FAILED " + reason)
	quit(1)
