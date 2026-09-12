extends RefCounted
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
static func route(b,vehicle,destination: Vector2) -> Dictionary:
 if vehicle==null or not Body.has_usable_pose(vehicle):return {}
 var profile=Body.profile_for_vehicle(vehicle);var m=Models.model(vehicle.vehicle_type_id)
 var candidates: Array[Vector2]=[]
 var rows=m.get("door_rows",[.12,-.075]).duplicate()
 if rows.is_empty():rows=[0.,-.25,.25]
 for row in rows:
  for side in [-1.,1.]:
   candidates.append(Body.local_to_world(Vector2(profile.length*float(row)-.35,side*(profile.half_width()+1.)),vehicle.battle_position,vehicle.facing_direction))
 for side in [-1.,1.]:
  candidates.append(Body.local_to_world(Vector2(-profile.half_length()-.8,side*.4),vehicle.battle_position,vehicle.facing_direction))
  candidates.append(Body.local_to_world(Vector2(profile.half_length()+.8,side*.4),vehicle.battle_position,vehicle.facing_direction))
 candidates.sort_custom(func(a,b):return a.distance_squared_to(destination)<b.distance_squared_to(destination))
 for origin in candidates:
  var planned=Nav.find_path(b,origin,destination)
  if planned!=null and planned.success:return {"origin":origin,"path":planned}
 return {}
