extends RefCounted
# World-positioned ambience. Radio belongs to Raiders transport; sirens belong
# to police vehicles. These sources never replace or drive combat events.
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var view
var sources={}
var battle_id=0
var streams={}
func setup(p_view):view=p_view
func clear():
 for source in sources.values():source.queue_free()
 sources.clear()
func faction(b,side: String) -> String:
 for p in b.participants.values():
  if p.side_id==side and p.identity!=null:return p.identity.gang_archetype_id
 return ""
func stream(name: String):
 if streams.has(name):return streams[name]
 var s=AudioStreamWAV.load_from_file("res://assets/audio/convoy/"+name+".wav")
 if s==null:return null
 s.loop_mode=AudioStreamWAV.LOOP_FORWARD;s.loop_begin=0;s.loop_end=s.data.size()/2
 streams[name]=s;return s
func rebuild(b):
 clear();battle_id=b.get_instance_id()
 for side in [b.attacker_side_id,b.defender_side_id]:
  var identity=faction(b,side);var candidates=[]
  for v in b.vehicles.values():
   if v.side_id==side:candidates.append(v)
  candidates.sort_custom(func(a,z):return int(Models.model(a.vehicle_type_id).unit_capacity)>int(Models.model(z.vehicle_type_id).unit_capacity))
  var count=0
  for v in candidates:
   var name="raiders_radio" if identity=="stateline" else "police_siren"
   if identity not in ["stateline","nbpd"]:break
   if identity=="nbpd" and b.battlefield_geometry.authored_layout_id!="river_suspension_bridge_v1":break
   if count>=(1 if identity=="stateline" else 2):break
   var clip=stream(name)
   if clip==null:continue
   var player=AudioStreamPlayer2D.new();view.add_child(player);player.stream=clip
   player.max_distance=900. if identity=="stateline" else 1050.;player.attenuation=.7;player.panning_strength=.75
   player.set_meta("base_gain",-16. if identity=="stateline" else -26.);player.set_meta("offset",count*2.35)
   sources[v.battle_vehicle_id]=player;count+=1
func sync(b,poses: Dictionary,enabled: bool,duck: float,ending: float):
 if b==null:return
 if battle_id!=b.get_instance_id():rebuild(b)
 for id in sources:
  var player=sources[id];var v=b.get_vehicle(id)
  if not enabled or v==null:player.stop();continue
  player.position=poses.get(id,v.battle_position)*Vector2(8,6)
  player.volume_db=float(player.get_meta("base_gain"))-duck*4.-ending*5.
  if not player.playing:player.play(float(player.get_meta("offset",0.)))
