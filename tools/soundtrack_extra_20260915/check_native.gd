extends SceneTree
const OUT="res://tools/soundtrack_extra_20260915/"
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
func run():
	root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(OUT+"manifest.json"))
	var sandbox=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(sandbox)
	var music=load("res://gameplay/sandbox_menu_music.gd").new()
	music.settings_path="user://soundtrack_extra_native_test.cfg";music.sandbox=sandbox;root.add_child(music)
	music.player.volume_db=-60;music.start_signature();music.show_on_entry();await frames(5)
	note("twenty_two_tracks_and_checkboxes",music.tracks.size()==22 and music.track_checks.size()==22)
	note("signature_preserved",music.current_id=="dead_street" and music.play_count==1)
	music.entry_clock-=5;music.panel.show();await frames(5)
	var scroll=music.queue_box.get_parent()
	note("playlist_scrolls_with_fixed_panel",scroll is ScrollContainer and scroll.get_v_scroll_bar().max_value>scroll.size.y and music.panel.size.y<500)
	var battle=AudioStreamPlayer.new();root.add_child(battle);battle.volume_db=-60;battle.finished.connect(func():loop_finishes+=1)
	for item in manifest.tracks:
		var id=str(item.id);var t=Catalog.track(id);var full=Catalog.menu_stream(id)
		note(id+"_metadata",t.title==item.title and t.artist=="B-22" and t.battle_loop.source_start_seconds==item.start_seconds)
		note(id+"_full_menu_stream",full!=null and full.get_length()>=item.start_seconds+30)
		note(id+"_checkbox_title",music.track_checks[id].text.contains(str(item.title)) and music.enabled_tracks[id])
		music.queue.erase(id);music.queue.push_front(id);music.refresh_tracks();music.next_track();await frames(3)
		note(id+"_next_playback",music.current_id==id and music.player.playing and music.label.text==str(item.title)+"\nB-22")
		var clip=Catalog.battle_stream(id)
		note(id+"_exact_loop",clip!=null and clip.stereo and is_equal_approx(clip.get_length(),30.0) and clip.loop_end==1323000 and clip.loop_mode==AudioStreamWAV.LOOP_FORWARD)
		battle.stream=clip;battle.play(29.85);await create_timer(.38).timeout
		note(id+"_native_wrap",battle.playing and battle.get_playback_position()<2.0 and loop_finishes==0)
		battle.stop()
	var expected=music.queue[0]
	music.player.seek(music.player.stream.get_length()-.16);await create_timer(.6).timeout
	note("actual_end_advances_queue",music.current_id==expected and music.player.playing)
	var last=music.queue_box.get_child(music.queue_box.get_child_count()-1);scroll.ensure_control_visible(last);await frames(5)
	note("last_row_reachable",scroll.get_global_rect().has_point(last.get_global_rect().get_center()))
	var count=0
	for t in Catalog.tracks():
		if t.has("battle_loop"):count+=1
	note("twenty_one_registered_loops",count==21)
	note("faction_mapping_unchanged",Catalog.catalogue().faction_tracks.is_empty())
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"songs":22,"loops":count,"validation_limit":"Focused new-track playback, actual file-end advance and one native wrap per new loop. No subjective listening approval or faction assignment."},"  "))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(music.settings_path))
	battle.queue_free()
	print("EXTRA_NATIVE ",checks.size()," checks; failures=",failures)
	quit(0 if failures.is_empty() else 1)
