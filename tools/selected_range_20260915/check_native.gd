extends SceneTree
const RangeView = preload("res://gameplay/tactical_selection_range.gd")
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Participant = preload("res://battle/core/battle_participant.gd")
var errors := []
var checks := 0
var samples := []
var out := "C:/Users/brand/OneDrive/Documents/dead-street/tools/selected_range_20260915"

func _initialize(): call_deferred("run")
func check(ok, label):
	checks += 1
	if not ok:
		errors.append(label)
		printerr("RANGE_FAIL ", label)

func settle(seconds := 0.16):
	await create_timer(seconds).timeout
	await RenderingServer.frame_post_draw

func click(control):
	var point = control.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame

func snapshot(b):
	var rows := []
	for p in b.participants.values():
		rows.append([p.participant_id, p.battle_position, p.velocity, p.vitality, p.is_alive, p.target_participant_id, p.weapon_state.ammo_in_magazine if p.weapon_state != null else -1])
	return var_to_str([b.elapsed_time_seconds, rows])

func run():
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1440, 1000)
	DisplayServer.window_set_size(root.size)
	for map_id in ["harold", "river_bridge", "whittaker_estate"]:
		var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
		root.add_child(scene)
		await process_frame
		var config = Cases.make(5, 5, ["aegis", "vigil"])
		config.map_id = map_id
		config.attacker.faction = "trc"
		config.defender.faction = "whittaker" if map_id == "whittaker_estate" else "orlov"
		config.defender.vehicles = ["bulwark", "interceptor"]
		await scene.start_battle(false, config)
		scene.set_process(false)
		var b = scene.battle
		check(b != null, map_id + " native fixture")
		if b == null:
			scene.queue_free()
			await process_frame
			continue
		var view = scene.runtime.get_node("TacticalBattleView")
		var indicator = view.selection_range_layer
		check(indicator != null, map_id + " range node attached")
		view.battle_presentation.skip_to_ready()
		await process_frame
		check(not indicator.visible, map_id + " hidden during ready/intro")
		var begun = Fixture.begin_review(scene.runtime, b)
		check(begun != null and begun.success, map_id + " starts")
		b.tactical_paused = true
		var orders = view.orders_controller
		var hud = view.get_node("CommandHudLayer").get_child(0)
		orders.clear_selection()
		await settle()
		check(not indicator.visible, map_id + " no selection has no disc")
		root.get_texture().get_image().save_png(out + "/" + map_id + "_none.png")
		var by_class := {}
		for p in b.participants.values():
			if p.side_id == b.attacker_side_id: by_class[p.weapon_type] = p
		for weapon_class in ["pistol", "smg", "shotgun", "rifle", "sniper"]:
			var p = by_class[weapon_class]
			await click(hud.cards[p.participant_id])
			await settle()
			var authoritative = Weapons.for_participant(p)
			check(orders.selected_participant_ids == [p.participant_id], map_id + " HUD click selects " + weapon_class)
			check(indicator.visible and indicator.selected_id == p.participant_id, map_id + " one correct indicator " + weapon_class)
			check(is_equal_approx(indicator.radius_units, authoritative.max_range), map_id + " equipped model/tier range " + weapon_class)
			check(indicator.position.is_equal_approx(view._to_view(p.battle_position)), map_id + " grounded center " + weapon_class)
			check(indicator.projected_radii.is_equal_approx(view._to_view(Vector2.ONE * authoritative.max_range)), map_id + " projected radius " + weapon_class)
			check(indicator.disc.get_child_count() == 0 and indicator.get_child_count() == 1, map_id + " one retained quad")
			check(indicator.get_index() > view.static_composite_root.get_index() and indicator.get_index() < view.static_building_root.get_index(), map_id + " ground ordering")
			check(indicator.z_index < view.dynamic_unit_root.z_index, map_id + " below scenery/units")
			for axis in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
				var boundary = p.battle_position + axis * indicator.radius_units
				check(is_equal_approx(boundary.distance_to(p.battle_position), authoritative.max_range), map_id + " cardinal boundary " + weapon_class)
			samples.append({"map": map_id, "class": weapon_class, "model": p.weapon_model_id, "tier": p.unit_tier, "radius": indicator.radius_units, "center": str(indicator.position), "projected_radii": str(indicator.projected_radii)})
			root.get_texture().get_image().save_png(out + "/" + map_id + "_" + weapon_class + ".png")
		var pistol = by_class.pistol
		orders.select_participant(pistol.participant_id)
		await settle()
		var fixed_state = snapshot(b)
		await settle(.4)
		check(snapshot(b) == fixed_state, map_id + " paused presentation does not change combat state")
		var previous_radii = indicator.projected_radii
		var previous_zoom = view._dusk_zoom
		view._dusk_zoom = previous_zoom * 1.25
		view._frame_camera()
		await settle()
		check(indicator.projected_radii == previous_radii, map_id + " camera zoom cannot change tactical range")
		check(indicator.position == view._to_view(pistol.battle_position), map_id + " zoom retains ground anchor")
		view._dusk_zoom = previous_zoom
		view._frame_camera()
		var before_position = pistol.battle_position
		pistol.battle_position += Vector2(1, .5) # Paused test fixture only.
		await settle()
		check(indicator.position == view._to_view(pistol.battle_position), map_id + " follows unit movement")
		pistol.battle_position = before_position
		orders.select_participant(by_class.rifle.participant_id, true)
		await settle()
		check(not indicator.visible, map_id + " group selection hides disc")
		orders.select_participant(pistol.participant_id)
		pistol.is_wounded = true
		await settle()
		check(indicator.visible, map_id + " wounded inspection retains nominal weapon range")
		pistol.is_wounded = false
		pistol.is_alive = false
		await settle()
		check(not indicator.visible, map_id + " death hides stale selection")
		pistol.is_alive = true
		orders.select_participant(pistol.participant_id)
		await settle()
		view.hide()
		await settle()
		check(not indicator.visible, map_id + " hidden battle clears indicator")
		view.show()
		b.battle_phase = "resolved"
		await process_frame
		check(RangeView.describe(b, [pistol.participant_id]).is_empty(), map_id + " no results-phase range")
		# Malformed/equipment edge cases checked without changing live actors.
		check(RangeView.describe(null, []).is_empty(), "null battle safe")
		b.battle_phase = "active"
		check(RangeView.describe(b, ["missing"]).is_empty(), "missing participant safe")
		for p in b.participants.values():
			if p.side_id != b.attacker_side_id:
				check(RangeView.describe(b, [p.participant_id]).is_empty(), "enemy cannot get friendly range")
				break
		orders.clear_selection()
		await settle()
		check(not indicator.visible, map_id + " cleared selection hides disc")
		scene.queue_free()
		await process_frame
		await process_frame
		print("RANGE_MAP_DONE ", map_id)
	var report := {"checks": checks, "errors": errors, "samples": samples, "engine": Engine.get_version_info().string, "fixture_units_per_side": 5, "combat_balance_changed": false}
	FileAccess.open(out + "/native_validation.json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	print("RANGE_NATIVE ", JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
