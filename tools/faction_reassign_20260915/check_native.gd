extends SceneTree
const C=preload("res://gameplay/music_catalog.gd")
const M=preload("res://gameplay/sandbox_menu_music.gd")
const P=preload("res://gameplay/faction_audio_preview.gd")
const F=preload("res://battle/identity/faction_unit_catalog.gd")
var checks=0
var errors=[]
func ck(ok:bool,msg:String):
 checks+=1
 if not ok:errors.append(msg);printerr(msg)
func _initialize():call_deferred("run")
func run():
 var settings="user://faction_reassign_test.cfg"
 var cfg=ConfigFile.new();cfg.set_value("playlist","glock_b22",true);cfg.set_value("player","volume",0.0);cfg.save(settings)
 var music=M.new();music.settings_path=settings;root.add_child(music)
 var preview=P.new();root.add_child(preview)
 music.start_signature()
 await process_frame
 ck(music.tracks.size()==20 and music.track_checks.size()==20,"20 menu rows")
 ck(not music.track_checks.has("glock_b22"),"Glock excluded even with old preference")
 for i in range(3):
  music.refill_queue()
  for id in C.catalogue().menu_excluded_tracks:ck(id not in music.queue,"excluded "+id)
 var assignments={"orlov":["hitters_b22",17.0],"union_sur":["creepin_b22",12.0],"calle_ocho":["mercy_b22",0.0]}
 for faction in assignments:
  var expected=assignments[faction]
  ck(C.catalogue().faction_tracks[faction]==expected[0],"mapping "+faction)
  var track=C.track(expected[0])
  ck(track.battle_loop.source_start_seconds==expected[1] and track.battle_loop.duration_seconds==30.0,"timestamp "+faction)
  ck(preview.source_path(faction)==track.battle_loop.file,"glossary source "+faction)
  var loop=C.faction_stream(faction)
  ck(loop!=null and loop.loop_mode==AudioStreamWAV.LOOP_FORWARD and loop.loop_begin==0 and loop.loop_end==1323000,"battle loop "+faction)
  ck(is_equal_approx(loop.get_length(),30.0),"duration "+faction)
 for faction in F.all_ids():
  ck(preview.available(faction),"available "+faction)
  ck(preview.play_faction(faction),"preview starts "+faction)
  ck(preview.player.playing and preview.current_faction==faction,"playing "+faction)
  var expected=AudioStreamWAV.load_from_file(preview.source_path(faction))
  ck(preview.player.stream.data==expected.data,"exact preview bytes "+faction)
  ck(preview.player.stream.loop_mode==AudioStreamWAV.LOOP_DISABLED,"preview one-shot "+faction)
  ck(music.preview_paused and music.player.stream_paused,"menu paused "+faction)
  preview.stop()
  ck(not music.preview_paused and not music.player.stream_paused and preview.current_faction.is_empty(),"stop/resume "+faction)
 ck(preview.source_path("trc")=="res://assets/audio/convoy/trc_siren.wav","TRC unchanged")
 ck(preview.source_path("nbpd")=="res://assets/audio/convoy/police_siren.wav","NBPD unchanged")
 var result={"passed":errors.is_empty(),"checks":checks,"errors":errors,"factions":23,"menu_tracks":20,"assignments":assignments}
 FileAccess.open("res://tools/faction_reassign_20260915/native_validation.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(settings))
 preview.queue_free();music.queue_free();await process_frame
 print("FACTION_REASSIGN ",checks," checks; ",errors.size()," failures")
 quit(0 if errors.is_empty() else 1)
