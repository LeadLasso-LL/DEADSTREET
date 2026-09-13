extends SceneTree
# Screenshot-only review for HUD spacing changes; no combat regression suite.
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
func _initialize(): call_deferred("capture")
func capture():
	root.size = Vector2i(1440, 1000)
	DisplayServer.window_set_size(root.size)
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var config = Cases.make(12, 12, ["aegis", "vigil", "aegis"])
	config.map_id = "river_bridge"
	config.defender.vehicles = ["bulwark", "interceptor", "bulwark"]
	await scene.start_battle(false, config)
	scene.set_process(false)
	var view = scene.runtime.get_node("TacticalBattleView")
	view.battle_presentation.skip_to_ready()
	await process_frame
	var result = load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime, scene.battle)
	if result == null or not result.success:
		printerr("HUD_PREVIEW_FAILED: battle setup")
		quit(1)
		return
	scene.battle.tactical_paused = true
	view.orders_controller.select_class()
	view.orders_controller.command_selected("hold")
	await create_timer(.15).timeout
	await RenderingServer.frame_post_draw
	var saved = root.get_texture().get_image().save_png("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/hud_header.png")
	print("HUD_PREVIEW_SAVED ", saved)
	scene.queue_free()
	await process_frame
	quit(0 if saved == OK else 1)
