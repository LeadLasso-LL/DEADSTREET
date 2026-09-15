extends RefCounted
const Catalog=preload("res://battle/geometry/river_bridge_catalog.gd")
const Authored=preload("res://battle/geometry/authored_battlefield_service.gd")
const Vehicle=preload("res://battle/core/battle_vehicle.gd")
const Placement=preload("res://battle/vehicles/battle_vehicle_placement_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Doors=preload("res://battle/vehicles/battle_arrival_service.gd")
static func apply(b,config: Dictionary) -> Dictionary:
 var result=Authored.apply_definition(b,Catalog.build())
 if result==null or not result.success:return {"error":"Bridge geometry failed validation."}
 b.vehicle_hidden_cover_slots.clear()
 for side_id in [b.attacker_side_id,b.defender_side_id]:
  var zone=b.get_deployment_zone(b.get_side(side_id).deployment_zone_id);zone.deployed_vehicle_ids.clear()
 for v in b.vehicles.values():v.has_battle_position=false;v.deployment_slot_id=""
 var side=b.get_side(b.defender_side_id);var zone=b.get_deployment_zone(side.deployment_zone_id)
 for i in range(config.defender.vehicles.size()):
  var id="bridge_defender_vehicle_%02d"%i;var v=Vehicle.new(id,id,side.faction_id,side.side_id,config.defender.vehicles[i])
  if not b.add_vehicle(v) or not side.add_vehicle_id(id):return {"error":"Unable to add the defending vehicle."}
  zone.allowed_vehicle_ids.append(id)
 # Deliberate rows, not a nearest-centre pile. Footprints are checked by the shared service.
 for side_id in [b.attacker_side_id,b.defender_side_id]:
  var vs=[]
  for v in b.vehicles.values():
   if v.side_id==side_id:vs.append(v)
  vs.sort_custom(func(a,c):return Body.profile_for_vehicle(a).length>Body.profile_for_vehicle(c).length)
  var candidates=[]
  if side_id==b.attacker_side_id:
   for x in [34.,22.,10.]:
    for y in Catalog.LANES:candidates.append(Vector2(x,y))
  else:
   for x in [150.,161.,173.]:
    for y in [19.,38.,12.8,45.7]:candidates.append(Vector2(x,y))
  for v in vs:
   var placed=false
   for at in candidates:
    var facing=Vector2.RIGHT if side_id==b.attacker_side_id else Vector2.DOWN
    var attempt=Placement.place_vehicle(b,v.battle_vehicle_id,at,facing)
    if attempt!=null and attempt.success:placed=true;break
   if not placed:return {"error":"This convoy does not fit the bridge approach. Choose fewer vehicles."}
  for v in vs:Doors.ensure_doors(b,v)
 b.arrival_choice="west_approach";b.battlefield_geometry.content_revision+=1
 return {"valid":true}

static func deploy_remaining_attackers(b) -> bool:
 var ids=b.participants.keys();ids.sort()
 for id in ids:
  var unit=b.get_participant(id)
  if unit.side_id!=b.attacker_side_id or unit.has_battle_position:continue
  var v=b.get_vehicle(unit.transport_vehicle_id)
  if v==null:return false
  var candidates=[]
  for x in range(3,42,2):
   for y in range(11,48,2):candidates.append(Vector2(x,y))
  candidates.sort_custom(func(a,c):return a.distance_squared_to(v.battle_position)<c.distance_squared_to(v.battle_position))
  var placed=false
  for at in candidates:
   var occupied=false
   for other in b.participants.values():
    if other.has_battle_position and at.distance_to(other.battle_position)<1.3:occupied=true;break
   if occupied:continue
   if not b.get_deployment_position_error(b.attacker_side_id,at).is_empty():continue
   var exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd").route(b,v,at)
   if exit.is_empty() or not exit.path.success:continue
   var result=preload("res://battle/core/battle_deployment_placement_service.gd").place_participant(b,id,at)
   if result!=null and result.success:placed=true;break
  if not placed:return false
 return true
