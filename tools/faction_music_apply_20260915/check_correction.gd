extends SceneTree
const OUT="res://tools/faction_music_apply_20260915/"
const Music=preload("res://gameplay/music_catalog.gd")
const Convoy=preload("res://gameplay/tactical_convoy_audio.gd")
var checks={}
func _initialize():call_deferred("run")
func run():
	AudioServer.set_bus_volume_db(0,-65)
	var catalog=Music.catalogue();var ids={}
	for id in catalog.faction_tracks.values():ids[id]=true
	checks["calle_ocho_glock"]=catalog.faction_tracks.calle_ocho=="glock_b22"
	checks["union_sur_burn"]=catalog.faction_tracks.union_sur=="burn_b22"
	checks["21_distinct_assignments"]=ids.size()==21 and catalog.faction_tracks.size()==21
	checks["authorities_excluded"]=Music.faction_stream("trc")==null and Music.faction_stream("nbpd")==null
	var view=Node2D.new();root.add_child(view)
	var listener=AudioListener2D.new();view.add_child(listener);listener.make_current()
	var radio=Convoy.new();radio.setup(view)
	var b={"defender_side_id":"defender","battlefield_geometry":{"authored_layout_id":"harold_street_v1"},"participants":{}}
	var expected=Music.battle_stream("glock_b22")
	for side in ["attacker","defender"]:
		radio.add_faction_radio(b,side,"calle_ocho",[{"battle_vehicle_id":"test-car"}],"glock_b22")
		var p=radio.sources.values()[0]
		checks[side+"_glock_audio"]=p.stream.data==expected.data and p.get_meta("track_id")=="glock_b22"
		checks[side+"_30s_loop"]=p.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD and p.stream.loop_end==1323000 and is_equal_approx(p.stream.get_length(),30.)
		checks[side+"_correct_anchor"]=p.has_meta("fixed_position")==(side=="defender")
		listener.global_position=p.global_position
		await physics_frame;await physics_frame
		p.play();await create_timer(.2).timeout
		p.play(29.85);await create_timer(.6).timeout
		print(side," position=",p.get_playback_position()," playing=",p.playing)
		checks[side+"_native_wrap"]=p.playing and p.get_playback_position()<2.
		radio.clear();await process_frame
	checks["union_sur_audio_unchanged"]=Music.faction_stream("union_sur").data==Music.battle_stream("burn_b22").data
	FileAccess.open(OUT+"correction_validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks,"  "))
	print("CORRECTION_CHECKS ",checks.size()," ALL_PASS=",not checks.values().has(false))
	quit(0 if not checks.values().has(false) else 1)
