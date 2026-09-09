extends SceneTree
func _initialize():
	call_deferred("run_checks")
func run_checks():
	var c=load("res://core/core_validation.gd")
	var failures=[]
	for name in ["_battleclosing_defend_ok","_battledefend_far_target_ok","_battlefallback_counters_ok","_battlefocus_counters_ok","_battlepush_counter_ok","_defender_ai_cover_ok","_battlehealthycover_target_change_researches_ok","_battlehealthycover_los_change_researches_ok","_battleclosing_target_change_ok"]:
		var ok=c.call(name)
		if not ok:failures.append(name)
	print("QUEUE_TARGETED ",JSON.stringify({"failed":failures}))
	quit(0 if failures.is_empty() else 1)
