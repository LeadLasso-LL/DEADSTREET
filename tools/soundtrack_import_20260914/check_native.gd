extends SceneTree
const OUT = "res://tools/soundtrack_import_20260914/"
const Catalog = preload("res://gameplay/music_catalog.gd")
var observations = {}
var failures = []
var background_clicks = 0
var loop_finishes = 0
func _initialize(): call_deferred("run")
func frames(n):
	for i in range(n): await process_frame
func note(key: String, ok: bool):
	observations[key] = ok
	print("CHECK ",key," ",ok)
	if not ok: failures.append(key)
func click(point: Vector2):
	print("CLICK ",point)
	var m = InputEventMouseMotion.new(); m.position=point; m.global_position=point; root.push_input(m,true)
	for pressed in [true,false]:
		var e = InputEventMouseButton.new(); e.position=point; e.global_position=point; e.button_index=MOUSE_BUTTON_LEFT; e.pressed=pressed; root.push_input(e,true); await process_frame
	await create_timer(0.12).timeout
func key(code):
	for pressed in [true,false]:
		var e=InputEventKey.new();e.keycode=code;e.pressed=pressed;root.push_input(e,true);await process_frame
	await frames(2)
func run():
	root.size=Vector2i(1280,720); DisplayServer.window_set_size(root.size)
	var opening = load("res://gameplay/sandbox_opening.tscn").instantiate(); root.add_child(opening)
	await frames(5)
	var music = opening.music
	music.settings_path="user://soundtrack_native_test.cfg"
	music.enabled_tracks={"dead_street":true,"bond_ob":true};music.refill_queue();music.refresh_tracks()
	var player = music.player
	note("silent_enter_gate", opening.phase=="gate" and not player.playing and music.play_count==0)
	opening.begin(); await create_timer(0.2).timeout
	note("enter_starts_signature_once", music.current_id=="dead_street" and player.playing and music.play_count==1)
	opening.begin();note("enter_idempotent",music.play_count==1)
	player.seek(20.95); await create_timer(0.3).timeout
	note("audio_clock_reveals_title",opening.phase=="title" and opening.title.visible)
	player.seek(26.95); await create_timer(0.3).timeout
	note("audio_clock_enables_sandbox",opening.open_button.visible and not opening.open_button.disabled)
	var before = player.get_playback_position()
	opening.open_sandbox(); await frames(8)
	note("entry_keeps_player_and_position",music.player==player and music.play_count==1 and player.get_playback_position()>=before)
	note("both_tracks_visible_and_bond_next",music.track_checks.size()==2 and music.queue==["bond_ob"] and not music.skip.disabled)
	music.entry_clock-=5;await create_timer(0.25).timeout;print("DOCK ",music.dock.visible," ",music.dock.get_global_rect()," panel ",music.panel.visible);await click(music.dock.get_global_rect().get_center())
	note("dock_opens_playlist",music.panel.visible)
	await click(music.skip.get_global_rect().get_center())
	note("next_plays_bond",music.current_id=="bond_ob" and player.playing and not player.stream_paused)
	note("title_artist_and_toast_update",music.label.text=="Bond\nOB" and music.toast.visible and music.toast_label.text.contains("Bond\nOB"))
	note("signature_stays_in_shuffle",music.queue==["dead_street"])
	note("toast_does_not_cover_open_panel",not music.toast.get_global_rect().intersects(music.panel.get_global_rect()))
	player.seek(player.stream.get_length()-0.18);await create_timer(0.65).timeout
	note("actual_file_end_advances",music.current_id=="dead_street" and not music.user_paused and player.playing)
	var no_repeats=true
	for i in range(8):
		var previous=music.current_id;music.next_track();no_repeats=no_repeats and previous!=music.current_id
	note("no_immediate_repeats_eight_advances",no_repeats)
	await create_timer(0.25).timeout
	print("BEFORE_PAUSE ",music.panel.visible," ",music.toggle.get_global_rect()," paused ",music.user_paused," playing ",player.playing)
	# Preserve pause through a deliberate skip and dismissing the panel.
	await click(music.toggle.get_global_rect().get_center());note("pause_icon_works",music.user_paused and player.stream_paused and music.toggle.tooltip_text=="Play music")
	var previous=music.current_id;await click(music.skip.get_global_rect().get_center())
	note("next_while_paused_preserves_pause",music.current_id!=previous and music.user_paused and player.stream_paused)
	await click(music.toggle.get_global_rect().get_center())
	note("resume_after_skip",not music.user_paused and player.playing)
	if music.current_id!="dead_street":music.next_track()
	await click(music.track_checks["bond_ob"].get_global_rect().get_center())
	note("checkbox_excludes_bond_and_disables_next",not music.enabled_tracks["bond_ob"] and music.queue.is_empty() and music.skip.disabled)
	var plays=music.play_count
	player.seek(player.stream.get_length()-0.15);await create_timer(0.65).timeout
	note("one_enabled_song_stops_without_repeat",music.track_finished and music.user_paused and music.play_count==plays)
	music.set_track_enabled("dead_street",false);await frames(3)
	music.pause_music();note("all_unchecked_do_not_replay",music.track_finished and music.play_count==plays)
	music.set_track_enabled("bond_ob",true);await frames(3);music.pause_music();await frames(3)
	note("enable_new_song_resumes_queue",music.current_id=="bond_ob" and player.playing and not music.user_paused)
	music.volume.value=0.42;await frames(2)
	var saved = load("res://gameplay/sandbox_menu_music.gd").new();saved.settings_path=music.settings_path;root.add_child(saved)
	note("exclusions_and_volume_persist",not saved.enabled_tracks["dead_street"] and saved.enabled_tracks["bond_ob"] and is_equal_approx(saved.volume.value,0.42))
	saved.queue_free();await frames(2)
	music.set_track_enabled("dead_street",true);await frames(3)
	var sandbox=opening.sandbox
	var backdrop=Button.new();sandbox.surface.add_child(backdrop);backdrop.position=Vector2(30,40);backdrop.size=Vector2(140,38);backdrop.text="UI input check";backdrop.pressed.connect(func():background_clicks+=1)
	await frames(3);music.panel.show()
	await click(backdrop.get_global_rect().get_center())
	note("outside_dismiss_consumed",not music.panel.visible and background_clicks==0)
	backdrop.queue_free()
	plays=music.play_count;before=player.get_playback_position()
	sandbox.ui.hide();await frames(4)
	note("battle_hides_panel_and_pauses_music",not music.layer.visible and player.stream_paused)
	await create_timer(0.15).timeout;sandbox.ui.show();await frames(4)
	note("return_resumes_without_restart",not player.stream_paused and music.play_count==plays and player.get_playback_position()>=before)
	await key(KEY_M);note("m_opens_music",music.panel.visible)
	music.toggle.release_focus();await key(KEY_SPACE);note("space_pauses_in_music",music.user_paused)
	await key(KEY_SPACE);note("space_resumes_in_music",not music.user_paused)
	previous=music.current_id;await key(KEY_MEDIANEXT);note("media_next_key_advances",music.current_id!=previous)
	await key(KEY_ESCAPE);note("escape_closes_music",not music.panel.visible)
	# Native stereo WAV looping across real audio boundaries; no finished/restart callback.
	var clip=Catalog.battle_stream("bond_ob")
	note("battle_stream_exact_30_seconds",clip!=null and is_equal_approx(clip.get_length(),30.0))
	note("stereo_loop_counts_frames",clip.stereo and clip.loop_begin==0 and clip.loop_end==1323000 and clip.loop_mode==AudioStreamWAV.LOOP_FORWARD)
	note("faction_assignment_not_invented",Catalog.catalogue().faction_tracks.is_empty() and Catalog.faction_stream("mercer")==null)
	var battle=AudioStreamPlayer.new();root.add_child(battle);battle.stream=clip;battle.volume_db=-60;battle.finished.connect(func():loop_finishes+=1);battle.play()
	var wraps=[]
	for i in range(3):
		battle.seek(29.8);await create_timer(0.55).timeout
		wraps.append(battle.playing and battle.get_playback_position()<2.0 and loop_finishes==0)
	note("three_real_loop_wraps_without_stop",wraps==[true,true,true]);battle.queue_free()
	# Review frame and viewport boundary check.
	if music.current_id!="bond_ob":music.next_track()
	music.user_paused=false;music.update_transport_button();music.volume.value=db_to_linear(-4.0)
	music.entry_clock-=5;music.panel.show();await frames(5)
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"playlist.png")
	root.size=Vector2i(1152,860);DisplayServer.window_set_size(root.size);await frames(6)
	note("scaled_panel_fits_viewport",Rect2(Vector2.ZERO,Vector2(root.size)).encloses(music.panel.get_global_rect()))
	await click(Vector2(40,100));note("scaled_outside_dismiss",not music.panel.visible)
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"observations":observations,"failures":failures,"loop_wraps":wraps,"live_player_count":music.play_count,"entry_clock_test":"Seek near actual 21s and 27s audio cues; no full cinematic replay claimed."},"  "))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(music.settings_path))
	print("SOUNDTRACK_NATIVE ",observations.size()," checks; failures=",failures)
	quit(0 if failures.is_empty() else 1)
