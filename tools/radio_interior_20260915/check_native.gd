extends SceneTree
const Filter=preload("res://gameplay/tactical_radio_filter.gd")
const Convoy=preload("res://gameplay/tactical_convoy_audio.gd")
const Before=preload("res://tools/radio_interior_20260915/before_tactical_convoy_audio.gd")
const Music=preload("res://gameplay/music_catalog.gd")
const OUT="res://tools/radio_interior_20260915/"
var checks=[]
var failures=[]
var stage: Node2D
var listener: AudioListener2D
class Fixture extends RefCounted:
 var attacker_side_id="attacker"
 var defender_side_id="defender"
 var participants={}
 var vehicles={}
 var battlefield_geometry={}
 var battle_phase="combat"
 func get_vehicle(id):return vehicles.get(id)
 func get_winning_side_id():return attacker_side_id

func check(ok: bool,label: String):
 checks.append(label)
 if not ok:failures.append(label);push_error(label)
func _initialize():call_deferred("run")
func fixture(layout: String,a: String="calle_ocho",d: String="union_sur"):
 var b=Fixture.new()
 b.battlefield_geometry={"authored_layout_id":layout}
 for side in ["attacker","defender"]:
  b.participants[side]={"side_id":side,"identity":{"gang_archetype_id":a if side=="attacker" else d},"battle_position":Vector2(20,30)}
  b.vehicles[side+"_car"]={"side_id":side,"vehicle_type_id":"bayou","battle_vehicle_id":side+"_car","battle_position":Vector2(10,20) if side=="attacker" else Vector2(40,30)}
 return b

func run():
 stage=Node2D.new();root.add_child(stage)
 listener=AudioListener2D.new();stage.add_child(listener);listener.make_current()
 AudioServer.set_bus_volume_db(0,-65.)
 var baseline=AudioServer.get_bus_count()
 var master_effects=AudioServer.get_bus_effect_count(0)
 AudioServer.add_bus();AudioServer.set_bus_name(baseline,"RadioTestUnrelated")
 var expected_buses=AudioServer.get_bus_count()
 await physics_frame
 await physics_frame
 for layout in ["harold_street_v1","whittaker_estate_v1","river_suspension_bridge_v1"]:
  var b=fixture(layout)
  var old=Before.new();old.setup(stage);old.rebuild(b)
  var now=Convoy.new();now.setup(stage);now.rebuild(b)
  check(now.sources.size()==2,layout+" creates two radios")
  check(AudioServer.get_bus_count()==expected_buses+2,layout+" each source owns one bus")
  for mix in [0.,1.]:
   old.sync(b,{"attacker_car":Vector2(12,22)},true,.2,.1,mix)
   now.sync(b,{"attacker_car":Vector2(12,22)},true,.2,.1,mix)
   for id in old.sources:
    var x=old.sources[id];var y=now.sources[id]
    check(y.position==x.position and is_equal_approx(y.volume_db,x.volume_db),layout+" position/gain preserved "+id+" "+str(mix))
    check(y.attenuation==x.attenuation and y.max_distance==x.max_distance and y.panning_strength==x.panning_strength,layout+" distance/pan preserved "+id+" "+str(mix))
    check(y.has_meta(Filter.EFFECT_META) and y.bus!=&"Master",layout+" radio is filtered "+id)
  var a=now.sources.attacker_car
  listener.global_position=a.global_position
  await create_timer(.25).timeout
  var original_stream=a.stream
  a.play(7.0)
  await create_timer(.2).timeout
  var position_before=a.get_playback_position()
  b.battle_phase="resolved"
  now.sync(b,{},true,0.,1.,1.,.5)
  check(a.get_meta(Filter.EFFECT_META).cutoff_hz>2400. and a.get_meta(Filter.EFFECT_META).cutoff_hz<7500.,layout+" winner opens gradually")
  now.sync(b,{},true,0.,1.,1.,1.)
  check(is_equal_approx(a.get_meta(Filter.EFFECT_META).cutoff_hz,7500.),layout+" winner becomes clearer")
  check(a.stream==original_stream and a.get_playback_position()>=position_before-.08,layout+" outro preserves current stream and playback")
  for p in now.sources.values():
   if p.get_meta("side_id")=="defender":
    check(is_equal_approx(p.get_meta(Filter.EFFECT_META).cutoff_hz,p.get_meta(Filter.BASE_META)),layout+" losing side stays muffled")
  a.play(29.85)
  await create_timer(.65).timeout
  check(a.playing and a.get_playback_position()<1.5,layout+" actual thirty second loop wraps")
  old.clear();now.clear()
  await process_frame
  await process_frame
  check(AudioServer.get_bus_count()==expected_buses,layout+" rebuild releases all owned buses")
 for spec in [["whittaker_estate_v1","trc"],["river_suspension_bridge_v1","nbpd"]]:
  var b=fixture(spec[0],spec[1],spec[1])
  var old=Before.new();old.setup(stage);old.rebuild(b)
  var now=Convoy.new();now.setup(stage);now.rebuild(b)
  old.sync(b,{},true,.3,.2,1.,.5);now.sync(b,{},true,.3,.2,1.,.5)
  check(now.sources.size()==old.sources.size() and now.sources.size()>0,spec[1]+" existing sirens remain")
  for id in old.sources:
   var x=old.sources[id];var y=now.sources[id]
   check(y.bus==x.bus and not y.has_meta(Filter.EFFECT_META),spec[1]+" siren bypasses filter "+id)
   check(y.volume_db==x.volume_db and y.position==x.position and y.pitch_scale==x.pitch_scale and y.stream.data==x.stream.data,spec[1]+" siren source/gain/pitch unchanged "+id)
  old.clear();now.clear();await process_frame;await process_frame
 var mappings: Dictionary=Music.catalogue().faction_tracks
 for identity in mappings:
  var b=fixture("harold_street_v1",identity,identity)
  var now=Convoy.new();now.setup(stage);now.rebuild(b)
  check(now.sources.size()==2,identity+" mapped loop creates both radio types")
  for p in now.sources.values():
   var building=p.has_meta("fixed_position")
   check(is_equal_approx(p.get_meta(Filter.EFFECT_META).cutoff_hz,1800. if building else 2400.),identity+" correct interior profile "+str(building))
  now.clear();await process_frame
 check(AudioServer.get_bus_count()==expected_buses,"all faction rebuilds release buses")
 var menu=AudioStreamPlayer.new();stage.add_child(menu)
 check(menu.bus==&"Master" and AudioServer.get_bus_effect_count(0)==master_effects,"menu and Master remain unfiltered")
 menu.queue_free()
 await measure()
 check(AudioServer.get_bus_count()==expected_buses,"signal probe releases own bus")
 check(AudioServer.get_bus_index("RadioTestUnrelated")>=0,"unrelated bus preserved")
 AudioServer.remove_bus(AudioServer.get_bus_index("RadioTestUnrelated"))
 var result={"checks":checks.size(),"failures":failures,"mix_rate":AudioServer.get_mix_rate(),"profiles_hz":{"vehicle":2400,"building":1800,"foreground":7500},"validation":"Native Godot routing, real loop transport, before/after behavior, cleanup and captured signal response. No independent listening approval."}
 FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("RADIO_INTERIOR_CHECKS ",checks.size()," FAILURES ",failures)
 quit(0 if failures.is_empty() else 1)

func measure():
 var p=AudioStreamPlayer2D.new();stage.add_child(p)
 p.stream=AudioStreamWAV.load_from_file(OUT+"filter_probe.wav")
 p.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
 p.stream.loop_begin=0;p.stream.loop_end=48000
 p.global_position=listener.global_position
 p.volume_db=0.;p.attenuation=0.;p.panning_strength=0.
 Filter.attach(p,false)
 var idx=AudioServer.get_bus_index(p.bus)
 var capture=AudioEffectCapture.new();capture.buffer_length=2.
 AudioServer.add_bus_effect(idx,capture)
 p.play()
 await create_timer(.3).timeout
 for mode in ["dry","vehicle","building","foreground"]:
  AudioServer.set_bus_effect_enabled(idx,0,mode!="dry")
  var effect=p.get_meta(Filter.EFFECT_META)
  effect.cutoff_hz=1800. if mode=="building" else (7500. if mode=="foreground" else 2400.)
  await create_timer(.12).timeout
  capture.clear_buffer()
  await create_timer(.55).timeout
  var count=capture.get_frames_available()
  check(count>8000,mode+" native signal capture has frames")
  var buf=capture.get_buffer(count)
  FileAccess.open(OUT+"response_"+mode+".f32",FileAccess.WRITE).store_buffer(buf.to_byte_array())
 p.queue_free()
 await process_frame
 await process_frame
