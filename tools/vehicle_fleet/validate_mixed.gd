extends "res://tools/vehicle_fleet/validate_fleet.gd"
func run():
 var combos=[["bastion","yardbird","bayou"],["shortbox","meridian"],["nightjar","volta","bayou"],["ironhorse","ironhorse","bayou"],["pilgrim","wayfarer"]]
 for combo in combos:
  var runtime=load("res://gameplay/gameplay_runtime.gd").new()
  runtime.game_state=Starter.create();runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
  var view=HeadlessView.new();view.name="TacticalBattleView";runtime.add_child(view)
  var result=Fixture.setup(runtime,{"attacker":{"faction":"trc","vehicles":combo},"defender":{"faction":"mercer"}},false,48201,true)
  check(result.has("battle"),str(combo)+" mixed deployment "+str(result.get("error","")))
  if result.has("battle"):
   var b=result.battle;var counts={}
   for p in b.participants.values():
    if p.side_id==b.attacker_side_id:counts[p.transport_vehicle_id]=int(counts.get(p.transport_vehicle_id,0))+1
   for v in b.vehicles.values():
    check(int(counts.get(v.battle_vehicle_id,0))>=1,"actual driver "+v.vehicle_type_id)
    check(int(counts.get(v.battle_vehicle_id,0))<=Models.model(v.vehicle_type_id).unit_capacity,"capacity "+v.vehicle_type_id)
   var director=load("res://gameplay/tactical_battle_presentation.gd").new();director.view=view;director.battle=b;view.deployment_controller=runtime.tactical_deployment_controller
   director.begin_arrival();check(director.last_path_errors.is_empty(),"mixed disembark "+str(combo));director.free()
  runtime.free();await process_frame
 var state=Starter.create();var gang=state.get_faction(Starter.PLAYER_FACTION_ID)
 check(not Fleet.purchase(state,Starter.PLAYER_FACTION_ID,Starter.KEEP_ID,"bastion").success,"insufficient purchase funds")
 gang.money=1000000.
 check(not Fleet.purchase(state,Starter.RIVAL_FACTION_ID,Starter.KEEP_ID,"bayou").success,"wrong-owner purchase")
 var v=Fleet.create("cargo_test",Starter.PLAYER_FACTION_ID,"shortbox");var source=ResourceStore.new();source.set_amount("Ammo",20.)
 check(not Fleet.load_resource(v,source,"Ammo",-1.),"negative cargo")
 check(Fleet.load_resource(v,source,"Ammo",6.),"load six")
 check(Fleet.unload_resource(v,source,"Ammo",2.),"unload two")
 check(v.cargo_amount()==4. and source.get_amount("Ammo")==16.,"cargo conservation")
 state.add_vehicle(v)
 var restored=GameState.new();restored.from_dict(state.to_dict())
 check(restored.get_vehicle("cargo_test").cargo_amount()==4.,"whole campaign cargo save")
 print("FLEET_MIXED checks=",checks," errors=",errors)
 var file=FileAccess.open("res://tools/vehicle_fleet/validation_mixed.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"errors":errors},"  "))
 quit(0 if errors.is_empty() else 1)
