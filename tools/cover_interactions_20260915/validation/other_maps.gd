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

		var legacy=load("res://tools/cover_interactions_20260915/validation/legacy_visual.gd")
		var legacy_doors=load("res://tools/cover_interactions_20260915/before/battle_arrival_service.gd")
		for p in b.participants.values():
			check(preload("res://battle/presentation/tactical_participant_visual.gd").view_origin(b,p,8.).is_equal_approx(legacy.view_origin(b,p,8.)),map_id+" unchanged unit origin "+p.participant_id)
		for v in b.vehicles.values():
			check(var_to_str(preload("res://battle/vehicles/battle_arrival_service.gd").door_specs(v))==var_to_str(legacy_doors.door_specs(v)),map_id+" unchanged door geometry "+v.battle_vehicle_id)
		scene.queue_free();await process_frame
	var report={"checks":checks,"errors":errors}
	FileAccess.open("res://tools/cover_interactions_20260915/validation/other_maps_report.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OTHER_MAPS ",JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
