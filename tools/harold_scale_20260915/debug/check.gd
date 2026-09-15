extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate()
 scene.set_script(load("res://tools/harold_scale_20260915/debug/review.gd"))
 root.add_child(scene)
 await process_frame
 var config=preload("res://tools/sandbox_setup/scenarios.gd").make(12,12,["taiga","bayou","outlander"])
 config.map_id="harold";config.attacker.faction="orlov";config.defender.faction="mercer"
 await scene.start_battle(false,config)
 quit()
