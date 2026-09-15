extends RefCounted
const Catalog=preload("res://battle/geometry/whittaker_estate_catalog.gd")
const Authored=preload("res://battle/geometry/authored_battlefield_service.gd")
const Vehicle=preload("res://battle/core/battle_vehicle.gd")
const Placement=preload("res://battle/vehicles/battle_vehicle_placement_service.gd")
const UnitPlacement=preload("res://battle/core/battle_deployment_placement_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
const Doors=preload("res://battle/vehicles/battle_arrival_service.gd")
const Cover=preload("res://battle/geometry/battle_cover_service.gd")
static func apply(b,config: Dictionary) -> Dictionary:
 var result=Authored.apply_definition(b,Catalog.build())
 if result==null or not result.success:return {"error":"Estate geometry failed validation."}
 b.vehicle_hidden_cover_slots.clear()
 for side_id in [b.attacker_side_id,b.defender_side_id]:
  var side=b.get_side(side_id);side.deployment_committed=false
  var zone=b.get_deployment_zone(side.deployment_zone_id)
  zone.deployed_vehicle_ids.clear();zone.deployed_participant_ids.clear()
 for p in b.participants.values():
  p.has_battle_position=false;p.deployment_slot_id="";p.occupied_cover_slot_id="";p.reserved_cover_slot_id="";p.clear_player_tactical_intent()
 for v in b.vehicles.values():v.has_battle_position=false;v.deployment_slot_id=""
 # Resident garrison vehicles do not transport a second imaginary defender roster.
 var side=b.get_side(b.defender_side_id);var zone=b.get_deployment_zone(side.deployment_zone_id)
 var parked=config.defender.get("vehicles",["mesa","outlander","workhorse"])
 for i in range(parked.size()):
  var id="estate_defender_vehicle_%02d"%i;var v=Vehicle.new(id,id,side.faction_id,side.side_id,parked[i])
  if not b.add_vehicle(v) or not side.add_vehicle_id(id):return {"error":"Unable to add estate vehicle."}
  zone.allowed_vehicle_ids.append(id)
 for side_id in [b.attacker_side_id,b.defender_side_id]:
  var vs=[]
  for v in b.vehicles.values():
   if v.side_id==side_id:vs.append(v)
  vs.sort_custom(func(a,z):return a.battle_vehicle_id<z.battle_vehicle_id)
  var grouped_attacker=side_id==b.attacker_side_id and vs.any(func(vehicle):return int(vehicle.get_meta("convoy_group_size",1))>1)
  var candidates=[[Vector2(39,49),Vector2(.8,-.6)],[Vector2(41,78),Vector2(.5,-.866).normalized()],[Vector2(30,103),Vector2(.94,.342).normalized()],[Vector2(28,62),Vector2.RIGHT],[Vector2(28,82),Vector2.UP]] if side_id==b.attacker_side_id else [[Vector2(69,62),Vector2.LEFT],[Vector2(117,35),Vector2.LEFT],[Vector2(70,81),Vector2.LEFT],[Vector2(115,82),Vector2.LEFT],[Vector2(95,26),Vector2.LEFT]]
  for v in vs:
   var placed=false
   var vehicle_candidates=[[Vector2(116,74),Vector2.LEFT]]+candidates if side_id==b.defender_side_id and v.vehicle_type_id=="workhorse" else candidates
   if grouped_attacker:
    var base: Array=candidates[clampi(int(v.get_meta("convoy_slot",0)),0,2)]
    vehicle_candidates=[base]
    for shift in [Vector2(-4,0),Vector2(4,0),Vector2(-8,0),Vector2(8,0),Vector2(0,-4),Vector2(-4,-4),Vector2(4,-4)]:
     vehicle_candidates.append([base[0]+shift,base[1]])
   if side_id==b.attacker_side_id and Formation.two_wheeler(v.vehicle_type_id):
    var slot=clampi(int(v.get_meta("convoy_slot",0)),0,2);var member=int(v.get_meta("convoy_member",0));var count=int(v.get_meta("convoy_group_size",1))
    var base: Array=candidates[slot];var forward: Vector2=base[1];var lateral=Vector2(-forward.y,forward.x)
    var offset=lateral*(-2.8 if member%2==0 else 2.8)+forward*((3. if count==4 else 0.)-floori(member/2.)*9.) if count>1 else Vector2.ZERO
    vehicle_candidates=[[base[0]+offset,forward]]
   for pose in vehicle_candidates:
    var at: Vector2=pose[0];var facing: Vector2=pose[1]
    var attempt=Placement.place_vehicle(b,v.battle_vehicle_id,at,facing)
    if attempt!=null and attempt.success:placed=true;break
   if not placed:return {"error":"This convoy does not fit the estate arrival area. Choose fewer vehicles."}
  for v in vs:Doors.ensure_doors(b,v)
 b.set_meta("estate_flank_count",int(config.get("estate_flank_count",0)))
 b.arrival_choice="estate_approach";b.battlefield_geometry.content_revision+=1
 if not deploy_defenders(b):return {"error":"Unable to deploy the estate garrison safely."}
 return {"valid":true}
static func deploy_defenders(b) -> bool:
 var ids=b.participants.keys();ids.sort();var counts={}
 var targets={"pistol":[Vector2(60,60),Vector2(61,74)],"smg":[Vector2(67,32),Vector2(73,77)],"shotgun":[Vector2(80,56),Vector2(90,70),Vector2(77,88),Vector2(123,56)],"rifle":[Vector2(73,38),Vector2(96,35),Vector2(107,74),Vector2(126,80),Vector2(119,42),Vector2(116,80)],"sniper":[Vector2(118,26),Vector2(127,56),Vector2(127,86)]}
 for id in ids:
  var p=b.get_participant(id)
  if p.side_id!=b.defender_side_id:continue
  var n=int(counts.get(p.weapon_type,0));counts[p.weapon_type]=n+1
  var group=targets.get(p.weapon_type,targets.rifle);var goal: Vector2=group[n%group.size()]
  var slots=b.battlefield_geometry.cover_slots.keys()
  slots.sort_custom(func(a,z):return b.battlefield_geometry.cover_slots[a].position.distance_squared_to(goal)<b.battlefield_geometry.cover_slots[z].position.distance_squared_to(goal))
  var placed=false
  for slot_id in slots:
   var slot=b.battlefield_geometry.cover_slots[slot_id]
   if slot.is_occupied() or slot.is_reserved():continue
   if slot.facing_direction.dot(Vector2.LEFT)<.5:continue
   if not b.get_deployment_position_error(p.side_id,slot.position).is_empty():continue
   var crowded=false
   for q in b.participants.values():
    if q.has_battle_position and q.battle_position.distance_to(slot.position)<1.4:crowded=true;break
   if crowded:continue
   var attempt=UnitPlacement.place_participant(b,id,slot.position)
   if attempt!=null and attempt.success:
    var occupied=Cover.occupy_slot(b,id,slot_id)
    if occupied!=null and occupied.success:placed=true;break
  if not placed:return false
 return b.commit_side_deployment(b.defender_side_id)
static func deploy_attackers(b) -> bool:
 var ids=b.participants.keys();ids.sort();var index=0;var flank_assigned=0
 for id in ids:
  var unit=b.get_participant(id)
  if unit.side_id!=b.attacker_side_id or unit.has_battle_position:continue
  var v=b.get_vehicle(unit.transport_vehicle_id)
  if v==null:return false
  var flanker=int(v.get_meta("convoy_slot",0))==2 and flank_assigned<int(b.get_meta("estate_flank_count",0))
  var goal=Vector2(69.+flank_assigned*4.,103.5) if flanker else Vector2(48.,40.+float(index%10)*5.5)
  if flanker:flank_assigned+=1
  unit.set_meta("estate_flanker",flanker);unit.set_meta("estate_fireteam",index/4);index+=1
  # Use real occupied cover, never an exposed parade line. Mix transport shelter
  # with front-fence positions; every slot must have a valid dismount route.
  var prefer_vehicle=not flanker and index%3==0
  var slots=b.battlefield_geometry.cover_slots.keys()
  slots.sort_custom(func(a,z):return opening_score(b.battlefield_geometry.cover_slots[a],goal,v.battle_vehicle_id,prefer_vehicle)<opening_score(b.battlefield_geometry.cover_slots[z],goal,v.battle_vehicle_id,prefer_vehicle))
  var placed=false
  for slot_id in slots:
   var slot=b.battlefield_geometry.cover_slots[slot_id]
   if slot.is_occupied() or slot.is_reserved():continue
   if flanker:
    if slot.position.y<103.0 or slot.position.x<55.0 or slot.position.x>80.:continue
    if slot.facing_direction.dot(Vector2.UP)<.5:continue
   else:
    if slot.position.x>49. or slot.position.y>102. or slot.facing_direction.dot(Vector2.RIGHT)<.25:continue
   if not b.get_deployment_position_error(b.attacker_side_id,slot.position).is_empty():continue
   var crowded=false
   for q in b.participants.values():
    if q.has_battle_position and slot.position.distance_to(q.battle_position)<1.4:crowded=true;break
   if crowded:continue
   var exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd").route(b,v,slot.position,bool(unit.get_meta("transport_bed",false)))
   if exit.is_empty() or not exit.path.success:continue
   var attempt=UnitPlacement.place_participant(b,id,slot.position)
   if attempt!=null and attempt.success:
    var occupied=Cover.occupy_slot(b,id,slot_id)
    if occupied!=null and occupied.success:
     unit.set_meta("estate_opening_cover",slot_id);placed=true;break
  if not placed:return false
 return true
static func opening_score(slot,goal: Vector2,transport: String,prefer_vehicle: bool) -> float:
 var own_vehicle=str(slot.cover_object_id).begins_with(transport)
 var fence="front_fence" in str(slot.cover_object_id)
 return slot.position.distance_squared_to(goal)-(650. if prefer_vehicle and own_vehicle else (180. if fence else 0.))
static func bike_formation_offset(v,facing: Vector2) -> Vector2:
 var count=int(v.get_meta("convoy_group_size",1))
 if count<=1:return Vector2.ZERO
 var member=int(v.get_meta("convoy_member",0))
 return Vector2(-facing.y,facing.x)*(-2.8 if member%2==0 else 2.8)+facing*((3. if count==4 else 0.)-floori(member/2.)*9.)
static func arrival_pose(v,clock: float,stop: float) -> Dictionary:
 var target: Vector2=v.battle_position-bike_formation_offset(v,v.facing_direction)
 var slot=int(v.get_meta("convoy_slot",0))
 # Each assault vehicle peels off before the final angle-aligned braking leg.
 # The rear team uses the outside verge; the lead vehicles cut across the lawn.
 var turn_y=111. if slot==2 else (63. if slot==0 else 89.)
 var turn_start=Vector2(12.8,turn_y+8.)
 var turn_end=Vector2(22.,turn_y)
 var control=Vector2(12.8,turn_y)
 # Packed riders share a centerline and retain their actual body spacing while
 # it turns; separate per-rider path lengths make trailing bikes catch the lead.
 var points=[Vector2(12.8,144.+slot*20.),turn_start]
 for i in range(1,13):points.append(turn_start.bezier_interpolate(control,control,turn_end,float(i)/12.))
 var approach=turn_end+Vector2(7.,0.)
 var brake=target-v.facing_direction*8.
 for i in range(1,21):points.append(turn_end.bezier_interpolate(approach,brake,target,float(i)/20.))
 var length=0.
 for i in range(1,points.size()):length+=points[i-1].distance_to(points[i])
 # Travel by arc length: followers retain real longitudinal spacing through the
 # bend instead of each accelerating into the same eased turning point.
 var remaining=clampf((clock-1.6)/(stop-1.6),0.,1.)*length
 for i in range(1,points.size()):
  var distance=points[i-1].distance_to(points[i])
  if remaining<=distance and distance>.001:
   var at=points[i-1].lerp(points[i],remaining/distance)
   var facing=points[i-1].direction_to(points[i]) if clock<stop else v.facing_direction
   return {"position":at+bike_formation_offset(v,facing),"facing":facing}
  remaining-=distance
 return {"position":v.battle_position,"facing":v.facing_direction}
