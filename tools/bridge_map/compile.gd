extends SceneTree
func _initialize():
 var failures=[]
 for path in ["battle/geometry/river_bridge_catalog.gd","gameplay/river_bridge_art.gd","gameplay/bridge_battle_setup.gd","gameplay/sandbox_force_config.gd","gameplay/sandbox_force_builder.gd","gameplay/arsenal_battle_fixture.gd","gameplay/tactical_battle_view.gd","gameplay/tactical_battle_presentation.gd","gameplay/tactical_battle_outro.gd"]:
  if load("res://"+path)==null:failures.append(path)
 print("BRIDGE_COMPILE ",failures);quit(0 if failures.is_empty() else 1)
