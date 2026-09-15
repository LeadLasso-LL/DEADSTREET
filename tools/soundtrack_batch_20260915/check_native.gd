extends SceneTree
const OUT="res://tools/soundtrack_batch_20260915/"
const Catalog=preload("res://gameplay/music_catalog.gd")
var checks={}
var failures=[]
var loop_finishes=0
func _initialize():call_deferred("run")
func frames(n):
	for i in range(n):await process_frame
func note(id: String,ok: bool):
	checks[id]=ok
	if not ok:failures.append(id)
func click(point: Vector2):
	var m=InputEventMouseMotion.new();m.position=point;m.global_position=point;root.push_input(m,true)
	for pressed in [true,false]:
		var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;root.push_input(e,true);await process_frame
	await create_timer(.12).timeout
func run():
	root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(OUT+"manifest.json"))
	var opening=load("res://gameplay/sandbox_opening.tscn").instantiate();root.add_child(opening);await frames(5)
	var music=opening.music;music.settings_path="user://soundtrack_batch_native_test.cfg"
	for t in music.tracks:music.enabled_tracks[str(t.id)]=true
	music.refill_queue();music.refresh_tracks();music.player.volume_db=-60
	note("nineteen_songs_eighteen_upcoming",music.tracks.size()==19 and music.queue.size()==18 and music.track_checks.size()==19)
	note("silent_enter_gate",not music.player.playing and opening.phase=="gate")
	opening.begin();await create_timer(.2).timeout;music.player.seek(26.95);await create_timer(.4).timeout
	note("signature_and_opening_cues_preserved",music.current_id=="dead_street" and music.play_count==1 and opening.title.visible and opening.open_button.visible)
	var pos=music.player.get_playback_position();opening.open_sandbox();await frames(5)
	note("entry_keeps_signature_position",music.play_count==1 and music.player.get_playback_position()>=pos)
	music.entry_clock-=5;await create_timer(.2).timeout;await click(music.dock.get_global_rect().get_center())
	note("dock_opens_expanded_playlist",music.panel.visible)
	var scroll=music.queue_box.get_parent()
	note("playlist_scrolls_with_fixed_panel",scroll is ScrollContainer and scroll.get_v_scroll_bar().max_value>scroll.size.y and music.panel.size.y<500)
	var exact_titles=true
	for item in manifest.tracks:
		var t=Catalog.track(str(item.id));var s=Catalog.menu_stream(str(item.id))
		note(str(item.id)+"_metadata",t.title==item.title and t.artist==item.artist and t.battle_loop.source_start_seconds==item.start_seconds)
		note(str(item.id)+"_full_menu_stream",s!=null and s.get_length()>=item.start_seconds+30)
		exact_titles=exact_titles and music.track_checks[str(item.id)].text.contains(str(item.title))
	note("all_supplied_titles_in_ui",exact_titles)
	# Walk an entire shuffle round using actual Next callbacks; no song repeated in the round.
	var seen=[music.current_id];var order=[];var unique=true;var labels=true
	for i in range(18):
		var expected=music.queue[0];music.next_track();await frames(2)
		unique=unique and music.current_id not in seen;seen.append(music.current_id);order.append(music.current_id)
		labels=labels and music.current_id==expected and music.label.text==str(Catalog.track(expected).title)+"\n"+str(Catalog.track(expected).artist)
	note("one_round_covers_all_nineteen_without_repeat",unique and seen.size()==19)
	note("visible_queue_matches_played_order",labels)
	var expected_next=music.queue[0]
	music.player.seek(music.player.stream.get_length()-.16);await create_timer(.6).timeout
	note("actual_end_advances_expanded_queue",music.current_id==expected_next and music.player.playing and not music.user_paused)
	# Reach the last row through the scroll viewport and toggle it with real pointer input.
	var last=music.queue_box.get_child(music.queue_box.get_child_count()-1)
	var last_id=str(last.name).trim_prefix("Track_")
	scroll.ensure_control_visible(last);await create_timer(.2).timeout
	note("last_track_reachable_by_scrolling",scroll.get_global_rect().has_point(last.get_global_rect().get_center()))
	await click(last.get_global_rect().get_center())
	note("last_track_checkbox_excludes",not music.enabled_tracks[last_id] and last_id not in music.queue)
	var reloaded=load("res://gameplay/sandbox_menu_music.gd").new();reloaded.settings_path=music.settings_path;root.add_child(reloaded)
	note("batch_exclusion_persists",not reloaded.enabled_tracks[last_id] and reloaded.track_checks.size()==19)
	reloaded.queue_free();music.set_track_enabled(last_id,true);await frames(4)
	# While the toast is visible, transport buttons remain visible and clickable.
	music.show_track_toast();await frames(3)
	note("toast_clear_of_panel",not music.toast.get_global_rect().intersects(music.panel.get_global_rect()))
	await click(music.toggle.get_global_rect().get_center());note("pause_click_with_toast",music.user_paused and music.player.stream_paused)
	await click(music.skip.get_global_rect().get_center());note("skip_preserves_pause",music.user_paused and music.player.stream_paused)
	await click(music.toggle.get_global_rect().get_center());note("resume_click",not music.user_paused)
	opening.sandbox.ui.hide();await frames(3);note("battle_pauses_menu_music",music.player.stream_paused and not music.layer.visible)
	opening.sandbox.ui.show();await frames(3);note("return_resumes_menu_music",not music.player.stream_paused)
	var battle=AudioStreamPlayer.new();root.add_child(battle);battle.volume_db=-60;battle.finished.connect(func():loop_finishes+=1)
	var loop_count=0
	for t in Catalog.tracks():
		if not t.has("battle_loop"):continue
		var clip=Catalog.battle_stream(str(t.id))
		note(str(t.id)+"_loop_frames",clip!=null and clip.stereo and is_equal_approx(clip.get_length(),30.0) and clip.loop_end==1323000 and clip.loop_mode==AudioStreamWAV.LOOP_FORWARD)
		battle.stream=clip;battle.play(29.85);await create_timer(.38).timeout
		note(str(t.id)+"_native_wrap",battle.playing and battle.get_playback_position()<2.0 and loop_finishes==0)
		battle.stop();loop_count+=1
	battle.queue_free();note("eighteen_native_loops_checked",loop_count==18)
	note("faction_assignments_preserved",Catalog.catalogue().faction_tracks.is_empty())
	music.entry_clock-=5;scroll.scroll_vertical=0;music.panel.show();await frames(5)
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"playlist_top.png")
	last=music.queue_box.get_child(music.queue_box.get_child_count()-1);scroll.ensure_control_visible(last);await frames(5)
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+"playlist_bottom.png")
	root.size=Vector2i(1152,860);DisplayServer.window_set_size(root.size);await frames(6)
	note("scaled_panel_fits",Rect2(Vector2.ZERO,Vector2(root.size)).encloses(music.panel.get_global_rect()))
	await click(Vector2(35,85));note("scaled_outside_closes",not music.panel.visible)
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"songs":19,"loops":loop_count,"shuffle_round":order,"validation_limit":"Seek-assisted opening/end cues and one real wrap per loop, not full cinematic/battle or subjective listening review."},"  "))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(music.settings_path))
	print("BATCH_NATIVE ",checks.size()," checks; failures=",failures)
	quit(0 if failures.is_empty() else 1)
