extends RefCounted
const C=preload("res://battle/geometry/doble_ocho_catalog.gd")
const Authored=preload("res://battle/geometry/authored_battlefield_service.gd")
const Place=preload("res://battle/vehicles/battle_vehicle_placement_service.gd")
const Units=preload("res://battle/core/battle_deployment_placement_service.gd")
const Doors=preload("res://battle/vehicles/battle_arrival_service.gd")
const Cover=preload("res://battle/geometry/battle_cover_service.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
static func apply(b,_config: Dictionary) -> Dictionary:
 var result=Authored.apply_definition(b,C.build())
 if result==null or not result.success:return {"error":"Doble Ocho geometry failed validation."}
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
  var poses=[]
  if n==0:
   poses=[[Vector2(29,33),Vector2(1,-.35).normalized()],[Vector2(17,32),Vector2.RIGHT],[Vector2(10,33),Vector2.RIGHT]]
  elif n==1:
   poses=[[Vector2(75,58),Vector2(1,-.4).normalized()],[Vector2(65,58),Vector2.RIGHT],[Vector2(51,58),Vector2.RIGHT]]
  else:poses=[[Vector2(16,53),Vector2.RIGHT],[Vector2(5.5,54),Vector2.RIGHT]]
  if member>0:poses=[[poses[0][0]+Vector2(-4.5,member*3.8),poses[0][1]]]+poses
  var placed=false
  for pose in poses:
   var attempt=Place.place_vehicle(b,v.battle_vehicle_id,pose[0],pose[1])
   if attempt!=null and attempt.success:placed=true;break
  if not placed:return {"error":"This convoy is too large for the auto-yard approach. Choose smaller vehicles."}
 for v in vehicles:Doors.ensure_doors(b,v)
 b.arrival_choice="doble_ocho_assault";b.battlefield_geometry.content_revision+=1
 if not deploy(b,b.defender_side_id):return {"error":"Doble Ocho defenders could not reach safe cover."}
 if not b.commit_side_deployment(b.defender_side_id):return {"error":"Doble Ocho defender deployment failed."}
 return {"valid":true}
static func deploy(b,side: String) -> bool:
 var ids=b.participants.keys();ids.sort();var i=0;var flank_count=0
 for id in ids:
  var p=b.get_participant(id)
  if p.side_id!=side or p.has_battle_position:continue
  var attacking=side==b.attacker_side_id;var v=b.get_vehicle(p.transport_vehicle_id)
  var flank=attacking and v!=null and int(v.get_meta("convoy_slot",0))==1
  var goal=Vector2(45,29+float(i%3)*4.)
  var facing=Vector2(1,-.3).normalized()
  if flank:goal=Vector2(80+flank_count*5,47.1);facing=Vector2.UP;flank_count+=1
  if not attacking:
   goal=[Vector2(73,25),Vector2(85,33),Vector2(96,38),Vector2(63,36),Vector2(69,22),Vector2(103,33),Vector2(62,19)][i%7]
   facing=Vector2(-1,.35).normalized() if goal.y<35 else Vector2(-.65,.75).normalized()
  var slots=b.battlefield_geometry.cover_slots.values()
  slots.sort_custom(func(a,z):return a.position.distance_squared_to(goal)<z.position.distance_squared_to(goal))
  var placed=false
  for slot in slots:
   if slot.is_occupied() or slot.is_reserved() or slot.facing_direction.dot(facing)<.2:continue
   if not b.get_deployment_position_error(side,slot.position).is_empty():continue
   if flank and (slot.position.y<46. or slot.position.x<65. or slot.position.x>102.):continue
   if attacking and not flank and slot.position.x>50.:continue
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
     p.set_meta("doble_ocho_flanker",flank);p.set_meta("doble_ocho_opening_cover",slot.cover_slot_id);placed=true;break
  if not placed:return false
  i+=1
 return true
static func arrival_pose(v,clock: float,stop: float) -> Dictionary:
 var n=int(v.get_meta("convoy_slot",0));var target: Vector2=v.battle_position
 var points=[]
 if n==0:
  # Lead truck turns up the access street, then cuts through the already open gate.
  points=[Vector2(-40,64.5),Vector2(3,64.5),Vector2(11,55),Vector2(11,37),Vector2(17,35)]
 else:
  # Following vehicle continues along the correct carriageway for the service team.
  points=[Vector2(-61-n*13,64.5),Vector2(24,64.5),Vector2(59,64.5)]
 var a: Vector2=points.back();var brake=target-v.facing_direction*7.
 for j in range(1,19):points.append(a.bezier_interpolate(a+Vector2(4,0),brake,target,float(j)/18.))
 var length=0.
 for j in range(1,points.size()):length+=points[j-1].distance_to(points[j])
 var remaining=clampf((clock-1.6)/(stop-1.6),0.,1.)*length
 for j in range(1,points.size()):
  var distance=points[j-1].distance_to(points[j])
  if remaining<=distance and distance>.001:return {"position":points[j-1].lerp(points[j],remaining/distance),"facing":points[j-1].direction_to(points[j]) if clock<stop else v.facing_direction}
  remaining-=distance
 return {"position":target,"facing":v.facing_direction}

