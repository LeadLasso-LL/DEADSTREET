extends "res://tools/selected_range_20260915/check_native.gd"
const H = preload("res://battle/geometry/harold_street_catalog.gd")
const Body = preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Exit = preload("res://battle/vehicles/battle_vehicle_exit_service.gd")

func run():
	out = "res://tools/harold_scale_20260915/"
	var phase = "before" if "--before" in OS.get_cmdline_user_args() else "after"
	var screenshot_only = "--screenshot" in OS.get_cmdline_user_args()
	root.size = Vector2i(1440, 1000)
	DisplayServer.window_set_size(root.size)
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var config = Cases.make(12, 12, ["aegis", "vigil", "aegis"])
	if screenshot_only: config = Cases.make(12,12,["taiga","bayou","outlander"])
	config.map_id = "harold"
	config.attacker.faction = "orlov"
	config.defender.faction = "mercer"
	await scene.start_battle(false, config)
	scene.set_process(false)
	var b = scene.battle
	check(b != null, "native Harold fixture")
	var view = scene.runtime.get_node("TacticalBattleView")
	if phase == "after" and not screenshot_only:
		# Sandbox setup commits both sides automatically. Reopen the whole
		# isolated deployment so no defender retains a slot on a moving car.
		for side in [b.attacker_side_id,b.defender_side_id]:
			b.get_side(side).deployment_committed=false
			b.get_deployment_zone(b.get_side(side).deployment_zone_id).deployed_participant_ids.clear()
		for p in b.participants.values():
			preload("res://battle/geometry/battle_cover_service.gd").release_all_for_participant(b,p.participant_id)
			p.clear_pending_deployment_cover();p.clear_player_tactical_intent()
			p.has_battle_position=false;p.deployment_slot_id=""
		for choice in ["close", "medium", "far"]:
			check(preload("res://battle/vehicles/battle_arrival_service.gd").choose(b, choice), "arrival option " + choice)
			for v in b.vehicles.values():
				if v.side_id != b.attacker_side_id: continue
				var corners = Body.world_corners(v)
				check(corners.size() == 4, "placed convoy body " + choice + v.battle_vehicle_id)
				for corner in corners: check(Rect2(0,23,64,20).has_point(corner), "convoy inside street " + choice)
				for row in H.props():
					check(Geometry2D.intersect_polygons(corners,H.rect_points(row[1])).is_empty(), "convoy clear " + choice + row[0])
		check(scene.runtime.tactical_deployment_controller.place_unplaced_in_cover(), "all attackers auto-cover after arrival choices")
		check(b.commit_side_deployment(b.attacker_side_id), "recommit isolated arrival fixture")
		check(preload("res://battle/ai/battle_deployment_ai_service.gd").apply_and_commit_side(b,b.defender_side_id,b.attacker_side_id).success,"defenders deploy after final arrival choice")
		var nav = preload("res://battle/navigation/battle_navigation_service.gd")
		for slot in b.battlefield_geometry.cover_slots.values():
			check(nav.is_reachable(b, Vector2(25,20), slot.position), "reachable cover " + slot.cover_slot_id)
		for point in [Vector2(25,15.2),Vector2(51,15.2),Vector2(36,12),Vector2(5,46),Vector2(59,46)]:
			check(nav.is_reachable(b,Vector2(25,20),point), "entrance/alley/sidewalk access " + str(point))
	view.battle_presentation.skip_to_ready()
	check(Fixture.begin_review(scene.runtime, b).success, "battle starts")
	b.tactical_paused = true
	await settle(.5)
	if screenshot_only:
		root.get_texture().get_image().save_png(out + "DEAD_STREET_Harold_Updated.png")
		quit();return
	root.get_texture().get_image().save_png(out + phase + "_ready.png")
	var car_count = 0
	for row in H.props():
		if row[2] != "car": continue
		car_count += 1
		var rect: Rect2 = row[1]
		for other in H.props():
			if other[0] != row[0]: check(not rect.intersects(other[1]), "car clear " + row[0] + "/" + other[0])
		if phase == "after":
			check(Rect2(0, 23, 64, 20).encloses(rect), "car inside asphalt " + row[0])
			var model = H.VehicleModels.model(row[4])
			check(rect.size.is_equal_approx(Vector2(model.length,model.width)*H.VehicleModels.TACTICAL_SCALE), "canonical model footprint " + row[0])
	check(car_count == 12, "all twelve parked cars retained")
	if phase == "after":
		var rendered = 0
		for node in view.dynamic_unit_root.get_children():
			if not node.has_node("ParkedArsenalVehicle"): continue
			rendered += 1
			var car = node.get_node("ParkedArsenalVehicle")
			check(car.model_id == node.prop[4], "canonical model renderer " + str(node.prop[0]))
			check(node.position.is_equal_approx(node.prop[1].get_center()*Vector2(8,6)), "physical ground anchor " + str(node.prop[0]))
			check(H.VehicleModels.sprite(car.model_id,car.facing,0.) != null, "canonical sprite loads " + car.model_id)
		check(rendered == 12, "all parked cars use Arsenal artwork")
	var exits = 0
	for p in b.participants.values():
		check(p.has_battle_position, "unit placed " + p.participant_id)
		if p.side_id == b.attacker_side_id:
			var v = b.get_vehicle(p.transport_vehicle_id)
			check(v != null and v.has_battle_position, "correct transport " + p.participant_id)
			if v != null:
				var route = Exit.route(b, v, p.battle_position, bool(p.get_meta("transport_bed", false)))
				check(not route.is_empty(), "usable disembark route " + p.participant_id)
				if not route.is_empty(): exits += 1
	var frame_ms := []
	var advance_ms := []
	b.tactical_paused = false
	var elapsed = 0.
	var previous = Time.get_ticks_usec()
	while elapsed < 20. and b.battle_phase == "active":
		await process_frame
		var now = Time.get_ticks_usec()
		var delta = minf(float(now - previous) / 1000000., .1)
		frame_ms.append(float(now - previous) / 1000.)
		previous = now
		var start = Time.get_ticks_usec()
		preload("res://battle/runtime/battle_runtime_service.gd").advance(b, delta)
		advance_ms.append(float(Time.get_ticks_usec() - start) / 1000.)
		elapsed += delta
	b.tactical_paused = true
	await settle(.2)
	root.get_texture().get_image().save_png(out + phase + "_combat.png")
	frame_ms.sort(); advance_ms.sort()
	var report = {"phase":phase,"checks":checks,"errors":errors,"disembark_routes":exits,"seconds":elapsed,"frames":frame_ms.size(),"frame_ms_median":frame_ms[frame_ms.size()/2],"frame_ms_p95":frame_ms[int(frame_ms.size()*.95)],"advance_ms_median":advance_ms[advance_ms.size()/2],"advance_ms_p95":advance_ms[int(advance_ms.size()*.95)],"battle_phase":b.battle_phase}
	FileAccess.open(out + phase + "_report.json", FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HAROLD_REPORT ", JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
