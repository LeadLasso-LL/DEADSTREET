extends SceneTree
const OUT="res://tools/faction_music_apply_20260915/"
const Catalog=preload("res://gameplay/music_catalog.gd")
const Convoy=preload("res://gameplay/tactical_convoy_audio.gd")
const Before=preload("res://tools/faction_music_apply_20260915/before_tactical_convoy_audio.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
var checks={}
var failures=[]
func _initialize():call_deferred("run")
func note(id:String,ok:bool):
	checks[id]=ok
	if not ok:failures.append(id);print("FAIL ",id)
func identities(b,id):
	for p in b.participants.values():p.identity=Identity.make(p.participant_id,id,p.weapon_type)
func radio(audio,side):
	for source in audio.sources.values():
		if source.has_meta("track_id") and str(source.get_meta("side_id"))==side:return source
	return null
func same_sirens(old,new):
	if old.sources.keys()!=new.sources.keys():return false
	for id in old.sources:
		var a=old.sources[id];var b=new.sources[id]
		if a.stream.data!=b.stream.data or a.stream.loop_end!=b.stream.loop_end:return false
		for prop in ["position","volume_db","pitch_scale","max_distance","attenuation","panning_strength"]:
			if a.get(prop)!=b.get(prop):return false
		if a.get_meta_list()!=b.get_meta_list():return false
		for key in a.get_meta_list():
			if a.get_meta(key)!=b.get_meta(key):return false
	return true
func run():
	AudioServer.set_bus_volume_db(0,-65)
	root.size=Vector2i(640,480)
	var test_view=Node2D.new();root.add_child(test_view)
	var listener=AudioListener2D.new();test_view.add_child(listener);listener.make_current()
	var approved=JSON.parse_string(FileAccess.get_file_as_string(OUT+"approved_assignments.json")).faction_tracks
	note("exact_owner_mapping",Catalog.catalogue().faction_tracks==approved and approved.size()==21)
	note("authority_catalogue_excluded",Catalog.faction_stream("trc")==null and Catalog.faction_stream("nbpd")==null)
	note("final_calle_glock_union_burn",approved.calle_ocho=="glock_b22" and approved.union_sur=="burn_b22")
	for map_id in ["harold","river_bridge","whittaker_estate"]:
		var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
		var config={"map_id":map_id,"attacker":{"faction":"orlov","units":Config.balanced(),"vehicles":["bayou","bayou"]},"defender":{"faction":"whittaker" if map_id=="whittaker_estate" else "mercer","units":Config.balanced(),"vehicles":["bayou","bayou"]}}
		await scene.start_battle(false,config);scene.set_process(false)
		var b=scene.battle;note(map_id+"_native_battle_loaded",b!=null)
		if b==null:scene.queue_free();continue
		var view=scene.runtime.get_node("TacticalBattleView");var presentation=view.battle_presentation
		await create_timer(.2).timeout
		note(map_id+"_live_sources",radio(presentation.convoy_audio,b.attacker_side_id)!=null and radio(presentation.convoy_audio,b.defender_side_id)!=null)
		note(map_id+"_old_apartment_beat_silent",presentation.sound.has_faction_music and not presentation.sound.music.playing)
		presentation.set_process(false);presentation.sound.set_process(false);presentation.sound.city.stop();presentation.sound.music.stop();presentation.convoy_audio.clear()
		scene.queue_free();await process_frame;await process_frame
		var audio=Convoy.new();audio.setup(test_view)
		audio.rebuild(b);audio.sync(b,{},true,0.,0.,0.,0.)
		var atk=radio(audio,b.attacker_side_id);var def=radio(audio,b.defender_side_id)
		note(map_id+"_both_sides_play",atk!=null and def!=null and atk.playing and def.playing)
		note(map_id+"_attacker_vehicle_anchor",not atk.has_meta("fixed_position"))
		note(map_id+"_defender_anchor",def.has_meta("fixed_position")== (map_id!="river_bridge"))
		if map_id=="whittaker_estate":note("estate_keys_and_mansion",def.get_meta("track_id")=="keys_b22" and def.get_meta("fixed_position")==preload("res://battle/geometry/whittaker_estate_catalog.gd").ENTRANCE and def.get_meta("base_gain")==-25.)
		audio.sync(b,{},true,0.,0.,1.,0.);note(map_id+"_combat_quieter",atk.volume_db<float(atk.get_meta("base_gain")) and def.volume_db<float(def.get_meta("base_gain")))
		var original_phase=b.battle_phase
		b.tactical_result=preload("res://battle/core/battle_victory_result.gd").new()
		if b.tactical_result!=null:
			b.tactical_result.resolved=true;b.tactical_result.winning_side_id=b.attacker_side_id;b.battle_phase="resolved"
			atk.play(7.0);await create_timer(.06).timeout;var pos=atk.get_playback_position();var stream=atk.stream
			audio.sync(b,{},true,.8,1.,1.,1.)
			note(map_id+"_winner_continues_same_loop",atk.stream==stream and atk.get_playback_position()>=pos and atk.get_meta("victory_foreground")==1.0 and atk.attenuation==0 and atk.panning_strength==0)
			note(map_id+"_loser_stays_background",def.get_meta("victory_foreground")==0.0 and def.volume_db<atk.volume_db)
			b.tactical_result.resolved=false;b.tactical_result.winning_side_id="";b.battle_phase=original_phase
		else:note(map_id+"_result_available",false)
		audio.sync(b,{},false,0.,0.);note(map_id+"_exit_stops_music",not atk.playing and not def.playing)
		audio.clear()
		if map_id=="harold":
			for id in approved:
				identities(b,str(id));audio.rebuild(b);audio.sync(b,{},true,0.,0.)
				atk=radio(audio,b.attacker_side_id);def=radio(audio,b.defender_side_id)
				var expected=Catalog.battle_stream(str(approved[id]))
				note(str(id)+"_both_sides_correct_audio",atk!=null and def!=null and atk.stream.data==expected.data and def.stream.data==expected.data and atk.get_meta("track_id")==approved[id] and def.get_meta("track_id")==approved[id])
				note(str(id)+"_exact_30s_loop",atk.stream.loop_end==1323000 and is_equal_approx(atk.stream.get_length(),30.) and atk.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD)
				def.stop();listener.global_position=atk.global_position;atk.play(29.85);await create_timer(.38).timeout
				print("WRAP ",id," playing=",atk.playing," position=",atk.get_playback_position())
				note(str(id)+"_native_wrap",atk.playing and atk.get_playback_position()<2.)
				audio.clear()
		for authority in ["trc","nbpd"]:
			identities(b,authority)
			var old=Before.new();old.setup(test_view);old.rebuild(b);audio.rebuild(b)
			for mix in [0.,1.]:
				old.sync(b,{},true,.4,.5,mix,.7);audio.sync(b,{},true,.4,.5,mix,.7)
				note(map_id+"_"+authority+"_siren_equivalence_"+str(mix),same_sirens(old,audio))
			note(map_id+"_"+authority+"_no_music_radio",radio(audio,b.attacker_side_id)==null and radio(audio,b.defender_side_id)==null)
			old.clear();audio.clear()
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"mapping_count":21,"limit":"Native source/playback and parameter checks with seek-assisted loop/outro checks; no new subjective mix approval."},"  "))
	print("FACTION_AUDIO_NATIVE ",checks.size()," checks; failures=",failures)
	quit(0 if failures.is_empty() else 1)
