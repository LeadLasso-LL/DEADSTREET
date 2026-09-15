extends SceneTree
const Config = preload("res://gameplay/sandbox_force_config.gd")
const Maps = preload("res://gameplay/sandbox_map_catalog.gd")
const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Feedback = preload("res://gameplay/tactical_command_feedback.gd")
const Cover = preload("res://battle/geometry/battle_cover_service.gd")
var checks := 0
var failures: Array = []
var results: Array = []
var cues: Array = []
var railcar := false

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		print("FAIL ", label)

func button(at: Vector2, pressed: bool, which: int = MOUSE_BUTTON_LEFT) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.position = at
	e.button_index = which
	e.pressed = pressed
	return e

func move(at: Vector2) -> InputEventMouseMotion:
	var e := InputEventMouseMotion.new()
	e.position = at
	return e

func screen(view, at: Vector2) -> Vector2:
	return view.get_global_transform_with_canvas() * view._to_view(at)

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tools/cover_slot_picker_20260915/" + name + ("_railcar" if railcar else "") + ".png")

func run() -> void:
	railcar = "--railcar" in OS.get_cmdline_user_args()
	AudioServer.set_bus_mute(0, true)
	root.size = Vector2i(1280, 800)
	root.unfocusable = true
	root.position = Vector2i(-2000, -1200)
	await process_frame
	var scene = load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_process(false)
	var maps: Array = Maps.IDS.duplicate()
	if "--visual" in OS.get_cmdline_user_args():
		maps = ["harold", "freight_exchange"]
	if railcar: maps = ["freight_exchange"]
	for map_id in maps:
		var config = Maps.preset(map_id)
		for side in ["attacker", "defender"]:
			config[side].units = [Config.unit("rifle"), Config.unit("smg")]
			config[side].erase("vehicle_occupants")
			if config[side].has("vehicles"):
				config[side].vehicles = Config.auto_convoy(2, config[side].faction)
		await scene.start_battle(false, config)
		var b = scene.battle
		var view = scene.runtime.get_node("TacticalBattleView")
		var presentation = view.battle_presentation
		if presentation.battle == null:
			presentation.reset(b)
		presentation.stage = "ready"
		Fixture.begin_review(scene.runtime, b)
		b.tactical_paused = true
		presentation.stage = "active"
		presentation.audio_enabled = true
		await process_frame
		await process_frame
		var c = view.orders_controller
		var f = view.command_feedback_layer
		var picker = f.cover_picker
		f.set_process(false)
		var audio = view.get_node("CommandHudLayer").get_child(0).get_child(0)
		audio.set_process(false)
		audio.cue_played.connect(func(command, single): cues.append([command, single]))
		var friends: Array = b.participants.values().filter(func(p): return p.side_id == b.attacker_side_id)
		var enemy = b.participants.values().filter(func(p): return p.side_id != b.attacker_side_id)[0]
		var unit = friends[0]
		c.select_participant(unit.participant_id)
		var start: Vector2 = unit.battle_position
		var clock: float = b.elapsed_time_seconds
		# Find real clickable cover with several reachable choices. Prefer large freight.
		var ids: Array = b.battlefield_geometry.cover_objects.keys()
		ids.sort_custom(func(a,z): return view._cover_object_hit_rect(b,a).get_area() > view._cover_object_hit_rect(b,z).get_area())
		var cover_id := ""
		var press := Vector2.ZERO
		for id in ids:
			if railcar and not str(id).begins_with("cover_boxcar_"):continue
			var rect: Rect2 = view._cover_object_hit_rect(b, id)
			var point: Vector2 = view.get_global_transform_with_canvas() * rect.get_center()
			if f.pointer_is_over_ui(point) or not view.hit_test_pointer_unit(point).is_empty():continue
			if view.hit_test_cover_object(view.viewport_to_local_position(point)) != id:continue
			var options: Array = c.cover_choices(id)
			if options.size() < 2:continue
			cover_id = id
			press = point
			break
		check(not cover_id.is_empty(), map_id + " found clickable multi-slot cover")
		if cover_id.is_empty():continue
		var art = f.cover_visual(cover_id)
		f.set_hover("", "")
		var alpha: float = art.modulate.a
		var reserve_before: String = unit.reserved_cover_slot_id
		var seq: int = c.feedback_sequence
		c.handle_input(view, button(press, true))
		f._process(.1)
		check(not picker.active and c.feedback_sequence == seq, map_id + " press has not issued any order")
		c.handle_input(view, button(press, false))
		check(c.feedback_sequence == seq + 1 and unit.has_player_cover_intent(), map_id + " quick click retains automatic cover")
		var auto_slot: String = unit.player_cover_slot_id
		var options: Array = c.cover_choices(cover_id)
		var exact = options.filter(func(row): return row.slot.cover_slot_id != auto_slot)[0]
		reserve_before = unit.reserved_cover_slot_id
		seq = c.feedback_sequence
		c.handle_input(view, button(press, true))
		f._process(.26)
		check(picker.active and picker.choices.size() >= 2, map_id + " hold reveals real positions while paused")
		check(c.feedback_sequence == seq and unit.reserved_cover_slot_id == reserve_before, map_id + " browsing preserves original order and reservation")
		check(art.modulate.a < alpha and art.modulate.a > 0, map_id + " clicked artwork fades")
		var destination_screen := screen(view, exact.slot.position)
		c.handle_input(view, move(destination_screen))
		f._process(.01)
		check(not picker.chosen.is_empty() and picker.chosen.slot.cover_slot_id == exact.slot.cover_slot_id, map_id + " mouse chooses exact nonautomatic slot")
		check(f.paths.any(func(row): return row.kind == "move" and row.destination == exact.slot.position), map_id + " paused route previews candidate")
		await capture(map_id + "_choosing")
		c.handle_input(view, button(destination_screen, false))
		f._process(.01)
		check(unit.player_cover_slot_id == exact.slot.cover_slot_id, map_id + " release orders exact slot")
		check(not picker.active and picker.choices.is_empty() and not picker.confirmation.is_empty(), map_id + " only confirmed circle remains")
		check(is_equal_approx(art.modulate.a, alpha), map_id + " release restores artwork opacity")
		await capture(map_id + "_confirmed")
		picker.tick(.48)
		check(not picker.confirmation.is_empty(), map_id + " confirmed circle remains about half a second")
		picker.tick(.3)
		check(picker.confirmation.is_empty(), map_id + " confirmation fades out during pause")
		check(Feedback.describe_orders(b,c.selected_participant_ids).any(func(row): return row.destination == exact.slot.position), map_id + " command path persists after circle fades")
		check(unit.battle_position == start and b.elapsed_time_seconds == clock, map_id + " paused interaction does not simulate movement")
		seq = c.feedback_sequence
		c.handle_input(view, button(press,true))
		f._process(.26)
		c.handle_input(view, button(press,true,MOUSE_BUTTON_RIGHT))
		c.handle_input(view, button(press,false))
		check(not picker.active and c.feedback_sequence == seq and unit.player_cover_slot_id == exact.slot.cover_slot_id, map_id + " right-click cancel preserves order and selection")
		check(is_equal_approx(art.modulate.a,alpha), map_id + " cancel restores opacity")
		c.handle_input(view, button(press,true))
		f._process(.26)
		# Dispatch through global input: HUD must not swallow the owned release.
		picker._input(button(Vector2(50,790),false))
		check(not picker.active and c.feedback_sequence == seq, map_id + " HUD release cancels without world order")
		c.handle_input(view, button(press,true))
		c.handle_input(view, move(press+Vector2(20,0)))
		check(c.dragging and not picker.active and picker.cover_id.is_empty(), map_id + " early drag retains box selection")
		c.dragging = false
		# Reserve the visible candidate with another unit before release.
		c.handle_input(view, button(press,true))
		f._process(.26)
		var other_options: Array = picker.choices.filter(func(row): return row.slot.cover_slot_id != unit.player_cover_slot_id)
		if not other_options.is_empty():
			var contested = other_options[0].slot
			var at := screen(view,contested.position)
			c.handle_input(view,move(at))
			var reserved = Cover.reserve_slot(b,friends[1].participant_id,contested.cover_slot_id)
			check(reserved.success,map_id + " competing unit reserves previewed slot")
			c.handle_input(view,button(at,false))
			check(c.last_command_feedback.accepted == 0 and unit.player_cover_slot_id == exact.slot.cover_slot_id,map_id + " stale slot rejected without replacing old order")
			Cover.release_reservation(b,friends[1].participant_id)
		# Every separate input must play even if several happen before a presentation frame.
		c.command_feedback_events.clear()
		cues.clear()
		for i in range(4):c.issue_target(enemy.participant_id)
		audio._process(.01)
		check(cues.size() == 4 and cues.all(func(row):return row == ["target",true]),map_id + " four paused replacements produce four single-unit cues")
		check(audio.voices.any(func(voice):return voice.playing and is_equal_approx(voice.pitch_scale,1.08)),map_id + " single cue uses actual player and subtle pitch variation")
		cues.clear()
		c.issue_cover(cover_id)
		c.command_selected("hold")
		c.command_selected("clear")
		c.issue_move(start)
		audio._process(.01)
		check(cues.size() == 4 and cues.map(func(row):return row[0]) == ["cover","hold","clear","move"],map_id + " cover hold clear move each acknowledged")
		c.select_participant(friends[1].participant_id,true)
		cues.clear()
		c.issue_target(enemy.participant_id)
		audio._process(.01)
		check(cues == [["target",false]],map_id + " group click has one group cue")
		check(audio.voices.any(func(voice):return voice.playing and is_equal_approx(voice.pitch_scale,1.0)),map_id + " group cue preserves original pitch")
		c.select_participant(unit.participant_id)
		b.tactical_paused = false
		c.handle_input(view,button(press,true))
		f._process(.26)
		check(picker.active,map_id + " picker also works unpaused")
		var esc := InputEventKey.new()
		esc.keycode = KEY_ESCAPE
		esc.pressed = true
		c.handle_input(view,esc)
		check(not picker.active and c.is_selected(unit.participant_id),map_id + " Escape cancels picker without clearing selection")
		b.tactical_paused = true
		c.handle_input(view,button(press,true))
		f._process(.26)
		c.clear_selection()
		f._process(.01)
		check(not picker.active and is_equal_approx(art.modulate.a,alpha),map_id + " selection change cleans up picker")
		if railcar:
			c.select_participant(unit.participant_id)
			# Reordering cover while already standing in that exact slot must work.
			Cover.release_all_for_participant(b,unit.participant_id)
			unit.battle_position = exact.slot.position
			var occupy = Cover.occupy_slot(b,unit.participant_id,exact.slot.cover_slot_id)
			var repeat = c.issue_cover_slot(cover_id,exact.slot.cover_slot_id)
			check(occupy.success and repeat.success and unit.occupied_cover_slot_id == exact.slot.cover_slot_id,"already occupied exact slot can be confirmed again")
			var marker = presentation.markers[unit.participant_id]
			var badge_center: Vector2 = marker.get_global_transform_with_canvas() * marker.size * .5
			check(not picker.handle_input(button(badge_center,true)),"emblems retain priority over cover hold gesture")
			c.handle_input(view,button(press,true))
			f._process(.26)
			picker._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
			check(not picker.active and is_equal_approx(art.modulate.a,alpha),"window focus loss cancels and restores cover")
			unit.is_wounded = true
			check(not picker.handle_input(button(press,true)),"wounded unit cannot open exact-slot picker")
			unit.is_wounded = false
			c.command_feedback_events.clear()
			cues.clear()
			c.issue_cover_slot(cover_id,"missing_slot")
			audio._process(.01)
			check(cues == [["failed",true]],"rejected command uses distinct failure cue")
			cues.clear()
			presentation.audio_enabled = false
			c.issue_target(enemy.participant_id)
			audio._process(.01)
			check(cues.is_empty() and c.command_feedback_events.is_empty(),"audio toggle mutes and drains orders without delayed replay")
			for key in audio.streams:
				var wave: AudioStreamWAV = audio.streams[key]
				var peak := 0.0
				for i in range(0,wave.data.size(),2):peak = maxf(peak,absf(wave.data.decode_s16(i))/32768.0)
				check(peak > .1 and peak < 1.0,"cue contains unclipped audio: " + key)
		results.append({"map":map_id,"cover":cover_id,"choices":options.size()})
		print("MAP_DONE ",map_id," checks=",checks," failures=",failures.size())
		scene.return_to_setup()
		await process_frame
		await process_frame
	var suffix := "railcar" if railcar else ("visual" if "--visual" in OS.get_cmdline_user_args() else "native")
	var file = FileAccess.open("res://tools/cover_slot_picker_20260915/"+suffix+"_result.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"maps":results},"  "))
	print("COVER_PICKER_QA ",checks," checks; ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
