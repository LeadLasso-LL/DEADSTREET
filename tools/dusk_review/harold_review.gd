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
var out_dir := "res://tools/dusk_review/frontage_results"

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

	var los=load("res://battle/combat/battle_line_of_sight_service.gd")
	var wall_checks=0
	for row in preload("res://battle/geometry/harold_street_catalog.gd").props():
		if row[2]!="stoop_wall":continue
		var b: Rect2=row[1]
		if not is_equal_approx(b.position.y,15.):problems.append("wall not flush to facade "+str(row[0]))
		for along in [.12,.5,.88]:
			var sy=b.position.y+b.size.y*along
			var left=Vector2(b.position.x-.85,sy)
			var right=Vector2(b.end.x+.85,sy)
			for endpoints in [[left,right],[right,left]]:
				var result=los.check_segment(battle,endpoints[0],endpoints[1])
				if not result.success or result.has_line_of_sight or result.blocking_obstacle_id!=row[0]:
					problems.append("sightline through wall "+str(row[0]))
				wall_checks+=1
		var left=Vector2(b.position.x-.85,b.end.y+.85)
		var right=Vector2(b.end.x+.85,b.end.y+.85)
		if not los.check_segment(battle,left,right).has_line_of_sight:problems.append("wall end sightline "+str(row[0]))
		var path=nav.find_path(battle,Vector2(left.x,b.get_center().y),Vector2(right.x,b.get_center().y))
		if not path.success or path.waypoints.size()<2:problems.append("wall bypass path "+str(row[0]))
		wall_checks+=2
		for side in [2,3]:
			var corner=g.get_cover_slot("cover_"+str(row[0])+"_"+str(side))
			var street_target=corner.position+corner.facing_direction*10+Vector2(0,8)
			if not los.check_segment(battle,corner.position,street_target).has_line_of_sight:
				problems.append("no firing angle around corner "+str(row[0]))
			wall_checks+=1
	for entrance in [Vector2(25,15.6),Vector2(51.4,15.6)]:
		if not nav.is_reachable(battle,Vector2(49,30),entrance):problems.append("inaccessible stair entrance")
	var bin_checks=0
	var protection=load("res://battle/geometry/battle_cover_protection_service.gd")
	var art_view=runtime.get_node("TacticalBattleView")
	for row in preload("res://battle/geometry/harold_street_catalog.gd").props():
		if row[2] not in ["trash_can","trash_can_fallen"]:continue
		var bounds: Rect2=row[1]
		var object_id="cover_"+str(row[0])
		var cover=g.get_cover_object(object_id)
		if cover==null or cover.slot_ids.size()<2:
			problems.append("can lacks usable cover "+str(row[0]));continue
		if g.get_movement_blocking_obstacle_id_at(bounds.get_center())!=row[0]:
			problems.append("can does not block movement "+str(row[0]))
		var click_point=Vector2(bounds.get_center().x*8,bounds.end.y*6-(7 if row[2]=="trash_can" else 4))
		if art_view.hit_test_cover_object(click_point)!=object_id:
			problems.append("can body not clickable "+str(row[0]))
		bin_checks+=3
		for slot_id in cover.slot_ids:
			var slot=g.get_cover_slot(slot_id)
			var front=protection.query_slot_protection(slot,slot.position+slot.facing_direction*8)
			var rear=protection.query_slot_protection(slot,slot.position-slot.facing_direction*8)
			if front.protection_factor<.99 or rear.protection_factor>.01:
				problems.append("can directional protection "+str(slot_id))
			bin_checks+=2
	# Arrival body uses the same range as the authored parked sedans; all its derived slots were checked above.
	var vehicle_body=load("res://battle/vehicles/battle_vehicle_body_service.gd")
	for vehicle in battle.vehicles.values():
		var profile=vehicle_body.profile_for_vehicle(vehicle)
		if profile.length<5. or profile.length>5.3 or not is_equal_approx(profile.width,2.1):
			problems.append("arrival body scale")
		if not vehicle_body.has_usable_pose(vehicle):problems.append("arrival pose")
	print("SIDEWALK_COVER_CHECKS ",bin_checks," problems=",problems)
	print("STOOP_WALL_CHECKS ",wall_checks," problems=",problems)
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
		view._dusk_zoom=2.5
		view._dusk_pan=Vector2(-114,-62)
		view._frame_camera()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out_dir+"/frontage_detail.png")
		for detail in [["alley_detail",1.65,Vector2(-5,-80)],["north_bins_detail",2.5,Vector2(-130,-5)],["south_bins_detail",2.5,Vector2(-165,82)],["arrival_car_detail",2.5,Vector2(100,30)]]:
			view._dusk_zoom=detail[1]
			view._dusk_pan=detail[2]
			view._frame_camera()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out_dir+"/"+str(detail[0])+".png")
		view._dusk_zoom=1.1
		view._dusk_pan=Vector2.ZERO
		view._frame_camera()
		comparing=false

func fail(reason: String) -> void:
	push_error("HAROLD_REVIEW_FAILED "+reason)
	quit(1)
