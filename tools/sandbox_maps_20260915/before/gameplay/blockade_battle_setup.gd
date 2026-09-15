extends RefCounted
## Controlled checkpoint battle geometry, applied before deployment planning.
const Obstacle=preload("res://battle/geometry/battle_obstacle.gd")
const Cover=preload("res://battle/geometry/battle_cover_object.gd")
const Slot=preload("res://battle/geometry/battle_cover_slot.gd")
const Vehicle=preload("res://battle/core/battle_vehicle.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const VehicleCover=preload("res://battle/vehicles/battle_vehicle_cover_service.gd")
static func apply(b,context: Dictionary) -> bool:
 if context.is_empty():return true
 if context.get("kind","")=="pursuit":return true
 if context.get("kind","")!="lockdown" or context.get("cover_barriers",0)!=2:return false
 var g=b.battlefield_geometry
 if g.authored_layout_id!="dead_street_dusk_v1":return false
 var side=b.get_side(b.defender_side_id);var zone=b.get_deployment_zone(side.deployment_zone_id)
 var v=Vehicle.new("checkpoint_roadwarden","checkpoint_roadwarden",side.faction_id,side.side_id,"roadwarden")
 v.battle_position=Vector2(24.5,29.);v.has_battle_position=true;v.set_facing_direction(Vector2.RIGHT)
 if not Body.blocking_vehicle_id_at(b,v.battle_position).is_empty():return false
 if not b.add_vehicle(v) or not side.add_vehicle_id(v.battle_vehicle_id):return false
 zone.allowed_vehicle_ids.append(v.battle_vehicle_id)
 if not b.deploy_vehicle(v.battle_vehicle_id,zone.zone_id):return false
 VehicleCover.ensure_body_cover(b,v.battle_vehicle_id)
 for i in range(2):
  var id="roadwarden_screen_"+str(i);var y=26.3+i*4.2;var rect=Rect2(29.4,y,.42,1.8);var at=Vector2(28.65,y+.9)
  if not g.get_movement_blocking_obstacle_id_at(at).is_empty() or not Body.blocking_vehicle_id_at(b,at).is_empty():return false
  # Remove only unoccupied authored cover positions that the new panel occupies.
  for existing in g.cover_slots.values():
   if rect.has_point(existing.position):
    if existing.is_occupied() or existing.is_reserved():return false
    g.remove_cover_slot(existing.cover_slot_id)
  if not g.add_obstacle(Obstacle.new(id,rect,true,false,"barrier")):return false
  if not g.add_cover_object(Cover.new(id,id)) or not g.add_cover_slot(Slot.new(id+"_slot",id,at,Vector2.RIGHT)):return false
 g.content_revision+=1
 if not g.is_valid():
  for slot in g.cover_slots.values():
   if not g._cover_slot_position_is_legal(slot.position):printerr("CHECKPOINT_INVALID_SLOT ",slot.cover_slot_id," ",slot.position)
  return false
 return true
