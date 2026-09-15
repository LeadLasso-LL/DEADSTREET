extends "res://tools/selected_range_20260915/check_native.gd"

func run():
	out = "C:/Users/brand/OneDrive/Documents/dead-street/tools/selected_range_groups_20260915"
	root.size = Vector2i(1440, 1000)
	DisplayServer.window_set_size(root.size)
	for map_id in ["harold", "river_bridge", "whittaker_estate"]:
		var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
		root.add_child(scene)
		await process_frame
		var config = Cases.make(12, 12, ["aegis", "vigil", "aegis"])
		config.map_id = map_id
		config.attacker.faction = "trc"
		config.defender.faction = "whittaker" if map_id == "whittaker_estate" else "orlov"
		config.defender.vehicles = ["bulwark", "interceptor", "bulwark"]
		await scene.start_battle(false, config)
		scene.set_process(false)
		var b = scene.battle
		check(b != null, map_id + " native fixture")
		var view = scene.runtime.get_node("TacticalBattleView")
		view.battle_presentation.skip_to_ready()
		check(Fixture.begin_review(scene.runtime, b).success, map_id + " starts")
		b.tactical_paused = true
		var orders = view.orders_controller
		var indicator = view.selection_range_layer
		var hud = view.get_node("CommandHudLayer").get_child(0)
		var friendly := []
		for p in b.participants.values():
			if p.side_id == b.attacker_side_id: friendly.append(p)
		await settle(.3) # Let active HUD layout/input state settle before clicking.
		for role in ["pistol", "smg", "rifle", "shotgun", "sniper"]:
			await click(hud.class_buttons[role])
			await settle()
			var expected := []
			for p in friendly:
				if p.weapon_type == role: expected.append(p.participant_id)
			print("GROUP_SELECT ", map_id, " ", role, " expected=", expected, " selected=", orders.selected_participant_ids)
			check(orders.selected_participant_ids.size() == expected.size() and expected.size() > 1, map_id + " actual class button " + role)
			check(indicator.visible and indicator.group_disc.visible and not indicator.disc.visible, map_id + " group outline mode " + role)
			check(indicator.group_ranges.size() == expected.size(), map_id + " every class unit represented " + role)
			for row in indicator.group_ranges:
				var p = b.get_participant(row.id)
				check(row.id in expected and is_equal_approx(row.radius, Weapons.for_participant(p).max_range), map_id + " actual model range " + row.id)
			root.get_texture().get_image().save_png(out + "/" + map_id + "_" + role + "_group.png")
			var state = snapshot(b)
			await settle(.2)
			check(snapshot(b) == state, map_id + " group display leaves paused combat unchanged")
			await click(hud.cards[expected[0]])
			await settle()
			check(indicator.visible and indicator.disc.visible and not indicator.group_disc.visible, map_id + " individual restored " + role)
			check(indicator.selected_id == expected[0], map_id + " correct single selected")
		# Mixed selection hides; same-class manual selection is useful too.
		orders.select_class("pistol")
		orders.select_class("rifle", true)
		await settle()
		check(not indicator.visible, map_id + " mixed classes suppressed")
		orders.select_class("pistol")
		await settle()
		var pistol_ids = orders.selected_participant_ids.duplicate()
		orders.clear_selection()
		for id in pistol_ids.slice(0, 2): orders.select_participant(id, true)
		await settle()
		check(indicator.visible and indicator.group_ranges.size() == 2, map_id + " manual same-class pair")
		var old_position = b.get_participant(pistol_ids[0]).battle_position
		b.get_participant(pistol_ids[0]).battle_position += Vector2(1, .5)
		await settle()
		check(indicator.group_ranges[0].at == b.get_participant(pistol_ids[0]).battle_position, map_id + " moving class outline follows")
		b.get_participant(pistol_ids[0]).battle_position = old_position
		var zoom = view._dusk_zoom
		view._dusk_zoom *= 1.25
		view._frame_camera()
		await settle()
		check(indicator.visible and indicator.group_ranges.size() == 2, map_id + " zoom retains group")
		view._dusk_zoom = zoom
		view._frame_camera()
		await click(hud.class_buttons[""])
		await settle()
		check(orders.selection_is_all and not indicator.visible, map_id + " Select All suppressed")
		# Selection-only fixture: homogeneous whole squad must still distinguish All/class.
		var original_classes := []
		for p in friendly:
			original_classes.append([p.weapon_type, p.weapon_model_id])
			p.weapon_type = "pistol"
			p.weapon_model_id = "glock_17"
		await click(hud.class_buttons[""])
		await settle()
		check(not indicator.visible, map_id + " homogeneous Select All remains suppressed")
		await click(hud.class_buttons["pistol"])
		await settle()
		check(indicator.visible and indicator.group_ranges.size() == 12, map_id + " full 12-unit class supported")
		for i in range(friendly.size()):
			friendly[i].weapon_type = original_classes[i][0]
			friendly[i].weapon_model_id = original_classes[i][1]
		orders.select_class("pistol")
		await settle()
		for id in orders.selected_participant_ids.duplicate().slice(1): b.get_participant(id).is_alive = false
		orders.sync_from_authority()
		await settle()
		check(indicator.visible and indicator.disc.visible and indicator.group_ranges.is_empty(), map_id + " deaths leave surviving individual mode")
		orders.clear_selection()
		await settle()
		check(not indicator.visible, map_id + " deselection clears all")
		scene.queue_free()
		await process_frame
		await process_frame
		print("GROUP_MAP_DONE ", map_id)
	await check_overlap_pixels()
	var report := {"checks": checks, "errors": errors, "engine": Engine.get_version_info().string, "maps": 3, "classes_per_map": 5, "largest_class_selection": 12}
	FileAccess.open(out + "/group_validation.json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	print("GROUP_NATIVE ", JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)

func check_overlap_pixels():
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var quad := Polygon2D.new()
	quad.polygon = PackedVector2Array([Vector2.ZERO, Vector2(256, 0), Vector2(256, 256), Vector2(0, 256)])
	var material := ShaderMaterial.new()
	material.shader = load("res://gameplay/tactical_group_range.gdshader")
	quad.material = material
	viewport.add_child(quad)
	var rings := PackedVector4Array()
	var feathers := PackedFloat32Array()
	for i in range(32):
		rings.append(Vector4(128, 128, 96, 72))
		feathers.append(.03)
	material.set_shader_parameter("rings", rings)
	material.set_shader_parameter("feathers", feathers)
	material.set_shader_parameter("range_count", 1)
	await settle()
	var one = viewport.get_texture().get_image()
	material.set_shader_parameter("range_count", 12)
	await settle()
	var twelve = viewport.get_texture().get_image()
	check(one.get_data() == twelve.get_data(), "12 coincident outlines exactly equal one in rendered pixels")
	check(one.get_pixel(128, 128).a == 0.0, "group interior has no fill")
	check(one.get_pixel(10, 10).a == 0.0, "outside group radius transparent")
	var max_alpha := 0.0
	for y in range(256):
		for x in range(256): max_alpha = maxf(max_alpha, one.get_pixel(x, y).a)
	check(max_alpha > .08 and max_alpha <= .11, "group actually visible with capped faint alpha")
	# Cross two distinct rings and compare to max of their separately rendered masks.
	rings[1].x += 35.0
	material.set_shader_parameter("rings", rings)
	material.set_shader_parameter("range_count", 2)
	await settle()
	var crossed = viewport.get_texture().get_image()
	rings[0] = rings[1]
	material.set_shader_parameter("rings", rings)
	material.set_shader_parameter("range_count", 1)
	await settle()
	var second = viewport.get_texture().get_image()
	var bad := 0
	for y in range(256):
		for x in range(256):
			if absf(crossed.get_pixel(x, y).a - maxf(one.get_pixel(x, y).a, second.get_pixel(x, y).a)) > .004: bad += 1
	check(bad == 0, "crossing outlines render maximum alpha without accumulation")
	viewport.queue_free()
