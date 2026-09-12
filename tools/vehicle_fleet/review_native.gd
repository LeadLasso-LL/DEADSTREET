extends SceneTree
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
var errors=[]
var review
var output="res://tools/vehicle_fleet/native_review/"
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
	if not ok:errors.append(message);printerr("FLEET_VISUAL_FAIL ",message)
func capture(name: String):
	await process_frame
	await RenderingServer.frame_post_draw
	var picture=root.get_texture().get_image()
	check(not picture.is_empty(),name+" render")
	if not picture.is_empty():picture.save_png(output+name+".png")
func run():
	root.size=Vector2i(1152,860)
	DisplayServer.window_set_size(Vector2i(1152,860))
	DirAccess.make_dir_recursive_absolute(output)
	review=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(review)
	await create_timer(1.).timeout
	review.open_vehicle_fleet()
	var panel=review.surface.get_node("VehicleFleet")
	for category in ["two_wheelers","passenger_cars","utility_vehicles","heavy_transports"]:
		panel.class_buttons[category].pressed.emit()
		await create_timer(.25).timeout
		await capture("selector_"+category)
	panel.selected=["bastion"];panel.refresh_convoy()
	panel.apply_button.pressed.emit();await process_frame
	check(review.loadouts.attacker.vehicles==["bastion"],"selector updates actual attacker loadout")
	for scenario in [{"name":"trc_bastion","faction":"trc","vehicles":["bastion"]},{"name":"nbpd_patrol","faction":"nbpd","vehicles":["interceptor","warden"]},{"name":"raiders_bus","faction":"sand_raiders","vehicles":["pilgrim"]},{"name":"bicycle_convoy","faction":"mercer","vehicles":["yardbird","yardbird","yardbird","yardbird","yardbird"]}]:
		review.loadouts.attacker.faction=scenario.faction
		review.loadouts.attacker.vehicles=scenario.vehicles
		await review.start_battle(false)
		check(review.battle!=null,scenario.name+" fixture")
		if review.battle==null:continue
		await create_timer(6.).timeout
		var view=review.runtime.get_node("TacticalBattleView")
		var presentation=view.battle_presentation
		check(presentation.last_path_errors.is_empty(),scenario.name+" arrival paths")
		check(view._dusk_vehicle_nodes.size()==scenario.vehicles.size(),scenario.name+" rendered vehicle count")
		for node in view._dusk_vehicle_nodes.values():check(node.visible,scenario.name+" vehicle visible")
		await capture(scenario.name+"_arrival")
		await create_timer(9.).timeout
		await capture(scenario.name+"_battle")
		check(review.battle.participants.size()==10,scenario.name+" retained full roster")
		review.runtime.queue_free();review.runtime=null;review.battle=null;review.ui.visible=true
		await process_frame;await process_frame
	print("FLEET_NATIVE_VISUAL ",errors)
	var report=FileAccess.open(output+"report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"scenarios":4,"errors":errors},"  "))
	review.queue_free();await process_frame
	quit(0 if errors.is_empty() else 1)
