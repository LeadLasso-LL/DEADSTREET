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
 if vehicles.size()!=1:return false
 var v=vehicles[0];var spec=Catalog.ARRIVAL_OPTIONS[choice];var c: Vector2=spec.center
 var rect=Rect2(maxf(0,c.x-8),24,minf(64,c.x+12)-maxf(0,c.x-8),10.8)
 var old_area=g.attacker_deployment_area;var old_rect=g.attacker_deployment_rect
 var area=Area.new();area.add_pocket(Pocket.new("arrival_"+choice,Catalog.rect_points(rect)))
 g.attacker_deployment_area=area;g.attacker_deployment_rect=rect
 # Validate before changing any unit, reservation, or vehicle pose.
 var previous_positions={}
 for p in b.participants.values():
  if p.side_id==b.attacker_side_id:previous_positions[p.participant_id]=p.has_battle_position;p.has_battle_position=false
 var error=Body.get_placement_error(b,v.battle_vehicle_id,c,Vector2.LEFT)
 for id in previous_positions:b.get_participant(id).has_battle_position=previous_positions[id]
 if not error.is_empty():g.attacker_deployment_area=old_area;g.attacker_deployment_rect=old_rect;return false
 for p in b.participants.values():
  if p.side_id!=b.attacker_side_id:continue
  CoverService.release_all_for_participant(b,p.participant_id);p.clear_pending_deployment_cover();p.clear_player_tactical_intent()
  p.has_battle_position=false;p.deployment_slot_id=""
 var zone=b.get_deployment_zone(b.get_side(b.attacker_side_id).deployment_zone_id)
 zone.deployed_participant_ids.clear();zone.deployment_rect=rect
 remove_doors(b,v)
 var body_id=Cover.body_cover_object_id(v.battle_vehicle_id)
 if g.has_cover_object(body_id):g.remove_cover_object(body_id)
 v.battle_position=c;v.set_facing_direction(Vector2.LEFT)
 Cover.ensure_body_cover(b,v.battle_vehicle_id)
 g.attacker_vehicle_placement_context=preload("res://battle/vehicles/battle_vehicle_placement_context.gd").new(true,c,true,Vector2.LEFT)
 b.arrival_choice=choice;g.content_revision+=1
 ensure_doors(b,v)
 return true
static func door_specs(v) -> Array:
 var specs=[];var profile=Body.profile_for_vehicle(v)
 if profile==null:return specs
 for row in range(2):
  for side in [-1.,1.]:
   var id=v.battle_vehicle_id+"__door_"+str(row)+("_north" if side<0 else "_south")
   # Four separate compact leaves, front-hinged; units shelter behind the leaf toward the rear.
   var local=Vector2(profile.length*(.12 if row==0 else -.075),side*(profile.half_width()+.50))
   var at=Body.local_to_world(local,v.battle_position,v.facing_direction)
   var facing=v.facing_direction
   specs.append({"id":id,"at":at,"slot":at-facing*.70,"facing":facing})
 return specs
static func ensure_doors(b,v) -> void:
 if not Body.has_usable_pose(v):return
 var g=b.battlefield_geometry
 for spec in door_specs(v):
  if g.has_cover_object(spec.id):continue
  var rect=Rect2(spec.at-Vector2(.18,.40),Vector2(.36,.8))
  if not g.contains_point(spec.slot) or not g.get_movement_blocking_obstacle_id_at(spec.slot).is_empty():continue
  g.add_obstacle(Obstacle.new(spec.id,rect,true,false,"car_door"))
  g.add_cover_object(CoverObject.new(spec.id,spec.id))
  g.add_cover_slot(Slot.new(spec.id+"_cover",spec.id,spec.slot,spec.facing))
static func remove_doors(b,v) -> void:
 var g=b.battlefield_geometry
 for spec in door_specs(v):
  if g.has_cover_object(spec.id):g.remove_cover_object(spec.id)
  if g.obstacles.erase(spec.id):g.content_revision+=1
