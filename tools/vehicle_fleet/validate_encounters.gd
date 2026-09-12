extends SceneTree
const Service=preload("res://campaign/vehicles/vehicle_encounter_service.gd")
const Scenarios=preload("res://gameplay/vehicle_encounter_scenarios.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);printerr("ENCOUNTER_FAIL ",message)
func run():
 var f=Scenarios.new();f.reset();var s=f.service
 for index in range(7):
  check(not f.run(index,true).success,"counterplay %d"%index)
  check(f.run(index).success,"ability %d"%index)
 check(not f.run(1).success and not s.can_move("lab","crownfire"),"breakaway spent and turn ended")
 s.advance_turn();check(s.can_move("lab","crownfire") and not f.run(1).success,"next turn restores movement, not journey charge")
 check(not f.run(5).success,"life support once per battle")
 check(not f.run(6).success and s.data.heat.player==25.,"breach once and heat exactly 25")
 check(s.start_journey("second","player",[{"id":"ambulance2","model":"archangel","occupants":["wounded2"]}]).success,"second recovery vehicle")
 check(not s.recover("second","ambulance2","battle_01",{"id":"wounded2","status":"critical","hp":1},true,true).success,"life support does not stack across journeys")
 check(not s.start_journey("duplicate","player",[{"id":"wraith_zero","model":"wraith_zero","occupants":["other"]}]).success,"active vehicle cannot duplicate journey")
 check(not s.start_journey("overloaded","player",[{"id":"x","model":"wraith_zero","occupants":["a","b"]}]).success,"driver included in seats")
 check(not s.cross_country("lab",["nomad"],{"designated":true,"kind":"water"}).success,"no water shortcut")
 check(not s.scout("lab","crownfire","a","b",[{"from":"a","to":"b","kind":"road"}],{}).success,"ability restricted to correct vehicle")
 var scoped=s.flank("lab","asterion","north",{"north":{"road_connected":true,"legal":true,"occupied":false}})
 check(scoped.occupants==["asterion_driver"],"flank affects own occupants only")
 s.set_jammer("lab","eidolon",false);check(not s.stop("lab","eidolon","routine_police").success,"jammer must be active")
 f.reset();s=f.service
 check(f.run(7).success and s.data.locations.origin.stock.supplies==10.,"bond dispatch debits stock")
 check(not s.dispatch_resources("other","lab","palisade","origin",{"supplies":1.}).success,"one cargo shipment per vehicle")
 var loss=f.run(7);check(loss.success and loss.enemy_loot.is_empty(),"bonded cargo denied to captor")
 check(not f.run(7).success and not s.deliver_resources("bonded","destination").success,"loss not duplicated or delivered")
 s.advance_turn();check(s.data.locations.origin.stock.supplies==10.,"refund not early")
 f.run(7,true);s.advance_turn();check(s.data.locations.origin.stock.supplies==10.,"captured origin holds escrow")
 var restored=Service.new();check(restored.from_dict(JSON.parse_string(JSON.stringify(s.to_dict()))),"save restore")
 restored.data.locations.origin.owner="player";check(restored.advance_turn()==["bonded"],"mature escrow recovered after ownership restored")
 restored.advance_turn();check(restored.data.locations.origin.stock.supplies==20.,"refund exactly once after reload")
 check(s.data.locations.origin.stock.supplies==10.,"snapshot does not alias live state")
 f.reset();s=f.service
 check(not s.dispatch_resources("bad","lab","palisade","origin",{"supplies":15.}).success and s.data.locations.origin.stock.supplies==20.,"over-capacity manifest atomic")
 check(s.dispatch_resources("good","lab","palisade","origin",{"supplies":10.}).success,"valid cargo")
 check(s.deliver_resources("good","destination").success,"normal delivery")
 check(not s.lose_bonded("good").success and not s.deliver_resources("good","destination").success,"delivered cargo cannot claim or redeliver")
 check(s.data.locations.origin.stock.supplies+s.data.locations.destination.stock.supplies==20.,"cargo conserved")
 for index in [8,9]:
  f.reset();s=f.service;var id=Scenarios.IDS[index];var cap=Models.model(id).cash_capacity
  check(not s.dispatch_cash("overflow",id,"bank","destination",cap+1.).success,"cash capacity "+id)
  check(f.run(index).success,"cash departure "+id)
  check(s.data.accounts.bank==500000.-cap,"bank debited "+id)
  check(not s.settle_cash(id,"interceptor",false).success,"failed raid no credit "+id)
  check(f.run(index,true).success and s.data.accounts.interceptor==cap,"victory cash stolen "+id)
  check(not f.run(index).success and not f.run(index,true).success,"no duplicate settlement "+id)
  s.advance_turn();s.advance_turn();s.advance_turn()
  check(s.data.accounts.bank+s.data.accounts.destination+s.data.accounts.interceptor==500000.,"cash conserved, no escrow "+id)
  f.reset();check(f.run(index).success and f.run(index).success,"normal bank arrival "+id)
  check(f.service.data.accounts.destination==cap,"destination paid "+id)
 f.reset();s=f.service
 check(not s.dispatch_cash("negative","sterling_cit","bank","destination",-1.).success,"negative cash rejected")
 check(not s.dispatch_cash("fake","palisade","bank","destination",100.).success,"bank service model required")
 check(f.run(10).success,"eight prisoners and separate guard seats")
 check(not f.run(10,true).success,"failed prison rescue")
 var rescued=f.run(10);check(rescued.success and rescued.freed.size()==8 and rescued.auto_recruited==0,"prisoner rescue")
 check(rescued.freed[0].returns_to=="eastex" and rescued.freed[7].returns_to=="whittaker","allegiance preserved")
 check(not f.run(10).success,"prisoner release idempotent")
 var lab=load("res://gameplay/vehicle_encounter_lab.gd").new();root.add_child(lab);await process_frame
 for index in range(11):lab.picker.select(index);lab.scenarios.reset();lab.execute(false);check(not lab.outcome.text.is_empty(),"interactive scenario %d"%index)
 lab.queue_free();await process_frame
 print("ENCOUNTER_VALIDATION checks=",checks," errors=",errors)
 var output=FileAccess.open("res://tools/vehicle_fleet/validation_encounters.json",FileAccess.WRITE);output.store_string(JSON.stringify({"checks":checks,"errors":errors},"  "))
 quit(0 if errors.is_empty() else 1)
