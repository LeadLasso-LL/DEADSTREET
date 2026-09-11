extends Node
# Event-driven presentation only. Uses an independent deterministic variation index.
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
var view: Node
var enabled=true
var streams={}
var voices: Array[AudioStreamPlayer2D]=[]
var cursor=0
var city: AudioStreamPlayer
var music: AudioStreamPlayer2D
var engine: AudioStreamPlayer2D
var seen={}
var positions={}
var foot_distance={}
var reloads={}
var battle_id=0
var shots_played=0
var gun_duck=0.
const APARTMENT_BASE_GAIN_DB=-13.5
const RESULTS_MUSIC_BOOST_DB=5.0
var apartment_gain_db=APARTMENT_BASE_GAIN_DB
var results_music_mix=0.
func setup(p_view):
 view=p_view
 for name in ["city","apartment_beat","engine","door","reload","impact","start"]:
  streams[name]=load("res://assets/audio/harold/"+name+".wav")
 for kind in ["smg","rifle","pistol","shotgun"]:
  for i in range(3):streams[kind+str(i)]=load("res://assets/audio/harold/"+kind+"_"+str(i)+".wav")
 for i in range(4):streams["step"+str(i)]=load("res://assets/audio/harold/step_"+str(i)+".wav")
 city=AudioStreamPlayer.new();add_child(city);city.stream=looping("city");city.volume_db=-6
 music=AudioStreamPlayer2D.new();view.add_child(music);music.stream=looping("apartment_beat");set_apartment_emitter(Vector2(25,7))
 engine=AudioStreamPlayer2D.new();view.add_child(engine);engine.stream=looping("engine");engine.max_distance=1100;engine.volume_db=-13
 for i in range(28):
  var v=AudioStreamPlayer2D.new();view.add_child(v);v.max_distance=1100;v.attenuation=.4;v.panning_strength=.8;voices.append(v)
# Reusable world-space sound source for apartments on other maps.
func set_apartment_emitter(at: Vector2,gain_db: float=APARTMENT_BASE_GAIN_DB,audible_radius: float=700.):
 apartment_gain_db=gain_db
 if music==null:return
 music.position=at*Vector2(8,6);music.max_distance=audible_radius;music.attenuation=.8;music.panning_strength=.9;music.volume_db=apartment_gain_db
func looping(name: String):
 var s=streams[name].duplicate();s.loop_mode=AudioStreamWAV.LOOP_FORWARD;s.loop_begin=0;s.loop_end=s.data.size()/(4 if s.stereo else 2);return s
func play(name: String,at: Vector2,gain: float=-10.,variation: int=0):
 if not enabled or not streams.has(name):return
 var v=voices[cursor%voices.size()];cursor+=1;v.stop();v.stream=streams[name];v.position=at*Vector2(8,6);v.volume_db=gain;v.pitch_scale=1.+float(variation%7-3)*.012;v.play()
func set_engine(at: Vector2,running: bool,pitch: float=1.):
 engine.position=at*Vector2(8,6);engine.pitch_scale=pitch
 if running and enabled:
  if not engine.playing:engine.play()
 else:engine.stop()
func _process(_delta):
 gun_duck=maxf(0.,gun_duck-maxf(_delta,0.)*5.)
 if city!=null:city.volume_db=-6.-gun_duck*2.5
 if music!=null:music.volume_db=apartment_gain_db+RESULTS_MUSIC_BOOST_DB*clampf(results_music_mix,0.,1.)-gun_duck*3.
 if view==null:return
 var b=view._battle_state();var active=enabled and view.visible and view._is_dusk_street() and b!=null
 if not active:
  city.stop();music.stop();engine.stop()
  for v in voices:v.stop()
  if b!=null:
   for e in b.combat_feedback_events:seen[e.sequence_id]=true
  return
 if not city.playing:city.play()
 if not music.playing:music.play()
 if battle_id!=b.get_instance_id():battle_id=b.get_instance_id();seen={};positions={};foot_distance={};reloads={};shots_played=0
 for e in b.combat_feedback_events:
  if seen.has(e.sequence_id):continue
  seen[e.sequence_id]=true
  var p=b.get_participant(e.source_participant_id)
  if p==null:continue
  play(_model_report(p,e.sequence_id%3),e.source_position if e.has_source_position else p.battle_position,-8. if p.weapon_type!="shotgun" else -6.5,e.sequence_id)
  shots_played+=1;gun_duck=1.
  if e.trauma_applied>0:play("impact",e.target_position,-21.,e.sequence_id)
 for p in b.participants.values():
  var id=p.participant_id;var moved=p.battle_position.distance_to(positions.get(id,p.battle_position));positions[id]=p.battle_position
  foot_distance[id]=float(foot_distance.get(id,0.))+moved
  if p.is_alive and float(foot_distance[id])>.85:
   foot_distance[id]=0.;play("step"+str((cursor+id.hash())%4),p.battle_position,-23.,cursor)
  var reloading=p.weapon_state!=null and p.weapon_state.is_reloading
  if reloading and not reloads.get(id,false):play("reload",p.battle_position,-20.,cursor)
  reloads[id]=reloading


func _model_report(p, variation: int) -> String:
 var model: String=p.weapon_model_id
 if model.is_empty():model=Weapons.default_model(p.weapon_type)
 var key: String=model+"_"+str(variation)
 if not streams.has(key):
  var path: String="res://assets/audio/weapons/"+key+".wav"
  if ResourceLoader.exists(path):streams[key]=load(path)
  else:return p.weapon_type+str(variation)
 return key
