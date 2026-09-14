extends Node
# Pack-07 performances, event transitions and a separate presentation-only budget.
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const EVENTS=["move_acknowledgment","enemy_spotted","taking_fire","hit_reaction","wounded","death"]
var view
var streams={}
var players=[]
var states={}
var variants={}
var cooldowns={}
var battle_id=0
var feedback_sequence=0
var clock=0.
var chatter_at=0.
var played=[]
var missing=[]
var loaded_clips=0
var max_simultaneous=0
var volume_db=0.
func setup(p_view):
 view=p_view
 if AudioServer.get_bus_index("FactionVoices")<0:
  AudioServer.add_bus();AudioServer.set_bus_name(AudioServer.bus_count-1,"FactionVoices")
 for faction in ["trc","whittaker"]:
  for event in EVENTS:
   for i in range(1,4):
    var key=faction+"/"+event+"/"+event+"_%02d"%i
    var path="res://assets/audio/factions/"+key+".ogg"
    var stream=AudioStreamOggVorbis.load_from_buffer(FileAccess.get_file_as_bytes(path)) if FileAccess.file_exists(path) else null
    if stream==null:missing.append(path)
    else:streams[key]=stream;loaded_clips+=1
 for i in range(3):
  var player=AudioStreamPlayer2D.new();view.add_child(player);player.bus="FactionVoices"
  player.max_distance=1700.;player.attenuation=.45;player.panning_strength=.6;players.append(player)
func profile(p) -> String:
 if p.identity==null:return ""
 var id=Factions.canonical_id(p.identity.gang_archetype_id)
 return id if id in ["trc","whittaker"] else ""
func stop_all():
 for player in players:player.stop()
func _exit_tree():
 for player in players:
  if is_instance_valid(player):player.queue_free()
func emit(p,event: String,priority: int):
 var faction=profile(p)
 if faction.is_empty():return
 var id=p.participant_id
 if event!="death" and not p.is_alive:return
 if priority<3 and clock<float(cooldowns.get(id,0.)):return
 if priority<2 and clock<chatter_at:return
 var chosen=null
 for player in players:
  if player.playing and player.get_meta("unit","")==id:
   if priority<=int(player.get_meta("priority",0)):return
   chosen=player;break
  if not player.playing:chosen=player
 if chosen==null:
  for player in players:
   if priority>int(player.get_meta("priority",0)):
    if chosen==null or int(player.get_meta("priority",0))<int(chosen.get_meta("priority",0)):chosen=player
 if chosen==null:return
 var key=id+"/"+event;var variant=(int(variants.get(key,absi(id.hash())%3))+1)%3;variants[key]=variant
 var name=faction+"/"+event+"/"+event+"_%02d"%(variant+1)
 if not streams.has(name):return
 chosen.stop();chosen.stream=streams[name];chosen.position=p.battle_position*Vector2(8,6)
 chosen.volume_db=volume_db+(-3.5 if priority<2 else 0.)
 chosen.pitch_scale=1.+float(absi(id.hash())%5-2)*.015
 chosen.set_meta("unit",id);chosen.set_meta("priority",priority);chosen.play()
 cooldowns[id]=clock+(2.5 if priority>=2 else 6.)
 if priority<2:chatter_at=clock+1.8
 var concurrent=0
 for player in players:
  if player.playing:concurrent+=1
 max_simultaneous=maxi(max_simultaneous,concurrent)
 played.append({"time":clock,"id":id,"profile":faction,"event":event,"variant":variant+1,"position":str(chosen.position)})
func _process(delta):
 if view==null:return
 var b=view._battle_state()
 if b==null:stop_all();return
 var enabled=view.visible and view.battle_presentation!=null and view.battle_presentation.audio_enabled
 if not enabled:stop_all()
 if battle_id!=b.get_instance_id():
  stop_all();battle_id=b.get_instance_id();states={};variants={};cooldowns={};played=[];clock=0.;chatter_at=0.;feedback_sequence=0
 var frozen=b.battle_phase=="active" and b.tactical_paused
 for player in players:player.stream_paused=frozen
 if frozen:return
 clock+=delta
 var requests=[]
 for p in b.participants.values():
  var id=p.participant_id;var previous=states.get(id,{"alive":p.is_alive,"wounded":p.is_wounded,"health":p.vitality,"target":false})
  if enabled:
   if previous.alive and not p.is_alive:requests.append([p,"death",3])
   elif p.is_alive:
    if not previous.wounded and p.is_wounded:requests.append([p,"wounded",2])
    elif p.vitality<float(previous.health)-.001:requests.append([p,"hit_reaction",2])
    elif b.battle_phase=="active" and p.has_target_participant and not previous.target:requests.append([p,"enemy_spotted",1])
  states[id]={"alive":p.is_alive,"wounded":p.is_wounded,"health":p.vitality,"target":p.has_target_participant}
 requests.sort_custom(func(a,z):return a[2]>z[2])
 for request in requests:emit(request[0],request[1],request[2])
 var c=view.orders_controller
 if c!=null and c.feedback_sequence!=feedback_sequence:
  feedback_sequence=c.feedback_sequence
  if enabled and int(c.last_command_feedback.get("accepted",0))>0:
   for id in c.last_command_feedback.get("accepted_ids",[]):
    var p=b.get_participant(id)
    if p!=null and p.is_alive and not profile(p).is_empty() and (not p.current_player_group_command().is_empty() or c.last_command_feedback.get("command","")=="clear"):
     emit(p,"move_acknowledgment",1);break
