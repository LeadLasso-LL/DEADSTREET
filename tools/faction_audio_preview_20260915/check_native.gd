extends SceneTree
const OUT="res://tools/faction_audio_preview_20260915/"
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Catalog=preload("res://gameplay/music_catalog.gd")
var checks=0
var errors=[]
func _initialize():call_deferred("run")
func frames(n):
 for i in range(n):await process_frame
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);printerr("PREVIEW_FAIL ",message)
func click(control):
 var point=control.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await frames(3)
func shot(name):
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+name+".png")
func run():
 root.size=Vector2i(1280,900);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await frames(10)
 var music=load("res://gameplay/sandbox_menu_music.gd").new();music.settings_path="user://faction_preview_test.cfg";root.add_child(music);music.sandbox=scene
 music.volume.value=.012;music.start_signature();music.show_on_entry();music.entry_clock-=5;await frames(4)
 var menu=scene.menu_panels;menu.show_tab("factions");await frames(4)
 var page=menu.pages.factions;var preview=page.faction_audio
 var original_player=music.player;var original_stream=music.player.stream;var original_id=music.current_id;var plays=music.play_count
 for id in Factions.all_ids():
  page.show_faction(id);await frames(2)
  check(not page.audio_button.disabled,"audio available "+id)
  check(page.audio_button.icon==preview.icon(false),"filled play icon ready "+id)
  await click(page.audio_button)
  check(preview.player.playing and preview.current_faction==id,"actual snippet starts "+id)
  check(page.audio_button.icon==preview.icon(true) and page.audio_button.get_meta("playing"),"filled stop icon while playing "+id)
  check(music.preview_paused and music.player.stream_paused,"menu pauses for "+id)
  check(preview.player.stream.loop_mode==AudioStreamWAV.LOOP_DISABLED,"preview is one shot "+id)
  var expected=AudioStreamWAV.load_from_file(preview.source_path(id))
  check(preview.player.stream.data==expected.data,"exact assigned clip bytes "+id)
  check(is_equal_approx(preview.player.pitch_scale,.75 if id=="trc" else 1.0),"canonical preview speed "+id)
  if id=="mercer":await shot("mercer_playing")
  if id=="nbpd":await shot("nbpd_siren")
  await click(page.audio_button)
  check(not preview.player.playing and preview.current_faction.is_empty(),"stop ends snippet "+id)
  check(page.audio_button.icon==preview.icon(false) and not music.preview_paused and not music.player.stream_paused,"stop restores play icon and menu "+id)
 check(music.player==original_player and music.player.stream==original_stream and music.current_id==original_id and music.play_count==plays,"23 auditions preserve same menu song/player without restart")
 # Real pause duration and same-position resume.
 page.show_faction("calle_ocho");await frames(2);music.player.seek(12.0);await create_timer(.1).timeout
 await click(page.audio_button);var position=music.player.get_playback_position();await create_timer(.5).timeout
 check(abs(music.player.get_playback_position()-position)<.08,"menu timeline stays frozen throughout preview")
 await click(page.audio_button);await create_timer(.15).timeout
 check(music.player.get_playback_position()>=position and music.player.get_playback_position()<position+.5,"menu resumes from held position")
 # Natural end is not a restart or endless battle loop.
 await click(page.audio_button);preview.player.seek(preview.player.stream.get_length()-.12);await create_timer(.7).timeout
 check(preview.current_faction.is_empty() and page.audio_button.icon==preview.icon(false) and not music.player.stream_paused,"natural clip finish restores icon and music")
 check(Catalog.faction_stream("calle_ocho").loop_mode==AudioStreamWAV.LOOP_FORWARD,"battle loop behavior preserved")
 await click(page.audio_button);page.show_faction("orlov");await frames(3)
 check(not preview.player.playing and not music.preview_paused and page.audio_button.icon==preview.icon(false),"faction change stops previous audition")
 await click(page.audio_button);await click(menu.tabs.arsenal)
 check(not preview.player.playing and not music.preview_paused,"leaving glossary stops audition")
 menu.show_tab("factions");await frames(2);await click(page.audio_button);menu.show_tab("tutorial");await frames(4)
 check(not preview.player.playing and not music.preview_paused,"tutorial navigation releases preview")
 var tutorial=scene.get_node_or_null("SandboxTutorial")
 if tutorial!=null:tutorial.queue_free();await frames(3)
 scene.ui.show();menu.show_tab("factions");await frames(3)
 await click(page.audio_button);scene.ui.hide();await frames(3)
 check(not preview.player.playing and not music.preview_paused and music.player.stream_paused,"hidden sandbox releases preview but keeps battle menu paused")
 scene.ui.show();await frames(3);check(not music.player.stream_paused,"menu returns with music resumed")
 music.pause_music();await click(page.audio_button);await click(page.audio_button)
 check(music.user_paused and music.player.stream_paused,"prior manual pause remains respected")
 music.pause_music();await click(page.audio_button)
 music.reshuffle_tracks();await frames(3)
 check(music.player.stream_paused and music.preview_paused,"shuffle cannot overlap an active faction snippet")
 preview.stop();await frames(3);check(not music.player.stream_paused,"stop resumes newly selected menu track")
 for size in [Vector2i(1152,860),Vector2i(1280,720),Vector2i(1440,1000)]:
  root.size=size;DisplayServer.window_set_size(size);await frames(5)
  check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(page.audio_button.get_global_rect()),"audio control in viewport "+str(size))
  if page.leader_image!=null:check(not page.audio_button.get_rect().intersects(page.leader_image.get_rect()),"audio control clears photo "+str(size))
 page.show_faction("mercer");await frames(3);await shot("mercer_stopped")
 await click(page.audio_button);page.queue_free();await frames(3)
 check(not music.preview_paused and not music.player.stream_paused,"page removal releases audio focus")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(music.settings_path))
 FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors,"factions":23,"mapped_snippets":21,"authority_sirens":2,"same_song_resume":true},"  "))
 print("FACTION_PREVIEW_NATIVE ",checks," checks; ",errors.size()," failures")
 quit(0 if errors.is_empty() else 1)
