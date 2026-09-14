extends SceneTree
const OUT="C:/Users/brand/OneDrive/Documents/dead-street/tools/music_controls_20260914/"
var observations={}
var failures=[]
var background_clicks=0
func _initialize():call_deferred("run")
func frames(n):
	for i in range(n):await process_frame
func click(point: Vector2):
	var m=InputEventMouseMotion.new();m.position=point;m.global_position=point;root.push_input(m,true)
	for pressed in [true,false]:
		var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;root.push_input(e,true);await process_frame
	await frames(3)
func note(key: String,ok: bool):
	observations[key]=ok
	if not ok:failures.append(key)
func run():
	root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
	var sandbox=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(sandbox)
	var music=load("res://gameplay/sandbox_menu_music.gd").new();music.sandbox=sandbox;root.add_child(music)
	music.start_signature();music.show_on_entry();music.entry_clock-=5;await frames(10)
	var backdrop=Button.new();sandbox.surface.add_child(backdrop);backdrop.position=Vector2(30,40);backdrop.size=Vector2(140,38);backdrop.text="UI input check";backdrop.pressed.connect(func():background_clicks+=1)
	await click(music.dock.get_global_rect().get_center());note("dock_opens_panel",music.panel.visible)
	var play_count=music.play_count;var before=music.player.get_playback_position()
	await click(music.label.get_global_rect().get_center());note("inside_click_keeps_panel_open",music.panel.visible)
	await click(backdrop.get_global_rect().get_center());note("outside_click_closes",not music.panel.visible);note("dismiss_does_not_activate_background",background_clicks==0)
	note("dismiss_keeps_music_running",not music.player.stream_paused and music.play_count==play_count and music.player.get_playback_position()>=before)
	await click(music.dock.get_global_rect().get_center());note("dock_reopens_once",music.panel.visible)
	var pause_icon=music.toggle.icon
	note("pause_icon_replaces_text",pause_icon!=null and music.toggle.text.is_empty() and music.toggle.tooltip_text=="Pause music")
	var skip=music.panel.find_child("NextTrack",true,false)
	note("next_icon_and_single_track_disabled",skip!=null and skip.icon!=null and skip.text.is_empty() and skip.disabled)
	await click(music.toggle.get_global_rect().get_center());note("icon_button_pauses",music.player.stream_paused and music.user_paused)
	note("paused_button_shows_play",music.toggle.icon!=pause_icon and music.toggle.tooltip_text=="Play music")
	await click(music.dock.get_global_rect().get_center());note("dock_closes_without_reopening",not music.panel.visible)
	await click(music.dock.get_global_rect().get_center());note("reopen_preserves_pause",music.user_paused and music.panel.visible)
	await click(music.toggle.get_global_rect().get_center());note("icon_button_resumes_same_track",not music.player.stream_paused and music.play_count==play_count)
	var old_volume=music.volume.value
	await click(music.volume.get_global_rect().position+music.volume.get_global_rect().size*Vector2(.25,.5))
	note("inside_volume_stays_open",music.panel.visible and music.volume.value!=old_volume)
	music.volume.value=old_volume
	backdrop.queue_free();await frames(3)
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"music_controls.png")
	root.size=Vector2i(1152,860);DisplayServer.window_set_size(root.size);await frames(6)
	await click(Vector2(50,100));note("outside_dismiss_scaled_viewport",not music.panel.visible)
	FileAccess.open(OUT+"native_observations.json",FileAccess.WRITE).store_string(JSON.stringify({"observations":observations,"failures":failures,"audio_play_count":music.play_count},"  "))
	print("MUSIC_CONTROLS ",JSON.stringify(observations)," FAILURES ",failures)
	quit(0 if failures.is_empty() else 1)
