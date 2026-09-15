extends "res://tools/selected_range_20260915/check_native.gd"
func run():
	root.size=Vector2i(1440,1000)
	for map_id in ["river_bridge","whittaker_estate"]:
		var scene=load("res://gameplay/arsenal_review.tscn").instantiate()
		root.add_child(scene)
		await process_frame
		var config=Cases.make(12,12,["aegis","vigil","aegis"])
		config.map_id=map_id;config.attacker.faction="trc"
		config.defender.faction="whittaker" if map_id=="whittaker_estate" else "orlov"
		config.defender.vehicles=["bulwark","interceptor","bulwark"]
		await scene.start_battle(false,config)
		scene.set_process(false)
		var b=scene.battle
		check(b!=null,map_id+" native setup")
		if b==null:scene.queue_free();continue
		var context=b.battlefield_geometry.attacker_vehicle_placement_context
		check(context==null or is_equal_approx(context.parking_clearance,.6),map_id+" retains previous clearance")
		var view=scene.runtime.get_node("TacticalBattleView")
		view.battle_presentation.skip_to_ready()
		check(Fixture.begin_review(scene.runtime,b).success,map_id+" starts")
		b.tactical_paused=true
		await settle(.2)
		scene.queue_free();await process_frame
	var report={"checks":checks,"errors":errors}
	FileAccess.open("res://tools/harold_scale_20260915/other_maps_report.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OTHER_MAPS ",JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
