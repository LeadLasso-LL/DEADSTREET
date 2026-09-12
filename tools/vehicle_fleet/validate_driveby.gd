extends SceneTree
const Scenarios=preload("res://gameplay/vehicle_encounter_scenarios.gd")
const Service=preload("res://campaign/vehicles/vehicle_encounter_service.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var checks=0
var errors=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);printerr("DRIVEBY_FAIL ",message)
func run():
 for index in [11,12]:
  var f=Scenarios.new();f.reset();var s=f.service;var id=Scenarios.IDS[index];var budget=float(Models.model(id).movement_per_turn)
  check(not s.drive_by("lab",id,id+"_shop").success,"cannot strike remote target "+id)
  check(not s.travel_road("lab",id,"unknown").success,"no disconnected travel "+id)
  check(s.travel_road("lab",id,"strip").success,"travel to target "+id)
  var before=s.to_dict();check(not s.drive_by("lab",id,"defended").success,"one defender blocks "+id)
  check(s.to_dict()==before,"defended rejection atomic "+id)
  var hit=s.drive_by("lab",id,id+"_shop");var target=s.data.locations[id+"_shop"]
  check(hit.success and target.status=="destroyed" and target.hp==0,"destroyed state "+id)
  check(not target.income_active and not target.production_active,"business income and production stop "+id)
  check(target.owner=="enemy" and hit.loot.is_empty() and not hit.territory_captured,"no capture or loot "+id)
  check(is_equal_approx(hit.movement_remaining,budget-2.) and s.data.turn==0 and not hit.turn_ended,"remaining movement retained "+id)
  check(s.data.heat.player==30.,"heat exactly once "+id)
  check(not s.drive_by("lab",id,id+"_shop").success,"destroyed target not repeated "+id)
  var second=target.duplicate(true);second.status="operational";second.hp=100;second.income_active=true;second.production_active=true;s.data.locations.second=second
  before=s.to_dict();check(not s.drive_by("lab",id,"second").success and s.to_dict()==before,"one strike per vehicle per turn "+id)
  var restored=Service.new();check(restored.from_dict(JSON.parse_string(JSON.stringify(s.to_dict()))),"restore driveby save "+id)
  check(not restored.drive_by("lab",id,"second").success,"save does not reset charge "+id)
  check(restored.travel_road("lab",id,"exit").success,"continue movement after strike "+id)
  check(is_equal_approx(restored.vehicle("lab",id).movement_left,budget-4.5),"normal road cost still paid "+id)
  restored.data.roads.append({"from":"exit","to":"far","kind":"road","distance":9.})
  before=restored.to_dict();check(not restored.travel_road("lab",id,"far").success and restored.to_dict()==before,"no overspend "+id)
  s.advance_turn();check(s.drive_by("lab",id,"second").success,"next turn refreshes strike "+id)
  check(is_equal_approx(s.vehicle("lab",id).movement_left,budget) and s.data.turn==1,"only advancing turn refills movement "+id)
  f.reset();s=f.service;s.travel_road("lab",id,"strip");s.vehicle("lab",id).occupants=[id+"_driver"]
  check(not s.drive_by("lab",id,id+"_shop").success,"driver alone cannot fire "+id)
  s.vehicle("lab",id).occupants.append(id+"_passenger")
  for property in [{"owner":"player"},{"owner":""},{"kind":"road"},{"defenders":-1},{"status":"destroyed"}]:
   var original=s.data.locations[id+"_shop"].duplicate(true);s.data.locations[id+"_shop"].merge(property,true);before=s.to_dict()
   check(not s.drive_by("lab",id,id+"_shop").success and s.to_dict()==before,"invalid target atomic "+id+str(property))
   s.data.locations[id+"_shop"]=original
  s.vehicle("lab",id).movement_left=0.
  check(s.drive_by("lab",id,id+"_shop").success and not s.can_move("lab",id),"last-distance strike grants no movement "+id)
  check(not s.drive_by("lab","eidolon",id+"_shop").success,"non-driveby model rejected")
 var f=Scenarios.new();f.reset()
 check(f.run(11).success and f.run(12).success,"separate vehicles each have one strike")
 check(f.service.data.heat.player==60.,"two strikes add correct heat")
 var legacy=f.service.to_dict();legacy.erase("roads");legacy.erase("driveby_uses")
 check(Service.new().from_dict(legacy),"older lab snapshot fields migrate")
 var lab=load("res://gameplay/vehicle_encounter_lab.gd").new();root.add_child(lab);await process_frame
 for index in [11,12]:
  lab.scenarios.reset();lab.picker.select(index);lab.execute(false)
  check(lab.outcome.text.contains("destroyed") and lab.state_label.text.contains("Remaining movement"),"interactive strike")
  lab.execute(false);check(lab.outcome.text.contains("Road movement completed"),"interactive continuation")
 lab.queue_free();await process_frame
 var report={"checks":checks,"errors":errors};var file=FileAccess.open("res://tools/vehicle_fleet/validation_driveby.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "))
 print("DRIVEBY_VALIDATION ",report);quit(0 if errors.is_empty() else 1)
