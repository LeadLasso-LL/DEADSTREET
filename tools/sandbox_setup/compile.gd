extends SceneTree
func _initialize():
 var errors=[]
 for path in ["sandbox_force_config","sandbox_force_builder","arsenal_battle_fixture","arsenal_review","vehicle_fleet_panel","tactical_command_hud","tactical_battle_presentation"]:
  var script=load("res://gameplay/"+path+".gd")
  if script==null or not script.can_instantiate():errors.append(path)
 print("FLEXIBLE_COMPILE ",errors);quit(0 if errors.is_empty() else 1)
