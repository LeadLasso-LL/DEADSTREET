extends "res://tools/selected_range_20260915/check_native.gd"
const H = preload("res://battle/geometry/harold_street_catalog.gd")
const Exit = preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
const Nav = preload("res://battle/navigation/battle_navigation_service.gd")
func run():
	out = "res://tools/harold_scale_20260915/hq_red/"
	root.size=Vector2i(1440,1000)
	DisplayServer.window_set_size(root.size)
	var scene=load("res://gameplay/arsenal_review.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var config=Cases.make(12,12,["taiga","bayou","outlander"])
	config.map_id="harold"
	config.attacker.faction="orlov"
	config.defender.faction="mercer"
	await scene.start_battle(false,config)
	scene.set_process(false)
	var b=scene.battle
	check(b!=null,"native Harold fixture")
	if b==null: quit(1);return
	var view=scene.runtime.get_node("TacticalBattleView")
	var cars=0
	for row in H.props():
		if row[2]!="car":continue
		cars+=1
		check(H.ROAD.encloses(row[1]),"parked body inside road "+row[0])
		for other in H.props():
			if other[0]!=row[0]: check(not row[1].intersects(other[1]),"parked clearance "+row[0]+"/"+other[0])
		if row[0]=="north_car_2":
			check(row[4]=="veloce","HQ uses Veloce Rosso")
			check(row[1].size.is_equal_approx(Vector2(4.55,1.98)*1.6),"Veloce actual scaled body")
			check(row[1].position.x<23 and row[1].end.x>27.1,"Veloce directly fronts the steps")
	check(cars==12,"twelve parked cars")
	for slot in b.battlefield_geometry.cover_slots.values():
		check(Nav.is_reachable(b,Vector2(25,20),slot.position),"reachable cover "+slot.cover_slot_id)
	for point in [Vector2(25,15.2),Vector2(51,15.2),Vector2(36,12)]:
		check(Nav.is_reachable(b,Vector2(25,20),point),"entrance/alley access "+str(point))
	var found=false
	for node in view.dynamic_unit_root.get_children():
		if not node.has_node("ParkedArsenalVehicle") or node.prop[0]!="north_car_2":continue
		var car=node.get_node("ParkedArsenalVehicle")
		found=true
		check(car.model_id=="veloce" and H.VehicleModels.sprite(car.model_id,car.facing,0.)!=null,"Veloce canonical sprite renders")
		check(node.position.is_equal_approx(node.prop[1].get_center()*Vector2(8,6)),"Veloce artwork/cover ground anchor")
	check(found,"HQ parked vehicle visible node")
	var exits=0
	for p in b.participants.values():
		if p.side_id!=b.attacker_side_id:continue
		var v=b.get_vehicle(p.transport_vehicle_id)
		check(v!=null and v.has_battle_position,"assigned transport "+p.participant_id)
		if v!=null:
			var route=Exit.route(b,v,p.battle_position,bool(p.get_meta("transport_bed",false)))
			check(not route.is_empty(),"disembark route "+p.participant_id)
			if not route.is_empty():exits+=1
	view.battle_presentation.skip_to_ready()
	check(Fixture.begin_review(scene.runtime,b).success,"battle starts")
	b.tactical_paused=true
	await settle(.5)
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(out+"DEAD_STREET_Harold_Red_HQ_Car.png")==OK,"native screenshot saved")
	var report={"checks":checks,"errors":errors,"disembark_routes":exits,"model":"veloce","capture":"native paused 12v12 Orlov/Mercer"}
	FileAccess.open(out+"report.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("HQ_REPORT ",JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
