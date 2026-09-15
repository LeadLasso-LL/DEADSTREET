extends SceneTree
const Config = preload("res://gameplay/sandbox_force_config.gd")
const Maps = preload("res://gameplay/sandbox_map_catalog.gd")
const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Feedback = preload("res://gameplay/tactical_command_feedback.gd")
var checks := 0
var failures: Array = []
var results: Array = []
var output := "res://tools/command_feedback_20260915/native_result.json"

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		print("FAIL ", label)

func center(badge: Control) -> Vector2:
	return badge.get_global_transform_with_canvas() * (badge.size * 0.5)

func run() -> void:
	AudioServer.set_bus_mute(0, true)
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	for map_id in ["harold"]:
		var config = Maps.preset(map_id)
		for side in ["attacker", "defender"]:
			config[side].units = [Config.unit("rifle"), Config.unit("smg")]
			config[side].erase("vehicle_occupants")
			if config[side].has("vehicles"):
				config[side].vehicles = Config.auto_convoy(2, config[side].faction)
		await scene.start_battle(false, config)
		check(scene.battle != null, map_id + " battle launch")
		if scene.battle == null:
			continue
		var battle = scene.battle
		var view = scene.runtime.get_node("TacticalBattleView")
		var presentation = view.battle_presentation
		if presentation.battle == null:
			presentation.reset(battle)
		presentation.stage = "ready"
		var begun = Fixture.begin_review(scene.runtime, battle)
		check(begun != null and begun.success, map_id + " begin active battle")
		battle.tactical_paused = true
		presentation.stage = "active"
		await process_frame
		await process_frame
		var controller = view.orders_controller
		var feedback = view.command_feedback_layer
		check(controller != null and feedback != null, map_id + " feedback bound")
		if controller == null or feedback == null:
			quit(2)
			return
		var friends: Array = []
		var enemies: Array = []
		for p in battle.participants.values():
			if p.side_id == battle.attacker_side_id:
				friends.append(p)
			else:
				enemies.append(p)
		var unit = friends[0]
		var enemy = enemies[0]
		var start: Vector2 = unit.battle_position
		var initial_clock: float = battle.elapsed_time_seconds
		var badge = presentation.markers[unit.participant_id]
		var enemy_badge = presentation.markers[enemy.participant_id]
		var screen := center(badge)
		print("DISPLAY ", {"viewport":view.get_viewport_rect(),"root":root.size,"view_visible":view.is_visible_in_tree(),"feedback_visible":feedback.visible,"badge_visible":badge.is_visible_in_tree(),"badge_center":screen,"pick":feedback.pick_unit(screen),"want":unit.participant_id,"over_ui":feedback.pointer_is_over_ui(screen),"markers":presentation.markers.keys(),"hud_visible":view.get_node("CommandHudLayer").get_child(0).visible,"hud_rect":view.get_node("CommandHudLayer").get_child(0).surface.get_global_rect(),"stage":presentation.stage,"battle":battle.battle_phase})
		for id in presentation.markers:print("BADGE ",id," ",presentation.markers[id].is_visible_in_tree()," ",center(presentation.markers[id]))

		check(feedback.pick_unit(screen) == unit.participant_id, map_id + " friendly emblem is clickable")
		controller.click_world(view, screen)
		check(controller.is_selected(unit.participant_id), map_id + " emblem selects its unit")
		var old_pos: Vector2 = enemy_badge.position
		var old_badge_visible: bool = badge.visible
		badge.visible = false
		var body = view.actor_presenter._unit_nodes[unit.participant_id].get_node("body")
		var overlap: Vector2 = body.get_global_transform_with_canvas() * Vector2(0, -15)
		enemy_badge.position = enemy_badge.get_parent().get_global_transform_with_canvas().affine_inverse() * overlap - enemy_badge.size * enemy_badge.scale * 0.5
		enemy_badge.visible = true
		check(feedback.pick_unit(center(enemy_badge)) == enemy.participant_id, map_id + " hostile emblem outranks friendly body")
		controller.click_world(view, center(enemy_badge))
		check(unit.player_priority_target_id == enemy.participant_id, map_id + " click hostile sets priority while paused")
		check(controller.is_selected(unit.participant_id), map_id + " target click preserves selection")
		var rows = Feedback.describe_orders(battle, controller.selected_participant_ids)
		check(rows.any(func(row): return row.kind == "target" and row.destination == enemy.battle_position), map_id + " target line exists immediately before unpause")
		enemy_badge.position = old_pos
		badge.visible = old_badge_visible
		feedback.set_hover(enemy.participant_id, "")
		var enemy_body = view.actor_presenter._unit_nodes[enemy.participant_id].get_node("body")
		check(enemy_body.material.get_shader_parameter("hover_amount") == 1.0 and enemy_badge.hovered, map_id + " hostile body and badge brighten")
		feedback.set_hover("", "")
		check(enemy_body.material.get_shader_parameter("hover_amount") == 0.0 and not enemy_badge.hovered, map_id + " hover clears")
		var moved := false
		for offset in [Vector2(3, 0), Vector2(0, 3), Vector2(-3, 0), Vector2(0, -3)]:
			var move = controller.issue_move(start + offset)
			if move != null and move.success:
				moved = true
				break
		check(moved, map_id + " accepted paused move")
		rows = Feedback.describe_orders(battle, controller.selected_participant_ids)
		check(rows.any(func(row): return row.kind == "move" and row.destination == unit.navigation_destination and row.points.size() > 1), map_id + " yellow route exists immediately while paused")
		check(unit.battle_position == start and battle.elapsed_time_seconds == initial_clock, map_id + " preview does not advance paused simulation")
		var covered := false
		var cover_ids: Array = battle.battlefield_geometry.cover_objects.keys()
		cover_ids.sort_custom(func(a, b): return view._cover_object_hit_rect(battle, a).get_center().distance_squared_to(view._to_view(start)) < view._cover_object_hit_rect(battle, b).get_center().distance_squared_to(view._to_view(start)))
		var chosen_cover := ""
		for id in cover_ids:
			var order = controller.issue_cover(id)
			if order != null and order.success:
				chosen_cover = id
				covered = true
				break
		check(covered, map_id + " accepted paused cover")
		rows = Feedback.describe_orders(battle, controller.selected_participant_ids)
		var slot = battle.battlefield_geometry.get_cover_slot(unit.player_cover_slot_id)
		check(slot != null and rows.any(func(row): return row.kind == "move" and row.destination == slot.position), map_id + " cover route reaches assigned slot immediately")
		var missing: Array = []
		for id in cover_ids:
			var cover = battle.battlefield_geometry.get_cover_object(id)
			if not cover.slot_ids.is_empty() and feedback.cover_visual(id) == null:
				missing.append(id)
		check(missing.is_empty(), map_id + " all playable cover has artwork highlight: " + str(missing))
		if not chosen_cover.is_empty():
			var art = feedback.cover_visual(chosen_cover)
			if art != null:
				var old_tint: Color = art.modulate
				feedback.set_hover("", chosen_cover)
				check(art.modulate.r > old_tint.r and art.modulate.a == old_tint.a, map_id + " cover brightens without changing shape/alpha")
				feedback.set_hover("", "")
				check(art.modulate == old_tint, map_id + " cover highlight restores")
		controller.selected_participant_ids.append(friends[1].participant_id)
		controller.issue_target(enemy.participant_id)
		rows = Feedback.describe_orders(battle, controller.selected_participant_ids)
		check(rows.filter(func(row): return row.kind == "target").size() == 2, map_id + " group target shows each selected unit")
		enemy.is_alive = false
		check(not Feedback.describe_orders(battle, controller.selected_participant_ids).any(func(row): return row.kind == "target"), map_id + " dead target has no stale line")
		enemy.is_alive = true
		controller.command_selected("clear")
		check(Feedback.describe_orders(battle, controller.selected_participant_ids).is_empty(), map_id + " Clear removes order paths")
		controller.clear_selection()
		check(Feedback.describe_orders(battle, controller.selected_participant_ids).is_empty(), map_id + " deselection hides paths")
		check(feedback.pick_unit(Vector2(50, root.size.y - 20)).is_empty(), map_id + " HUD blocks world picking")
		results.append({"map": map_id, "cover_count": cover_ids.size(), "missing_cover_art": missing, "paused": battle.tactical_paused})
		print("MAP_DONE ", map_id, " checks=", checks, " failures=", failures.size())
		scene.return_to_setup()
		await process_frame
		await process_frame
	var file = FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks": checks, "failures": failures, "maps": results}, "  "))
	print("FEEDBACK_QA ", checks, " checks; ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
