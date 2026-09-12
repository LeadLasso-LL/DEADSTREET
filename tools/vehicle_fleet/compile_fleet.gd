extends SceneTree
func _initialize():
 var paths=["res://campaign/vehicles/vehicle_encounter_service.gd","res://gameplay/vehicle_encounter_lab.gd","res://gameplay/vehicle_fleet_panel.gd","res://gameplay/arsenal_review.gd","res://gameplay/fleet_vehicle_art.gd","res://gameplay/campaign_map_view.gd","res://addons/faction_roster_export/roster_export.gd"]
 var errors=[]
 for path in paths:
  var script=load(path)
  if script==null or not script.can_instantiate():errors.append(path)
 print("FLEET_COMPILE ",errors)
 quit(0 if errors.is_empty() else 1)
