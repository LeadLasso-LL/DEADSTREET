extends SceneTree
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Fleet=preload("res://campaign/vehicles/vehicle_fleet_service.gd")
const VehicleData=preload("res://campaign/vehicles/vehicle.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Cover=preload("res://battle/vehicles/battle_vehicle_cover_service.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
class HeadlessView extends Node:
	var _dusk_zoom=1.3
	var _dusk_pan=Vector2.ZERO
	var deployment_controller
	func _frame_camera():pass
var selected_models=Array(OS.get_cmdline_user_args())
var checks=0
var errors: Array=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
	checks+=1
	if not ok:errors.append(message);printerr("FLEET_FAIL ",message)
func run():
	check(Models.all_ids().size()==73,"73 models")
	check(Models.data().faction_preferences.size()==23,"23 faction preferences")
	for faction in Models.data().faction_preferences:
		for id in Models.preferences(faction):check(Models.has_model(id),"preference "+str(id))
	for brand in ["trc","nbpd"]:
		for category in Models.data().classes:
			var covered=false
			for id in Models.all_ids():
				var candidate=Models.model(id)
				if candidate.get("brand", "")==brand and candidate.vehicle_class==category:covered=true
			check(covered,brand+" branded class "+category)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Models.ART+"manifest.json"))
	for id: String in Models.all_ids():
		if not selected_models.is_empty() and not selected_models.has(id):continue
		var m=Models.model(id);var c: Dictionary=Models.data().classes[m.vehicle_class]
		check(m.unit_capacity>=1 and m.unit_capacity<=c.max_units,id+" class capacity")
		check((m.resource_capacity>0)==(bool(c.resources) and not m.get("service_only",false)),id+" exclusive freight class")
		check(m.price>0 and m.movement_per_turn>0 and m.upkeep_per_turn>=0,id+" economy")
		var vehicle=Fleet.create("test",Starter.PLAYER_FACTION_ID,id)
		check(vehicle!=null and vehicle.passenger_capacity==int(m.unit_capacity),id+" factory")
		var store=ResourceStore.new();store.set_amount("supplies",100.)
		check(Fleet.load_resource(vehicle,store,"supplies",1.)==(bool(c.resources) and not m.get("service_only",false)),id+" cargo eligibility")
		if c.resources and not m.get("service_only",false):
			check(not Fleet.load_resource(vehicle,store,"supplies",m.resource_capacity+1.),id+" cargo overflow rejected")
			check(vehicle.cargo_amount()==1. and store.get_amount("supplies")==99.,id+" atomic cargo rejection")
		var restored=VehicleData.new();restored.from_dict(vehicle.to_dict())
		check(restored.passenger_capacity==vehicle.passenger_capacity and restored.cargo.to_dict()==vehicle.cargo.to_dict(),id+" save roundtrip")
		for frame in manifest.models[id].frames:
			var image=Image.new();var loaded=image.load_png_from_buffer(FileAccess.get_file_as_bytes(Models.ART+"sprites/"+frame))==OK
			check(loaded,id+" frame "+frame)
			if loaded:
				var rect=image.get_used_rect()
				check(image.get_size()==Vector2i(640,480) and rect.position.x>0 and rect.position.y>0 and rect.end.x<640 and rect.end.y<480,id+" frame bounds")
	check(not Models.convoy(["yardbird"],5).valid,"insufficient seats")
	check(not Models.convoy(["bayou","bayou"],1).valid,"insufficient drivers")
	check(Models.convoy(["yardbird","bastion"],5).movement==1.,"slowest convoy speed")
	var old=VehicleData.new();old.from_dict({"id":"legacy","vehicle_type_id":"car","passenger_capacity":4,"movement_per_turn":5.})
	check(old.passenger_capacity==4 and old.movement_per_turn==5. and old.cargo_amount()==0.,"legacy vehicle compatibility")
	var purchase_state=Starter.create();var gang=purchase_state.get_faction(Starter.PLAYER_FACTION_ID);gang.money=1000000.
	var bought=Fleet.purchase(purchase_state,Starter.PLAYER_FACTION_ID,Starter.KEEP_ID,"shortbox")
	check(bought.success and gang.money==983500.,"campaign vehicle purchase")
	# Every model completes real campaign travel, parking, deployment and troop assignment.
	for id: String in Models.all_ids():
		if not selected_models.is_empty() and not selected_models.has(id):continue
		var convoy=[]
		for i in range(ceili(5./float(Models.model(id).unit_capacity))):convoy.append(id)
		var runtime=load("res://gameplay/gameplay_runtime.gd").new()
		runtime.game_state=Starter.create()
		runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
		var view=HeadlessView.new();view.name="TacticalBattleView";runtime.add_child(view)
		var loadouts={"attacker":{"faction":"trc","vehicles":convoy},"defender":{"faction":"mercer"}}
		var result=Fixture.setup(runtime,loadouts,false,48201,true)
		check(result.has("battle"),id+" battle setup: "+str(result.get("error","")))
		if result.has("battle"):
			var b=result.battle;var occupants={}
			for p in b.participants.values():
				if p.side_id!=b.attacker_side_id:continue
				check(b.has_vehicle(p.transport_vehicle_id),id+" transport assignment")
				occupants[p.transport_vehicle_id]=int(occupants.get(p.transport_vehicle_id,0))+1
			for v in b.vehicles.values():
				check(Body.has_usable_pose(v),id+" legal parked pose")
				check(int(occupants.get(v.battle_vehicle_id,0))>=1 and int(occupants.get(v.battle_vehicle_id,0))<=int(Models.model(v.vehicle_type_id).unit_capacity),id+" no overloaded vehicle")
				if id=="yardbird":check(Cover.collect_legal_body_slots(b,v).is_empty(),"bicycle has no cover")
			var director=load("res://gameplay/tactical_battle_presentation.gd").new()
			director.view=view;director.battle=b;view.deployment_controller=runtime.tactical_deployment_controller
			director.begin_arrival()
			check(director.last_path_errors.is_empty(),id+" disembark paths: "+str(director.last_path_errors))
			director.free()
		print("FLEET_MODEL_TEST ",id,flush_stdout())
		runtime.free();await process_frame
	print("FLEET_VALIDATION checks=",checks," errors=",errors)
	var report_path="res://tools/vehicle_fleet/validation.json" if selected_models.is_empty() else "res://tools/vehicle_fleet/validation_driveby_fleet.json"
	var file=FileAccess.open(report_path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"errors":errors,"models_tested":Models.all_ids() if selected_models.is_empty() else selected_models,"catalog_models":Models.all_ids().size()},"  "))
	quit(0 if errors.is_empty() else 1)
func flush_stdout():return ""
