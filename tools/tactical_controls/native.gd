extends SceneTree
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
var errors = []
var checks = 0
func check(ok, label):
	checks += 1
	if not ok:
		errors.append(label)
		printerr("CONTROLS_FAIL ", label)
func click(control: Control, shift: bool = false):
	var point = control.get_global_rect().get_center()
	await click_at(point, shift)
func click_at(point: Vector2, shift: bool = false):
	for down in [true, false]:
		var e = InputEventMouseButton.new()
		e.position = point
		e.global_position = point
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		e.shift_pressed = shift
		# Control rectangles are viewport coordinates, including project stretch.
		root.push_input(e, true)
		await process_frame
func _initialize(): call_deferred("run")
func run():
	root.size = Vector2i(1440,1000)
	DisplayServer.window_set_size(root.size)
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var config = Cases.make(12,12,["aegis","vigil","aegis"])
	config.map_id = "river_bridge"
	config.defender.vehicles = ["bulwark","interceptor","bulwark"]
	await scene.start_battle(false,config)
	scene.set_process(false)
	var b = scene.battle
	if b == null:
		printerr("CONTROLS_FAIL native fixture")
		quit(1)
		return
	var view = scene.runtime.get_node("TacticalBattleView")
	var bodies = load("res://battle/vehicles/battle_vehicle_body_service.gd")
	var profiles = load("res://battle/vehicles/battle_vehicle_physical_catalog.gd")
	var traffic = load("res://battle/geometry/river_bridge_catalog.gd")
	var exits = load("res://battle/vehicles/battle_vehicle_exit_service.gd")
	for vehicle in b.vehicles.values():
		var profile = profiles.get_profile(vehicle.vehicle_type_id)
		var footprint = traffic.traffic_bounds(vehicle.battle_position, vehicle.vehicle_type_id, vehicle.facing_direction)
		for corner in bodies.world_corners(vehicle):
			check(footprint.grow(.001).has_point(corner), "fleet body matches equivalent road vehicle")
		var cached = profiles._get_collision_profile(vehicle.vehicle_type_id)
		check(cached.length == profile.length and cached.width == profile.width, "cached collision agrees with placement body")
		for other in b.vehicles.values():
			if vehicle.battle_vehicle_id < other.battle_vehicle_id:
				check(not bodies.bodies_intersect(vehicle, other), "enlarged convoy bodies do not overlap")
	for unit in b.participants.values():
		if not unit.transport_vehicle_id.is_empty():
			var vehicle = b.get_vehicle(unit.transport_vehicle_id)
			var exit_route = exits.route(b, vehicle, unit.battle_position)
			check(not exit_route.is_empty(), "unit has route from enlarged transport")
	view.battle_presentation.skip_to_ready()
	await create_timer(.3).timeout
	var begin = load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
	check(begin != null and begin.success,"native battle starts")
	scene.ready_started = true
	scene.set_process(true)
	await create_timer(.3).timeout
	var hud = view.get_node("CommandHudLayer").get_child(0)
	var orders = view.orders_controller
	check(hud != null and orders != null,"production HUD/controller connected")
	check(hud.cards.size() == 12,"all 12 friendly cards built")
	for widget in hud.cards.values():
		check(widget.visible and root.get_visible_rect().encloses(widget.get_global_rect()),"card fully visible")
	await click(hud.playback_buttons[0])
	check(b.tactical_paused,"pause button handles real GUI input")
	var elapsed = b.elapsed_time_seconds
	await create_timer(.2).timeout
	check(b.elapsed_time_seconds == elapsed,"native simulation clock freezes")
	await click(hud.class_buttons[""])
	check(orders.selected_participant_ids.size() == 12,"Select All GUI input")
	await click(hud.buttons["hold"])
	for id in orders.selected_participant_ids:
		check(b.get_participant(id).current_player_group_command() == "hold","native hold badge")
	await process_frame
	for id in view.battle_presentation.markers:
		var marker = view.battle_presentation.markers[id]
		check(marker.selected == orders.is_selected(id), "emblem selection follows actual selected unit")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/hud_revision_full_force.png")
	var first = hud.roster[0]
	await click(hud.cards[first])
	check(orders.selected_participant_ids == [first],"card selects only clicked unit")
	await click(hud.buttons["clear"])
	check(b.get_participant(first).current_player_group_command().is_empty(),"native Clear Orders badge removed")
	await process_frame
	for id in view.battle_presentation.markers:
		check(view.battle_presentation.markers[id].selected == (id == first), "single selection clears other emblem rings")
	for toggle in hud.playback.get_children():
		if toggle is CheckButton and toggle.text == "EMBLEMS":
			await click(toggle)
			check(not view.battle_presentation.identifiers_enabled, "emblem toggle handles GUI input")
			await click(toggle)
			check(view.battle_presentation.identifiers_enabled, "emblem toggle restores identifiers")
	var p = b.get_participant(first)
	var point = Vector2.ZERO
	var target = p.battle_position
	for offset in [Vector2(0,-3),Vector2(0,3),Vector2(-4,0),Vector2(4,0),Vector2(0,-5),Vector2(0,5)]:
		var candidate = p.battle_position + offset
		var local = view._to_view(candidate)
		var screen = view.get_global_transform_with_canvas() * local
		if not root.get_visible_rect().has_point(screen) or screen.y >= hud.surface.position.y - 10:
			continue
		if not view.hit_test_cover_object(local).is_empty() or not view.hit_test_live_friendly_soldier(local).is_empty():
			continue
		var route = load("res://battle/navigation/battle_navigation_service.gd").find_path(b,p.battle_position,candidate)
		if route != null and route.success:
			point = screen
			target = candidate
			break
	check(point != Vector2.ZERO,"reachable ground click fixture")
	if point != Vector2.ZERO:
		await click_at(point)
		check(p.has_player_order_position and p.player_order_position.distance_to(target) < .1,"world click reaches correct projected destination")
	var old_pan = view._dusk_pan
	var pan = InputEventMouseMotion.new()
	pan.relative = Vector2(10,0)
	pan.position = Vector2(600,300)
	pan.button_mask = MOUSE_BUTTON_MASK_MIDDLE
	root.push_input(pan, true)
	await process_frame
	check(view._dusk_pan != old_pan,"camera remains usable during pause")
	for i in [1,2,3]:
		await click(hud.playback_buttons[i])
		check(not b.tactical_paused and b.tactical_speed == [.0,.5,1.,1.5][i],"native playback " + str(i))
	await click(hud.playback_buttons[2])
	var start = Time.get_ticks_usec()
	var frames = 0
	var sim_start = b.elapsed_time_seconds
	while Time.get_ticks_usec()-start < 5000000 and b.battle_phase == "active":
		await process_frame
		frames += 1
	var fps = frames * 1000000. / (Time.get_ticks_usec()-start)
	check(b.elapsed_time_seconds > sim_start + 3.5,"native resumed battle advances")
	await click(hud.playback_buttons[0])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/hud_revision_orders.png")
	var report = {"checks":checks,"errors":errors,"brief_smoke_fps":fps,"units":b.participants.size(),"rendered":view.actor_presenter._unit_nodes.size(),"sim_seconds":b.elapsed_time_seconds,"debug":OS.has_feature("debug")}
	FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CONTROLS_NATIVE ",JSON.stringify(report))
	scene.queue_free()
	await process_frame
	quit(0 if errors.is_empty() else 1)
