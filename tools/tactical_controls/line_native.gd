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
func move_to(view, x: float) -> Vector2:
	var point: Vector2 = view.get_global_transform_with_canvas() * view._to_view(Vector2(x,22))
	var motion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion,true)
	await process_frame
	return point
func capture(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/"+name+".png")
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
	if b == null:quit(1);return
	var view = scene.runtime.get_node("TacticalBattleView")
	view.battle_presentation.skip_to_ready()
	await create_timer(.15).timeout
	var started = load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
	check(started != null and started.success,"native fixture begins")
	scene.ready_started = true
	scene.set_process(true)
	await create_timer(.15).timeout
	var hud = view.get_node("CommandHudLayer").get_child(0)
	var c = view.orders_controller
	view._dusk_zoom = .65
	view._dusk_pan = Vector2.ZERO
	view._frame_camera()
	await process_frame
	await click(hud.playback_buttons[0])
	check(b.tactical_paused,"paused command setup")
	await click(hud.class_buttons[""])
	await click(hud.buttons["push"])
	var point = await move_to(view,76.0)
	check(c.pending_command_id=="push" and absf(c.line_x-76.0)<.1,"mouse movement positions Push line in world space")
	check(not c.line_spans.is_empty(),"traversable line preview")
	check(root.get_visible_rect().has_point(point),"preview target is on screen")
	print("PREVIEW_POINT ",point," SPANS ",c.line_spans," ZOOM ",view._camera.zoom," WIDTH ",b.battlefield_geometry.width," HEIGHT ",b.battlefield_geometry.height)
	await create_timer(.1).timeout
	await capture("line_push_preview")
	await click_at(point)
	check(c.pending_command_id.is_empty(),"click commits line rather than selecting terrain/unit")
	check(int(c.last_command_feedback.accepted)>0,"GUI Push delivers group orders")
	var first_push = ""
	for id in hud.cards:
		var unit = b.get_participant(id)
		if unit.current_player_group_command()=="push":
			check(hud.cards[id].command_status.text=="Pushing","card has Pushing label")
			if first_push.is_empty():first_push=id
	check(not first_push.is_empty(),"native Push has labeled recipients")
	await create_timer(.65).timeout
	await capture("line_command_cards")
	check(c.confirmation.is_empty(),"line fades out while tactical time is paused")
	var order_audio
	for node in hud.get_children():
		if node.get_script()==load("res://gameplay/tactical_order_audio.gd"):order_audio=node
	await click(hud.class_buttons["rifle"])
	await click(hud.buttons["hold"])
	await create_timer(.05).timeout
	check(int(c.last_command_feedback.accepted)>0,"GUI Hold assigns directional cover")
	check(not c.hold_pulses.is_empty(),"Hold emits brief recipient pulses")
	check(order_audio!=null and order_audio.player.playing,"order receipt remains audible during tactical pause")
	for id in c.selected_participant_ids:
		if b.get_participant(id).current_player_group_command()=="hold":
			check(hud.cards[id].command_status.text=="Holding","Holding replaces previous movement label")
	await click(hud.buttons["fall_back"])
	# These paused units are already on the friendly side of this line; they must hold there.
	var retreat_x=0.0
	for id in c.selected_participant_ids:
		retreat_x=maxf(retreat_x,b.get_participant(id).battle_position.x+2.0)
	point = await move_to(view,retreat_x)
	check(c.pending_command_id=="fall_back","Fall Back preview is active")
	await capture("line_fall_back_preview")
	await click_at(point)
	check(int(c.last_command_feedback.accepted)>0,"GUI Fall Back finds friendly-side cover")
	await click(hud.buttons["push"])
	var old_feedback=c.feedback_sequence
	var escape=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true
	root.push_input(escape,true)
	await process_frame
	check(c.pending_command_id.is_empty() and c.feedback_sequence==old_feedback,"Escape cancels without issuing an order")
	await create_timer(.6).timeout
	check(c.hold_pulses.is_empty(),"Hold pulses disappear")
	for card in hud.cards.values():
		check(root.get_visible_rect().encloses(card.get_global_rect()),"all cards remain onscreen")
	var before=b.elapsed_time_seconds
	await click(hud.playback_buttons[2])
	await create_timer(2.0).timeout
	check(b.elapsed_time_seconds>before+1.5,"orders run under normal simulation")
	await click(hud.playback_buttons[0])
	await capture("line_commands_live")
	var report={"checks":checks,"errors":errors,"units":b.participants.size(),"debug":OS.has_feature("debug")}
	FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/line_native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("LINE_NATIVE ",JSON.stringify(report))
	scene.queue_free()
	await process_frame
	quit(0 if errors.is_empty() else 1)
