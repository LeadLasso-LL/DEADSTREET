extends RefCounted
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
const Authored=preload("res://battle/geometry/authored_battlefield_service.gd")
const Place=preload("res://battle/vehicles/battle_vehicle_placement_service.gd")
const Units=preload("res://battle/core/battle_deployment_placement_service.gd")
const Doors=preload("res://battle/vehicles/battle_arrival_service.gd")
const Cover=preload("res://battle/geometry/battle_cover_service.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
static func apply(b,_config: Dictionary) -> Dictionary:
 var result=Authored.apply_definition(b,C.build())
 if result==null or not result.success:return {"error":"Freight Exchange geometry failed validation."}
 b.vehicle_hidden_cover_slots.clear()
 for side in [b.attacker_side_id,b.defender_side_id]:
  b.get_side(side).deployment_committed=false
  var zone=b.get_deployment_zone(b.get_side(side).deployment_zone_id)
  zone.deployed_vehicle_ids.clear();zone.deployed_participant_ids.clear()
 for p in b.participants.values():
  p.has_battle_position=false;p.deployment_slot_id="";p.occupied_cover_slot_id="";p.reserved_cover_slot_id="";p.clear_player_tactical_intent()
 var vehicles=b.vehicles.values();vehicles.sort_custom(func(a,z):return a.battle_vehicle_id<z.battle_vehicle_id)
 for v in vehicles:v.has_battle_position=false;v.deployment_slot_id=""
 for v in vehicles:
  var n=int(v.get_meta("convoy_slot",0));var member=int(v.get_meta("convoy_member",0))
  var centers=[Vector2(18,18),Vector2(12,42),Vector2(21,67)]
  var directions=[Vector2(1,-1).normalized(),Vector2(-1,-1).normalized(),Vector2.RIGHT]
  var facing: Vector2=directions[clampi(n,0,2)];var center: Vector2=centers[clampi(n,0,2)]
  var grouped=int(v.get_meta("convoy_group_size",1))>1
  if grouped:center+=bike_formation_offset(v,facing)
  elif member>0:
   var side=Vector2(-facing.y,facing.x)
   center+=-facing*(2.8+member*.8)+side*(3.0 if member==1 else -3.0)
  var poses=[[center,facing],[center+Vector2(-3,1),facing],[center+Vector2(0,-4),facing],[center+Vector2(-4,-3),Vector2.UP]]
  if grouped:poses=[[center,facing]]
  var placed=false
  for pose in poses:
   var attempt=Place.place_vehicle(b,v.battle_vehicle_id,pose[0],pose[1])
   if attempt!=null and attempt.success:placed=true;break
  if not placed:return {"error":"This convoy cannot fit the freight receiving road. Choose smaller vehicles."}
 for v in vehicles:Doors.ensure_doors(b,v)
 b.arrival_choice="freight_exchange_assault";b.battlefield_geometry.content_revision+=1
 if not deploy(b,b.defender_side_id):return {"error":"Freight Exchange defenders could not reach safe cover."}
 if not b.commit_side_deployment(b.defender_side_id):return {"error":"Freight Exchange defender deployment failed."}
 return {"valid":true}
static func deploy(b,side: String) -> bool:
 var ids=b.participants.keys();ids.sort();var i=0
 for id in ids:
  var p=b.get_participant(id)
  if p.side_id!=side or p.has_battle_position:continue
  var attacking=side==b.attacker_side_id;var v=b.get_vehicle(p.transport_vehicle_id)
  var lane=[16.,35.,53.,65.][i%4]
  var goal=Vector2(39 if attacking else 140,lane)
  var facing=Vector2.RIGHT if attacking else Vector2.LEFT
  var slots=b.battlefield_geometry.cover_slots.values()
  slots.sort_custom(func(a,z):return a.position.distance_squared_to(goal)<z.position.distance_squared_to(goal))
  var placed=false
  for slot in slots:
   if slot.is_occupied() or slot.is_reserved() or slot.facing_direction.dot(facing)<-.1:continue
   if not b.get_deployment_position_error(side,slot.position).is_empty():continue
   var crowded=false
   for q in b.participants.values():
    if q.has_battle_position and q.battle_position.distance_to(slot.position)<2.4:crowded=true;break
   if crowded:continue
   if attacking:
    if v==null:continue
    var route=Exit.route(b,v,slot.position,bool(p.get_meta("transport_bed",false)))
    if route.is_empty() or not route.path.success:continue
   var attempt=Units.place_participant(b,id,slot.position)
   if attempt!=null and attempt.success:
    var occupied=Cover.occupy_slot(b,id,slot.cover_slot_id)
    if occupied!=null and occupied.success:
     p.set_meta("freight_opening_cover",slot.cover_slot_id);placed=true;break
  if not placed:return false
  i+=1
 return true
static func bike_formation_offset(v,facing: Vector2) -> Vector2:
 var count=int(v.get_meta("convoy_group_size",1))
 if count<=1:return Vector2.ZERO
 var member=int(v.get_meta("convoy_member",0))
 return Vector2(-facing.y,facing.x)*(-2.8 if member%2==0 else 2.8)+facing*((4.5 if count>2 else 0.)-floori(member/2.)*9.)
static var arrival_paths={}
static func arrival_pose(v,clock: float,stop: float) -> Dictionary:
 var f: Vector2=v.facing_direction;var target: Vector2=v.battle_position-bike_formation_offset(v,f)
 var slot=int(v.get_meta("convoy_slot",0));var member=int(v.get_meta("convoy_member",0))
 # Packed bikes keep a shared pace and body spacing through the authored curves.
 # Riders retain their staggered dismount timing after the whole group stops.
 if int(v.get_meta("convoy_group_size",1))>1:stop-=member*.28;member=0
 var key=str(target)+str(f)+str(slot)+str(member)
 if not arrival_paths.has(key):
  var knots=[]
  if slot==0:knots=[Vector2(-82,68),Vector2(-29,68),Vector2(-3,66),Vector2(9,53),Vector2(11,34),target-f*8.,target]
  elif slot==1:knots=[Vector2(-96,69),Vector2(-31,69),Vector2(-2,67),Vector2(16,57),target-f*8.,target]
  else:knots=[Vector2(-110,70),Vector2(-35,70),Vector2(-1,70),target-f*9.,target]
  if member>0:
   for i in range(knots.size()-2):knots[i]+=Vector2(-member*5.,(1. if member==1 else -1.)*2.5)
  var points=[]
  for i in range(knots.size()-1):
   var a: Vector2=knots[i];var z: Vector2=knots[i+1]
   var before: Vector2=knots[maxi(0,i-1)];var after: Vector2=knots[mini(knots.size()-1,i+2)]
   var out_control=a+(z-before)/6.;var in_control=z-(after-a)/6.
   if i==knots.size()-2:in_control=target-f*3.
   for j in range(12):points.append(a.bezier_interpolate(out_control,in_control,z,float(j)/12.))
  points.append(target)
  var length=0.
  for i in range(1,points.size()):length+=points[i-1].distance_to(points[i])
  arrival_paths[key]={"points":points,"length":length}
 var route: Dictionary=arrival_paths[key];var points: Array=route.points
 var start=[1.2,1.7,2.7][clampi(slot,0,2)]+member*.2
 var u=clampf((clock-start)/(stop-start),0.,1.)
 # Soft acceleration/braking with an uninterrupted curved path through the yard gate.
 var remaining=smoothstep(0.,1.,u)*float(route.length)
 for i in range(1,points.size()):
  var distance=points[i-1].distance_to(points[i])
  if remaining<=distance and distance>.0001:
   var at=points[i-1].lerp(points[i],remaining/distance)
   var direction=points[i-1].direction_to(points[i])
   if u>.96:direction=direction.slerp(f,smoothstep(.96,1.,u))
   var heading=direction if u<1. else f
   return {"position":at+bike_formation_offset(v,heading),"facing":heading}
  remaining-=distance
 return {"position":v.battle_position,"facing":f}
