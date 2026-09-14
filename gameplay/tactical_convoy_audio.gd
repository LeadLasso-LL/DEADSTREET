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
  if identity=="whittaker" and b.battlefield_geometry.authored_layout_id=="whittaker_estate_v1":
   var clip=stream("whittaker_radio")
   if clip!=null:
    var player=AudioStreamPlayer2D.new();view.add_child(player);player.stream=clip
    player.max_distance=1450.;player.attenuation=.6;player.panning_strength=.65
    player.set_meta("base_gain",-25.);player.set_meta("victory_gain",-18.);player.set_meta("battle_drop",6.)
    player.set_meta("attenuation",1.2);player.set_meta("offset",0.);player.set_meta("is_radio",true);player.set_meta("side_id",side)
    player.set_meta("fixed_position",preload("res://battle/geometry/whittaker_estate_catalog.gd").ENTRANCE);player.set_meta("range",1100.)
    sources["estate_porch_radio"]=player
  var count=0
  for v in candidates:
   var name="trc_siren" if identity=="trc" else ("raiders_radio" if identity=="stateline" else "police_siren")
   if identity not in ["stateline","nbpd","trc"]:break
   if identity=="trc" and b.battlefield_geometry.authored_layout_id!="whittaker_estate_v1":break
   if identity=="nbpd" and b.battlefield_geometry.authored_layout_id!="river_suspension_bridge_v1":break
   if count>=(2 if identity=="nbpd" else 1):break
   var clip=stream(name)
   if clip==null:continue
   var player=AudioStreamPlayer2D.new();view.add_child(player);player.stream=clip
   player.max_distance=900. if identity=="stateline" else 1050.;player.attenuation=.7;player.panning_strength=.75
   player.set_meta("base_gain",-18. if identity=="stateline" else (-13.5 if identity=="trc" else -29.));player.set_meta("offset",count*2.35)
   player.set_meta("is_trc_siren",identity=="trc")
   player.pitch_scale=.75 if identity=="trc" else 1.
   player.set_meta("is_radio",identity=="stateline");player.set_meta("side_id",side)
   sources[v.battle_vehicle_id]=player;count+=1
func sync(b,poses: Dictionary,enabled: bool,duck: float,ending: float,battle_mix: float=0.0,victory_mix: float=0.0):
 if b==null:return
 if battle_id!=b.get_instance_id():rebuild(b)
 var winner=b.get_winning_side_id() if b.battle_phase=="resolved" else ""
 for id in sources:
  var player=sources[id];var v=b.get_vehicle(id)
  if not enabled or (v==null and not player.has_meta("fixed_position")):player.stop();continue
  var anchor: Vector2=player.get_meta("fixed_position") if player.has_meta("fixed_position") else poses.get(id,v.battle_position)
  player.position=anchor*Vector2(8,6)
  var is_radio=bool(player.get_meta("is_radio",false))
  var owns_victory=is_radio and not winner.is_empty() and str(player.get_meta("side_id",""))==winner
  var foreground=clampf(victory_mix,0.,1.) if owns_victory else 0.
  var radio_drop=float(player.get_meta("battle_drop",14.))*clampf(battle_mix,0.,1.)*(1.-foreground) if is_radio else 0.
  var base_gain=float(player.get_meta("base_gain"))
  player.volume_db=lerpf(base_gain,float(player.get_meta("victory_gain",base_gain)),foreground)-radio_drop-(duck*4.+ending*5.)*(1.-foreground)
  # Continue the same playing riff as the winning faction takes the foreground.
  # At full victory mix it is centered and retains its intro gain regardless of camera distance.
  player.max_distance=lerpf(float(player.get_meta("range",900.)),100000.,foreground) if is_radio else 1050.
  player.attenuation=lerpf(float(player.get_meta("attenuation",.7)),0.,foreground)
  player.panning_strength=.75*(1.-foreground)
  if bool(player.get_meta("is_trc_siren",false)):
   # A persistent warning source, not radio music. Use broken, wavering warning pulses and
   # enough distance reach to remain audible after the camera leaves the convoy.
   var victory_dip=clampf(victory_mix,0.,1.) if not winner.is_empty() and str(player.get_meta("side_id",""))!=winner else 0.
   player.volume_db=-13.5-18.0*clampf(battle_mix,0.,1.)-2.0*duck-3.0*ending-11.0*victory_dip
   player.max_distance=2600.;player.attenuation=.22;player.panning_strength=.35
  player.set_meta("victory_foreground",foreground)
  if not player.playing:player.play(float(player.get_meta("offset",0.)))
