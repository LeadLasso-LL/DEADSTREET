extends RefCounted
# Authored Harold deployment choices and parked, open-door cover.
const Catalog=preload("res://battle/geometry/harold_street_catalog.gd")
const Area=preload("res://battle/geometry/battle_deployment_area.gd")
const Pocket=preload("res://battle/geometry/battle_deployment_pocket.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Cover=preload("res://battle/vehicles/battle_vehicle_cover_service.gd")
const CoverService=preload("res://battle/geometry/battle_cover_service.gd")
const Obstacle=preload("res://battle/geometry/battle_obstacle.gd")
const CoverObject=preload("res://battle/geometry/battle_cover_object.gd")
const Slot=preload("res://battle/geometry/battle_cover_slot.gd")
static func choose(b,choice: String) -> bool:
 if b==null or b.battle_phase!="deployment" or b.is_side_deployment_committed(b.attacker_side_id):return false
 if not Catalog.ARRIVAL_OPTIONS.has(choice):return false
 if b.arrival_choice==choice:return true
 var g=b.battlefield_geometry
 if g==null or g.authored_layout_id!=Catalog.ID:return false
 var vehicles=[]
 for v in b.vehicles.values():
  if v.side_id==b.attacker_side_id:vehicles.append(v)
 if vehicles.is_empty():return false
 var c: Vector2=Catalog.ARRIVAL_OPTIONS[choice].center
 var convoy_length=0.
 for v in vehicles:convoy_length+=Body.profile_for_vehicle(v).length+1.3
 var right=minf(64,c.x+12);var left=maxf(31,right-maxf(20.,convoy_length))
 var rect=Rect2(left,24,right-left,10.8)
 var old_area=g.attacker_deployment_area;var old_rect=g.attacker_deployment_rect
 var area=Area.new();area.add_pocket(Pocket.new("arrival_"+choice,Catalog.rect_points(rect)))
 g.attacker_deployment_area=area;g.attacker_deployment_rect=rect
 var context=preload("res://battle/vehicles/battle_vehicle_placement_context.gd").new(vehicles.size()==1,c,true,Vector2.LEFT)
 # Query a complete new convoy arrangement with old bodies/doors temporarily absent.
 # Restore every query-time change before either accepting or rejecting the choice.
 var obstacles=g.obstacles.duplicate();var objects=g.cover_objects.duplicate();var slots=g.cover_slots.duplicate()
 var flags={};var unit_flags={}
 for p in b.participants.values():
  if p.side_id==b.attacker_side_id:unit_flags[p.participant_id]=p.has_battle_position;p.has_battle_position=false
 for v in vehicles:
  flags[v.battle_vehicle_id]=v.has_battle_position;v.has_battle_position=false
  var ids=[Cover.body_cover_object_id(v.battle_vehicle_id)]
  for spec in door_specs(v):ids.append(spec.id)
  for id in ids:
   if g.cover_objects.has(id):
    for slot in g.cover_objects[id].slot_ids:g.cover_slots.erase(slot)
   g.cover_objects.erase(id);g.obstacles.erase(id)
 var plan=preload("res://battle/ai/battle_vehicle_deployment_planner.gd").plan_side_vehicles(b,b.attacker_side_id,b.defender_side_id,context)
 g.obstacles=obstacles;g.cover_objects=objects;g.cover_slots=slots
 for id in flags:b.get_vehicle(id).has_battle_position=flags[id]
 for id in unit_flags:b.get_participant(id).has_battle_position=unit_flags[id]
 if plan==null or not plan.success:
  g.attacker_deployment_area=old_area;g.attacker_deployment_rect=old_rect
  return false
 for p in b.participants.values():
  if p.side_id!=b.attacker_side_id:continue
  CoverService.release_all_for_participant(b,p.participant_id);p.clear_pending_deployment_cover();p.clear_player_tactical_intent()
  p.has_battle_position=false;p.deployment_slot_id=""
 var zone=b.get_deployment_zone(b.get_side(b.attacker_side_id).deployment_zone_id)
 zone.deployed_participant_ids.clear();zone.deployment_rect=rect
 for v in vehicles:
  remove_doors(b,v)
  var body_id=Cover.body_cover_object_id(v.battle_vehicle_id)
  if g.has_cover_object(body_id):g.remove_cover_object(body_id)
 for assignment in plan.assignments:
  var v=b.get_vehicle(assignment.vehicle_id)
  if not b.is_vehicle_deployed(v.battle_vehicle_id):b.deploy_vehicle(v.battle_vehicle_id,zone.zone_id)
  v.battle_position=assignment.position;v.set_facing_direction(assignment.facing_direction);v.has_battle_position=true
 for v in vehicles:Cover.ensure_body_cover(b,v.battle_vehicle_id);ensure_doors(b,v)
 g.attacker_vehicle_placement_context=context
 b.arrival_choice=choice;g.content_revision+=1
 return true
static func door_specs(v) -> Array:
 var specs=[];var profile=Body.profile_for_vehicle(v)
 if profile==null:return specs
 var rows=preload("res://campaign/vehicles/vehicle_model_catalog.gd").model(v.vehicle_type_id).get("door_rows",[.12,-.075])
 for row in range(rows.size()):
  for side in [-1.,1.]:
   var id=v.battle_vehicle_id+"__door_"+str(row)+("_north" if side<0 else "_south")
   var local=Vector2(profile.length*float(rows[row]),side*(profile.half_width()+.50))
   var at=Body.local_to_world(local,v.battle_position,v.facing_direction)
   var facing=v.facing_direction
   specs.append({"id":id,"at":at,"slot":at-facing*.70,"facing":facing})
 return specs
static func door_rect(spec) -> Rect2:
 var facing: Vector2=spec.facing
 var size=Vector2(absf(facing.x)*.36+absf(facing.y)*.8,absf(facing.y)*.36+absf(facing.x)*.8)
 return Rect2(spec.at-size*.5,size)
static func ensure_doors(b,v) -> void:
 if not Body.has_usable_pose(v):return
 var g=b.battlefield_geometry;var specs=door_specs(v)
 for spec in specs:
  if g.obstacles.has(spec.id):continue
  if not g.contains_point(spec.at) or not g.get_movement_blocking_obstacle_id_at(spec.at).is_empty() or not Body.blocking_vehicle_id_at(b,spec.at).is_empty():continue
  var blocked=[];var owned=false;var sweep=door_rect(spec)
  for slot in g.cover_slots.values():
   if sweep.has_point(slot.position):
    if slot.is_occupied() or slot.is_reserved():owned=true;break
    blocked.append(slot)
  if owned:continue
  for slot in blocked:
   b.vehicle_hidden_cover_slots[slot.cover_slot_id]=slot
   g.remove_cover_slot(slot.cover_slot_id)
  g.add_obstacle(Obstacle.new(spec.id,sweep,true,false,"car_door"))
 for spec in specs:
  if g.has_cover_object(spec.id) or not g.obstacles.has(spec.id):continue
  if not g.contains_point(spec.slot) or not g.get_movement_blocking_obstacle_id_at(spec.slot).is_empty() or not Body.blocking_vehicle_id_at(b,spec.slot).is_empty():continue
  g.add_cover_object(CoverObject.new(spec.id,spec.id))
  g.add_cover_slot(Slot.new(spec.id+"_cover",spec.id,spec.slot,spec.facing))
static func remove_doors(b,v) -> void:
 var g=b.battlefield_geometry
 for spec in door_specs(v):
  if g.has_cover_object(spec.id):g.remove_cover_object(spec.id)
  if g.obstacles.erase(spec.id):g.content_revision+=1
 restore_clear_slots(b)

static func restore_clear_slots(b) -> void:
 var g=b.battlefield_geometry
 for id in b.vehicle_hidden_cover_slots.keys():
  var slot=b.vehicle_hidden_cover_slots[id]
  if not g.has_cover_object(slot.cover_object_id):b.vehicle_hidden_cover_slots.erase(id);continue
  if g.has_cover_slot(id):b.vehicle_hidden_cover_slots.erase(id);continue
  if g.contains_point(slot.position) and g.get_movement_blocking_obstacle_id_at(slot.position).is_empty():
   if g.add_cover_slot(slot):b.vehicle_hidden_cover_slots.erase(id)
